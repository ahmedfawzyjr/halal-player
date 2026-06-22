// Halal Player - Frame Analyzer
//
// Extract and analyze video frames for AI content detection.
// The VideoPlayerScreen registers a frame-callback; the periodic
// timer calls it to obtain raw JPEG bytes and run AI analysis.

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import '../core/ai_gateway.dart';
import '../core/policy_engine.dart';

/// Result of frame analysis
class FrameAnalysisResult {
  const FrameAnalysisResult({
    required this.timestamp,
    required this.policyResult,
    required this.processingTimeMs,
  });

  final Duration timestamp;
  final PolicyResult policyResult;
  final int processingTimeMs;

  bool get isSafe => policyResult.action == ContentAction.allow;
  bool get shouldBlur => policyResult.action == ContentAction.blur;
  bool get shouldBlock => policyResult.action == ContentAction.block;
}

/// Frame analyzer for video content
class FrameAnalyzer {
  FrameAnalyzer({
    required this.aiGateway,
    required this.policyEngine,
    this.analysisIntervalMs = 1000,
  });

  final AIGateway aiGateway;
  final PolicyEngine policyEngine;
  final int analysisIntervalMs;

  // Analysis state
  bool _isAnalyzing = false;
  bool _isPaused = false;
  Timer? _analysisTimer;

  // Frame-callback registered by the player screen.
  // Returns raw JPEG bytes for the current video frame,
  // or null if no frame is available right now.
  Future<Uint8List?> Function()? _frameCallback;

  // Cache for analyzed frames
  final Map<int, FrameAnalysisResult> _frameCache = {};

  // Stream controller for analysis results
  final _resultController = StreamController<FrameAnalysisResult>.broadcast();

  /// Stream of analysis results
  Stream<FrameAnalysisResult> get resultStream => _resultController.stream;

  /// Whether analyzer is currently running
  bool get isAnalyzing => _isAnalyzing && !_isPaused;

  /// Register a callback that the analyzer calls every interval to obtain
  /// the current video frame bytes. Set to null to stop frame extraction.
  void setFrameCallback(Future<Uint8List?> Function()? callback) {
    _frameCallback = callback;
  }

  /// Start analyzing frames
  void start() {
    if (_isAnalyzing) return;
    
    _isAnalyzing = true;
    _isPaused = false;
    
    _analysisTimer = Timer.periodic(
      Duration(milliseconds: analysisIntervalMs),
      (_) => _analyzeCurrentFrame(),
    );
  }

  /// Pause analysis (e.g., when video is paused)
  void pause() {
    _isPaused = true;
  }

  /// Resume analysis
  void resume() {
    _isPaused = false;
  }

  /// Stop analyzing
  void stop() {
    _isAnalyzing = false;
    _isPaused = false;
    _analysisTimer?.cancel();
    _analysisTimer = null;
  }

  /// Clear cached results
  void clearCache() {
    _frameCache.clear();
  }

  /// Get cached result for a timestamp
  FrameAnalysisResult? getCachedResult(Duration timestamp) {
    // Round to nearest second for cache lookup
    final key = timestamp.inSeconds;
    return _frameCache[key];
  }

  /// Analyze frame at specific timestamp
  Future<FrameAnalysisResult> analyzeFrame(
    Uint8List frameBytes,
    Duration timestamp,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    // Check cache first
    final cacheKey = timestamp.inSeconds;
    if (_frameCache.containsKey(cacheKey)) {
      return _frameCache[cacheKey]!;
    }
    
    // Run AI analysis
    final aiResult = await aiGateway.analyzeImage(frameBytes);
    
    // Apply policy
    final policyResult = policyEngine.evaluate(
      nsfwScore: aiResult.nsfwScore,
      nudenetScore: aiResult.nudenetScore,
      detectedCategories: aiResult.allCategories,
    );
    
    stopwatch.stop();
    
    final result = FrameAnalysisResult(
      timestamp: timestamp,
      policyResult: policyResult,
      processingTimeMs: stopwatch.elapsedMilliseconds,
    );
    
    // Cache result
    _frameCache[cacheKey] = result;
    
    // Emit result
    _resultController.add(result);
    
    return result;
  }

  /// Called by the periodic timer — grabs the current frame via the
  /// registered callback and runs it through the full AI pipeline.
  Future<void> _analyzeCurrentFrame() async {
    if (_isPaused || !_isAnalyzing || _frameCallback == null) return;

    try {
      // 1. Get raw JPEG bytes from the player
      final frameBytes = await _frameCallback!();
      if (frameBytes == null || frameBytes.isEmpty) return;

      // 2. Build a timestamp key (seconds resolution for the cache)
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final timestamp = Duration(milliseconds: nowMs);
      final cacheKey = nowMs ~/ analysisIntervalMs; // bucket by interval

      // Skip if we already have a result for this bucket
      if (_frameCache.containsKey(cacheKey)) return;

      // 3. Run AI analysis
      final aiResult = await aiGateway.analyzeImage(frameBytes);

      // 4. Apply policy
      final policyResult = policyEngine.evaluate(
        nsfwScore: aiResult.nsfwScore,
        nudenetScore: aiResult.nudenetScore,
        detectedCategories: aiResult.allCategories,
      );

      final result = FrameAnalysisResult(
        timestamp: timestamp,
        policyResult: policyResult,
        processingTimeMs: aiResult.totalProcessingTimeMs,
      );

      // 5. Cache & emit
      _frameCache[cacheKey] = result;
      if (!_resultController.isClosed) {
        _resultController.add(result);
      }
    } catch (_) {
      // Silently ignore errors to keep playback uninterrupted
    }
  }

  /// Dispose resources
  void dispose() {
    stop();
    _resultController.close();
  }
}

/// Isolate-based frame analyzer for heavy processing
class IsolateFrameAnalyzer {
  IsolateFrameAnalyzer();

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  
  final _resultController = StreamController<FrameAnalysisResult>.broadcast();
  Stream<FrameAnalysisResult> get resultStream => _resultController.stream;

  /// Initialize isolate
  Future<void> initialize() async {
    _receivePort = ReceivePort();
    
    _isolate = await Isolate.spawn(
      _isolateEntryPoint,
      _receivePort!.sendPort,
    );
    
    // Get send port from isolate
    _sendPort = await _receivePort!.first as SendPort;
    
    // Listen for results
    _receivePort!.listen((message) {
      if (message is FrameAnalysisResult) {
        _resultController.add(message);
      }
    });
  }

  /// Send frame for analysis
  void analyzeFrame(Uint8List frameBytes, Duration timestamp) {
    _sendPort?.send({
      'bytes': frameBytes,
      'timestamp': timestamp.inMilliseconds,
    });
  }

  /// Dispose isolate
  void dispose() {
    _isolate?.kill();
    _receivePort?.close();
    _resultController.close();
  }

  /// Isolate entry point
  static void _isolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    
    receivePort.listen((message) async {
      if (message is Map<String, dynamic>) {
        // TODO: Process frame in isolate
        // This would run the AI models without blocking UI
      }
    });
  }
}
