// Halal Player - Blur/Block Actions
//
// UI components for blurring and blocking content

import 'package:flutter/material.dart';

/// Blur overlay widget for flagged content
class BlurOverlay extends StatelessWidget {
  const BlurOverlay({
    super.key,
    required this.child,
    this.isBlurred = false,
    this.blurIntensity = 20.0,
    this.onShowContent,
    this.warningMessage,
  });

  final Widget child;
  final bool isBlurred;
  final double blurIntensity;
  final VoidCallback? onShowContent;
  final String? warningMessage;

  @override
  Widget build(BuildContext context) {
    if (!isBlurred) return child;

    return Stack(
      children: [
        // Blurred content (placeholder - actual blur requires ImageFilter)
        Container(
          color: Colors.black,
          child: Center(
            child: Icon(
              Icons.visibility_off,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
        
        // Warning overlay
        Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Content Flagged',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  warningMessage ?? 'AI detected potentially inappropriate content',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                if (onShowContent != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: const Text('Go Back'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: onShowContent,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.8),
                        ),
                        child: const Text('View Anyway'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Block screen for completely blocked content
class BlockedContentScreen extends StatelessWidget {
  const BlockedContentScreen({
    super.key,
    this.reason,
    this.confidenceScore,
    this.onGoBack,
  });

  final String? reason;
  final double? confidenceScore;
  final VoidCallback? onGoBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(48),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Content Blocked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                reason ?? 'This content has been blocked by AI safety filters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              if (confidenceScore != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Confidence: ${(confidenceScore! * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onGoBack ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, color: Colors.green[300], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Your privacy is protected - this was analyzed locally',
                      style: TextStyle(color: Colors.green[300], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AI Status indicator widget
class AIStatusIndicator extends StatelessWidget {
  const AIStatusIndicator({
    super.key,
    this.isAnalyzing = false,
    this.isSafe,
    this.compact = false,
  });

  final bool isAnalyzing;
  final bool? isSafe;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (isAnalyzing) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: compact ? 12 : 14,
              height: compact ? 12 : 14,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              const Text(
                'Analyzing...',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ],
          ],
        ),
      );
    }

    final color = isSafe == true ? Colors.green : Colors.red;
    final icon = isSafe == true ? Icons.check_circle : Icons.warning;
    final text = isSafe == true ? 'Safe' : 'Flagged';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: compact ? 12 : 14),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// Analysis explanation dialog
class AnalysisExplanationDialog extends StatelessWidget {
  const AnalysisExplanationDialog({
    super.key,
    required this.nsfwScore,
    required this.nudenetScore,
    required this.categories,
    required this.reason,
    required this.threshold,
  });

  final double nsfwScore;
  final double nudenetScore;
  final List<String> categories;
  final String reason;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('AI Analysis Details'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reason),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildScoreRow('NSFW Score', nsfwScore),
          const SizedBox(height: 8),
          _buildScoreRow('NudeNet Score', nudenetScore),
          const SizedBox(height: 8),
          _buildScoreRow('Threshold', threshold, showBar: false),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Detected Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                return Chip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, double score, {bool showBar = true}) {
    final color = score > 0.7
        ? Colors.red
        : score > 0.4
            ? Colors.orange
            : Colors.green;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label),
        ),
        if (showBar)
          Expanded(
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey[800],
              color: color,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          '${(score * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
