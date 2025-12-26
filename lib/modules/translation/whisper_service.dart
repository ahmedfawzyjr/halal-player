// Halal Player - Whisper STT Service
//
// Speech to Text using Whisper models
// Note: Requires whisper.cpp or Faster Whisper installed

import 'dart:io';
import 'dart:async';

import '../subtitles/subtitle_model.dart';
import '../subtitles/subtitle_parser.dart';

/// Whisper STT service interface
abstract class WhisperService {
  Future<SubtitleTrack> transcribe(
    String audioPath, {
    String? language,
    void Function(double progress)? onProgress,
  });
  Future<bool> isAvailable();
  Future<List<String>> getAvailableModels();
}

/// Whisper.cpp integration
/// Requires whisper.cpp installed and models downloaded
class WhisperCppService implements WhisperService {
  WhisperCppService({
    this.modelPath,
    this.whisperPath = 'whisper',
  });

  final String? modelPath;
  final String whisperPath;

  @override
  Future<SubtitleTrack> transcribe(
    String audioPath, {
    String? language,
    void Function(double progress)? onProgress,
  }) async {
    // This is a placeholder - actual implementation would call whisper.cpp
    // through Process.run()
    
    final tempOutputPath = '${audioPath}_transcript.srt';
    
    try {
      // Command example:
      // whisper.cpp -m model.bin -f audio.wav -osrt -of output
      final result = await Process.run(
        whisperPath,
        [
          '-m', modelPath ?? 'models/ggml-base.bin',
          '-f', audioPath,
          '-osrt',
          '-of', audioPath.replaceFirst(RegExp(r'\.[^.]+$'), ''),
          if (language != null) ...['-l', language],
        ],
      );

      if (result.exitCode == 0 && await File(tempOutputPath).exists()) {
        return await SubtitleParser.parseFile(tempOutputPath);
      }
      
      return const SubtitleTrack(entries: []);
    } catch (e) {
      return const SubtitleTrack(entries: []);
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run(whisperPath, ['--help']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableModels() async {
    // Common Whisper model sizes
    return ['tiny', 'base', 'small', 'medium', 'large'];
  }
}

/// Python Whisper integration (via subprocess)
class PythonWhisperService implements WhisperService {
  PythonWhisperService({
    this.pythonPath = 'python',
    this.model = 'base',
  });

  final String pythonPath;
  final String model;

  @override
  Future<SubtitleTrack> transcribe(
    String audioPath, {
    String? language,
    void Function(double progress)? onProgress,
  }) async {
    final outputPath = '${audioPath.replaceFirst(RegExp(r'\.[^.]+$'), '')}.srt';
    
    try {
      // Python script to run whisper
      final script = '''
import whisper
model = whisper.load_model("$model")
result = model.transcribe("$audioPath"${language != null ? ', language="$language"' : ''})
# Generate SRT
with open("$outputPath", "w", encoding="utf-8") as f:
    for i, segment in enumerate(result["segments"]):
        start = segment["start"]
        end = segment["end"]
        text = segment["text"].strip()
        f.write(f"{i+1}\\n")
        f.write(f"{_format_time(start)} --> {_format_time(end)}\\n")
        f.write(f"{text}\\n\\n")

def _format_time(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    ms = int((seconds % 1) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"
''';
      
      final result = await Process.run(
        pythonPath,
        ['-c', script],
      );

      if (result.exitCode == 0 && await File(outputPath).exists()) {
        return await SubtitleParser.parseFile(outputPath);
      }
      
      return const SubtitleTrack(entries: []);
    } catch (e) {
      return const SubtitleTrack(entries: []);
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run(
        pythonPath,
        ['-c', 'import whisper; print("ok")'],
      );
      return result.exitCode == 0 && result.stdout.toString().contains('ok');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableModels() async {
    return ['tiny', 'base', 'small', 'medium', 'large', 'large-v3'];
  }
}

/// Audio extraction helper (uses FFmpeg)
class AudioExtractor {
  static Future<String?> extractAudio(
    String videoPath, {
    String? outputPath,
    String format = 'wav',
  }) async {
    final outPath = outputPath ?? '${videoPath.replaceFirst(RegExp(r'\.[^.]+$'), '')}.$format';
    
    try {
      final result = await Process.run(
        'ffmpeg',
        [
          '-i', videoPath,
          '-vn',                    // No video
          '-acodec', 'pcm_s16le',   // Audio codec
          '-ar', '16000',           // Sample rate
          '-ac', '1',               // Mono
          '-y',                     // Overwrite
          outPath,
        ],
      );

      if (result.exitCode == 0 && await File(outPath).exists()) {
        return outPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isFFmpegAvailable() async {
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}

/// Complete transcription pipeline
class TranscriptionPipeline {
  TranscriptionPipeline({
    required this.whisperService,
  });

  final WhisperService whisperService;

  /// Transcribe video to subtitles
  Future<SubtitleTrack?> transcribeVideo(
    String videoPath, {
    String? language,
    void Function(String status, double progress)? onProgress,
  }) async {
    onProgress?.call('Extracting audio...', 0.1);

    // Extract audio
    final audioPath = await AudioExtractor.extractAudio(videoPath);
    if (audioPath == null) {
      onProgress?.call('Failed to extract audio', 0);
      return null;
    }

    onProgress?.call('Transcribing...', 0.3);

    // Transcribe
    final track = await whisperService.transcribe(
      audioPath,
      language: language,
      onProgress: (p) => onProgress?.call('Transcribing...', 0.3 + p * 0.6),
    );

    // Cleanup temp audio
    try {
      await File(audioPath).delete();
    } catch (_) {}

    onProgress?.call('Done', 1.0);

    return track;
  }
}
