// Halal Player - Policy Engine
// 
// Decision engine for content filtering based on AI scores and user mode

import 'config.dart';

/// Actions that can be taken on content
enum ContentAction {
  allow,
  blur,
  block,
}

/// Result of policy evaluation
class PolicyResult {
  const PolicyResult({
    required this.action,
    required this.reason,
    required this.nsfwScore,
    required this.nudenetScore,
    required this.aggregatedScore,
    this.detectedCategories = const [],
  });

  final ContentAction action;
  final String reason;
  final double nsfwScore;
  final double nudenetScore;
  final double aggregatedScore;
  final List<String> detectedCategories;

  /// Create a safe/allowed result
  factory PolicyResult.allowed({
    required double nsfwScore,
    required double nudenetScore,
  }) {
    return PolicyResult(
      action: ContentAction.allow,
      reason: 'Content passed all safety checks',
      nsfwScore: nsfwScore,
      nudenetScore: nudenetScore,
      aggregatedScore: _aggregateScore(nsfwScore, nudenetScore),
    );
  }

  /// Calculate aggregated score
  static double _aggregateScore(double nsfw, double nudenet) {
    // Take the max, but weight nudenet slightly lower
    return nsfw > (nudenet * 0.8) ? nsfw : nudenet * 0.8;
  }

  @override
  String toString() {
    return 'PolicyResult(action: $action, score: ${aggregatedScore.toStringAsFixed(2)}, reason: $reason)';
  }
}

/// Policy Engine - decides what to do with content
class PolicyEngine {
  PolicyEngine(this.config);

  final AppConfig config;

  /// Blur margin - content is blurred if within this range of threshold
  static const double blurMargin = 0.15;

  /// Evaluate content based on AI scores
  PolicyResult evaluate({
    required double nsfwScore,
    required double nudenetScore,
    List<String> detectedCategories = const [],
  }) {
    // Calculate aggregated score
    final aggregatedScore = _calculateAggregatedScore(nsfwScore, nudenetScore);

    // Get threshold based on current mode
    final threshold = config.nsfwThreshold;

    // Determine action
    final ContentAction action;
    final String reason;

    if (aggregatedScore >= threshold) {
      // Above threshold - block
      action = ContentAction.block;
      reason = _generateBlockReason(aggregatedScore, detectedCategories);
    } else if (aggregatedScore >= threshold - blurMargin) {
      // Close to threshold - blur
      action = ContentAction.blur;
      reason = _generateBlurReason(aggregatedScore);
    } else {
      // Safe
      action = ContentAction.allow;
      reason = 'Content passed safety checks';
    }

    return PolicyResult(
      action: action,
      reason: reason,
      nsfwScore: nsfwScore,
      nudenetScore: nudenetScore,
      aggregatedScore: aggregatedScore,
      detectedCategories: detectedCategories,
    );
  }

  /// Calculate aggregated score from multiple AI models
  double _calculateAggregatedScore(double nsfw, double nudenet) {
    // Weight: NSFW = 1.0, NudeNet = 0.8
    // Take the maximum weighted score
    final weightedNudenet = nudenet * 0.8;
    return nsfw > weightedNudenet ? nsfw : weightedNudenet;
  }

  /// Generate reason for blocking
  String _generateBlockReason(double score, List<String> categories) {
    final buffer = StringBuffer();
    buffer.write('Content blocked (score: ${(score * 100).toStringAsFixed(1)}%)');

    if (categories.isNotEmpty) {
      buffer.write('. Detected: ${categories.join(", ")}');
    }

    return buffer.toString();
  }

  /// Generate reason for blurring
  String _generateBlurReason(double score) {
    return 'Content blurred for safety (score: ${(score * 100).toStringAsFixed(1)}%)';
  }

  /// Quick check if content should be analyzed
  /// Can be used to skip analysis for trusted sources
  bool shouldAnalyze(String? source) {
    // For now, always analyze
    // In future: whitelist support
    return true;
  }
}
