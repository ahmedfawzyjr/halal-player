// Halal Player - Waveform Painter
//
// CustomPainter that renders a waveform bar visualisation.
// The bars animate: active (played) portion is green, remaining is dim.

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  const WaveformPainter({
    required this.waveData,
    required this.progress,
    this.activeColor = Colors.green,
    this.inactiveColor = const Color(0x40FFFFFF),
    this.barWidth = 4.0,
    this.barSpacing = 2.0,
  });

  /// Normalised heights, each in [0, 1].
  final List<double> waveData;

  /// Playback progress in [0, 1].
  final double progress;

  final Color activeColor;
  final Color inactiveColor;
  final double barWidth;
  final double barSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    if (waveData.isEmpty) return;

    final totalBarWidth = barWidth + barSpacing;
    final barCount = (size.width / totalBarWidth).floor();
    final actualCount = barCount.clamp(1, waveData.length);

    for (int i = 0; i < actualCount; i++) {
      final ratio = waveData[i % waveData.length];
      final barHeight = (ratio * size.height * 0.85).clamp(4.0, size.height);
      final x = i * totalBarWidth;
      final y = (size.height - barHeight) / 2;

      final isActive = (i / actualCount) <= progress;

      final paint = Paint()
        ..color = isActive ? activeColor : inactiveColor
        ..strokeCap = StrokeCap.round;

      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter old) =>
      old.progress != progress ||
      old.waveData != waveData ||
      old.activeColor != activeColor;
}

/// A waveform widget that animates with playback progress.
class AnimatedWaveform extends StatelessWidget {
  const AnimatedWaveform({
    super.key,
    required this.waveData,
    required this.progress,
    this.height = 80,
    this.activeColor = Colors.green,
    this.inactiveColor = const Color(0x40FFFFFF),
  });

  final List<double> waveData;
  final double progress;
  final double height;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: WaveformPainter(
          waveData: waveData,
          progress: progress,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}
