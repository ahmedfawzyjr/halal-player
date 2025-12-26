// Halal Player - AI Gateway
// 
// Unified interface for all AI models

import 'dart:typed_data';

/// Result from a single AI detector
class DetectionResult {
  const DetectionResult({
    required this.score,
    required this.modelName,
    this.categories = const {},
    this.processingTimeMs = 0,
  });

  /// Overall score (0.0 = safe, 1.0 = unsafe)
  final double score;

  /// Name of the AI model
  final String modelName;

  /// Detected categories with confidence scores
  final Map<String, double> categories;

  /// Processing time in milliseconds
  final int processingTimeMs;

  @override
  String toString() =>
      'DetectionResult($modelName: ${score.toStringAsFixed(3)})';
}

/// Aggregated result from all AI models
class AggregatedResult {
  const AggregatedResult({
    required this.nsfwResult,
    required this.nudenetResult,
    required this.aggregatedScore,
    required this.allCategories,
    required this.totalProcessingTimeMs,
  });

  final DetectionResult nsfwResult;
  final DetectionResult nudenetResult;
  final double aggregatedScore;
  final List<String> allCategories;
  final int totalProcessingTimeMs;

  /// Get NSFW score
  double get nsfwScore => nsfwResult.score;

  /// Get NudeNet score
  double get nudenetScore => nudenetResult.score;

  @override
  String toString() =>
      'AggregatedResult(score: ${aggregatedScore.toStringAsFixed(3)}, '
      'categories: $allCategories, '
      'time: ${totalProcessingTimeMs}ms)';
}

/// Abstract base class for AI detectors
abstract class AIDetector {
  /// Initialize the model
  Future<void> initialize();

  /// Analyze image bytes
  Future<DetectionResult> analyze(Uint8List imageBytes);

  /// Dispose resources
  Future<void> dispose();

  /// Check if model is ready
  bool get isReady;
}

/// AI Gateway - Unified interface for all AI models
class AIGateway {
  AIGateway({
    required this.nsfwDetector,
    required this.nudenetDetector,
  });

  final AIDetector nsfwDetector;
  final AIDetector nudenetDetector;

  bool _isInitialized = false;

  /// Check if gateway is ready
  bool get isReady => _isInitialized;

  /// Initialize all AI models
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Future.wait([
      nsfwDetector.initialize(),
      nudenetDetector.initialize(),
    ]);

    _isInitialized = true;
  }

  /// Analyze image bytes using all models
  Future<AggregatedResult> analyzeImage(Uint8List imageBytes) async {
    if (!_isInitialized) {
      throw StateError('AIGateway not initialized. Call initialize() first.');
    }

    final stopwatch = Stopwatch()..start();

    // Run both models in parallel
    final results = await Future.wait([
      nsfwDetector.analyze(imageBytes),
      nudenetDetector.analyze(imageBytes),
    ]);

    stopwatch.stop();

    final nsfwResult = results[0];
    final nudenetResult = results[1];

    // Calculate aggregated score
    final aggregatedScore = _calculateAggregatedScore(
      nsfwResult.score,
      nudenetResult.score,
    );

    // Collect all detected categories
    final allCategories = <String>[
      ...nsfwResult.categories.keys,
      ...nudenetResult.categories.keys,
    ];

    return AggregatedResult(
      nsfwResult: nsfwResult,
      nudenetResult: nudenetResult,
      aggregatedScore: aggregatedScore,
      allCategories: allCategories,
      totalProcessingTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  /// Calculate aggregated score from model results
  double _calculateAggregatedScore(double nsfw, double nudenet) {
    // Weight: NSFW = 1.0, NudeNet = 0.8
    final weightedNudenet = nudenet * 0.8;
    return nsfw > weightedNudenet ? nsfw : weightedNudenet;
  }

  /// Dispose all models
  Future<void> dispose() async {
    await Future.wait([
      nsfwDetector.dispose(),
      nudenetDetector.dispose(),
    ]);
    _isInitialized = false;
  }
}

/// Placeholder NSFW Detector (to be replaced with ONNX implementation)
class PlaceholderNSFWDetector implements AIDetector {
  bool _isReady = false;

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    // TODO: Load ONNX model
    await Future.delayed(const Duration(milliseconds: 100));
    _isReady = true;
  }

  @override
  Future<DetectionResult> analyze(Uint8List imageBytes) async {
    // TODO: Run actual inference
    // For now, return safe result
    return const DetectionResult(
      score: 0.0,
      modelName: 'OpenNSFW2',
      categories: {},
      processingTimeMs: 50,
    );
  }

  @override
  Future<void> dispose() async {
    _isReady = false;
  }
}

/// Placeholder NudeNet Detector (to be replaced with ONNX implementation)
class PlaceholderNudeNetDetector implements AIDetector {
  bool _isReady = false;

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    // TODO: Load ONNX model
    await Future.delayed(const Duration(milliseconds: 100));
    _isReady = true;
  }

  @override
  Future<DetectionResult> analyze(Uint8List imageBytes) async {
    // TODO: Run actual inference
    // For now, return safe result
    return const DetectionResult(
      score: 0.0,
      modelName: 'NudeNet',
      categories: {},
      processingTimeMs: 50,
    );
  }

  @override
  Future<void> dispose() async {
    _isReady = false;
  }
}
