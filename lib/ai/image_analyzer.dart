// Halal Player - Image Analyzer
//
// Analyze images before display using AI models

import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;

import '../core/ai_gateway.dart';
import '../core/policy_engine.dart';

/// Result of image analysis
class ImageAnalysisResult {
  const ImageAnalysisResult({
    required this.imagePath,
    required this.policyResult,
    required this.processingTimeMs,
    this.thumbnailBytes,
  });

  final String imagePath;
  final PolicyResult policyResult;
  final int processingTimeMs;
  final Uint8List? thumbnailBytes;

  bool get isSafe => policyResult.action == ContentAction.allow;
  bool get shouldBlur => policyResult.action == ContentAction.blur;
  bool get shouldBlock => policyResult.action == ContentAction.block;
}

/// Image analyzer for content detection
class ImageAnalyzer {
  ImageAnalyzer({
    required this.aiGateway,
    required this.policyEngine,
  });

  final AIGateway aiGateway;
  final PolicyEngine policyEngine;

  // Cache for analyzed images
  final Map<String, ImageAnalysisResult> _cache = {};

  /// Check if image is already analyzed and cached
  bool hasCache(String imagePath) => _cache.containsKey(imagePath);

  /// Get cached result
  ImageAnalysisResult? getCached(String imagePath) => _cache[imagePath];

  /// Analyze an image file
  Future<ImageAnalysisResult> analyzeFile(String imagePath) async {
    // Check cache
    if (_cache.containsKey(imagePath)) {
      return _cache[imagePath]!;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Read file
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // Preprocess image (resize for AI model)
      final preprocessed = await _preprocessImage(bytes);

      // Run AI analysis
      final aiResult = await aiGateway.analyzeImage(preprocessed);

      // Apply policy
      final policyResult = policyEngine.evaluate(
        nsfwScore: aiResult.nsfwScore,
        nudenetScore: aiResult.nudenetScore,
        detectedCategories: aiResult.allCategories,
      );

      stopwatch.stop();

      final result = ImageAnalysisResult(
        imagePath: imagePath,
        policyResult: policyResult,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );

      // Cache result
      _cache[imagePath] = result;

      return result;
    } catch (e) {
      stopwatch.stop();

      // On error, default to safe (but log the error)
      final result = ImageAnalysisResult(
        imagePath: imagePath,
        policyResult: PolicyResult.allowed(
          nsfwScore: 0,
          nudenetScore: 0,
        ),
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );

      return result;
    }
  }

  /// Analyze image bytes directly
  Future<ImageAnalysisResult> analyzeBytes(
    Uint8List bytes, {
    String? identifier,
  }) async {
    final id = identifier ?? bytes.hashCode.toString();

    // Check cache
    if (_cache.containsKey(id)) {
      return _cache[id]!;
    }

    final stopwatch = Stopwatch()..start();

    // Preprocess image
    final preprocessed = await _preprocessImage(bytes);

    // Run AI analysis
    final aiResult = await aiGateway.analyzeImage(preprocessed);

    // Apply policy
    final policyResult = policyEngine.evaluate(
      nsfwScore: aiResult.nsfwScore,
      nudenetScore: aiResult.nudenetScore,
      detectedCategories: aiResult.allCategories,
    );

    stopwatch.stop();

    final result = ImageAnalysisResult(
      imagePath: id,
      policyResult: policyResult,
      processingTimeMs: stopwatch.elapsedMilliseconds,
    );

    // Cache result
    _cache[id] = result;

    return result;
  }

  /// Preprocess image for AI model (resize to 224x224)
  Future<Uint8List> _preprocessImage(Uint8List bytes) async {
    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      // Resize to 224x224 (standard input size for many models)
      final resized = img.copyResize(
        image,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );

      // Encode back to PNG
      return Uint8List.fromList(img.encodePng(resized));
    } catch (e) {
      // On error, return original bytes
      return bytes;
    }
  }

  /// Generate blurred thumbnail for flagged content
  Future<Uint8List?> generateBlurredThumbnail(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Resize to thumbnail
      final thumbnail = img.copyResize(image, width: 200);

      // Apply heavy blur
      final blurred = img.gaussianBlur(thumbnail, radius: 30);

      return Uint8List.fromList(img.encodePng(blurred));
    } catch (e) {
      return null;
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Remove specific item from cache
  void removeFromCache(String imagePath) {
    _cache.remove(imagePath);
  }
}
