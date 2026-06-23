// Halal Player - Video Frame Extractor
//
// Extracts individual frames from a video file at a given timestamp
// using FFmpeg as a subprocess. This provides the raw image bytes
// that the AI engine then analyzes.

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Extracts video frames for AI analysis using FFmpeg
class VideoFrameExtractor {
  VideoFrameExtractor._();

  /// Check if FFmpeg is available on this system
  static Future<bool> isAvailable() async {
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Extract a single frame from [videoPath] at [position] as JPEG bytes.
  ///
  /// Returns `null` if FFmpeg is not available or extraction fails.
  static Future<Uint8List?> extractFrame(
    String videoPath,
    Duration position,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outPath = p.join(
        tempDir.path,
        'hp_frame_${position.inMilliseconds}.jpg',
      );

      final result = await Process.run('ffmpeg', [
        '-ss', _formatTimestamp(position), // Seek to position
        '-i', videoPath,                   // Input file
        '-vframes', '1',                   // Extract exactly one frame
        '-q:v', '3',                       // Quality (2=best, 5=ok)
        '-vf', 'scale=224:224',            // Resize to AI model input size
        '-y',                              // Overwrite output
        outPath,
      ]);

      if (result.exitCode == 0) {
        final file = File(outPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // Clean up temp file (fire-and-forget)
          file.delete().catchError((_) => file);
          return bytes;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Extract a frame as JPEG bytes at a specific percentage of total duration.
  static Future<Uint8List?> extractFrameAtPercent(
    String videoPath,
    double percent, {
    Duration? totalDuration,
  }) async {
    final duration = totalDuration ?? await _getDuration(videoPath);
    if (duration == null) return null;

    final position = Duration(
      milliseconds: (duration.inMilliseconds * percent.clamp(0, 1)).round(),
    );
    return extractFrame(videoPath, position);
  }

  /// Get the total duration of a video file using FFprobe.
  static Future<Duration?> _getDuration(String videoPath) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=noprint_wrappers=1:nokey=1',
        videoPath,
      ]);

      if (result.exitCode == 0) {
        final seconds = double.tryParse(result.stdout.toString().trim());
        if (seconds != null) {
          return Duration(milliseconds: (seconds * 1000).round());
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Format a Duration as HH:MM:SS.mmm for FFmpeg -ss flag
  static String _formatTimestamp(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}
