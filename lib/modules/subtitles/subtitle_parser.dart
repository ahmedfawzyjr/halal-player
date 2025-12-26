// Halal Player - Subtitle Parser
//
// Parse SRT, VTT, and ASS subtitle files

import 'dart:io';
import 'subtitle_model.dart';

/// Main subtitle parser class
class SubtitleParser {
  /// Parse subtitle file from path
  static Future<SubtitleTrack> parseFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Subtitle file not found: $path');
    }
    
    final content = await file.readAsString();
    final format = detectFormat(path);
    
    return parseContent(content, format);
  }

  /// Parse subtitle content with known format
  static SubtitleTrack parseContent(String content, SubtitleFormat format) {
    switch (format) {
      case SubtitleFormat.srt:
        return _parseSRT(content);
      case SubtitleFormat.vtt:
        return _parseVTT(content);
      case SubtitleFormat.ass:
        return _parseASS(content);
      default:
        // Try SRT as default
        return _parseSRT(content);
    }
  }

  /// Parse SRT format
  static SubtitleTrack _parseSRT(String content) {
    final entries = <SubtitleEntry>[];
    final blocks = content.trim().split(RegExp(r'\n\s*\n'));
    
    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;
      
      // Parse index
      final index = int.tryParse(lines[0].trim()) ?? entries.length + 1;
      
      // Parse timing line: 00:00:00,000 --> 00:00:00,000
      final timingLine = lines[1].trim();
      final timingMatch = RegExp(
        r'(\d{2}):(\d{2}):(\d{2})[,.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,.](\d{3})'
      ).firstMatch(timingLine);
      
      if (timingMatch == null) continue;
      
      final start = Duration(
        hours: int.parse(timingMatch.group(1)!),
        minutes: int.parse(timingMatch.group(2)!),
        seconds: int.parse(timingMatch.group(3)!),
        milliseconds: int.parse(timingMatch.group(4)!),
      );
      
      final end = Duration(
        hours: int.parse(timingMatch.group(5)!),
        minutes: int.parse(timingMatch.group(6)!),
        seconds: int.parse(timingMatch.group(7)!),
        milliseconds: int.parse(timingMatch.group(8)!),
      );
      
      // Parse text (remaining lines)
      final text = lines.sublist(2).join('\n').trim();
      
      // Remove HTML tags
      final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '');
      
      entries.add(SubtitleEntry(
        index: index,
        start: start,
        end: end,
        text: cleanText,
      ));
    }
    
    return SubtitleTrack(entries: entries);
  }

  /// Parse VTT (WebVTT) format
  static SubtitleTrack _parseVTT(String content) {
    final entries = <SubtitleEntry>[];
    
    // Remove WEBVTT header
    var cleanContent = content;
    if (content.startsWith('WEBVTT')) {
      cleanContent = content.substring(content.indexOf('\n') + 1);
    }
    
    final blocks = cleanContent.trim().split(RegExp(r'\n\s*\n'));
    var index = 0;
    
    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;
      
      // Find timing line
      var timingLineIndex = 0;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('-->')) {
          timingLineIndex = i;
          break;
        }
      }
      
      if (timingLineIndex >= lines.length) continue;
      
      // Parse timing: 00:00:00.000 --> 00:00:00.000
      final timingLine = lines[timingLineIndex].trim();
      final timingMatch = RegExp(
        r'(\d{2}):(\d{2}):(\d{2})[.,](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[.,](\d{3})'
      ).firstMatch(timingLine);
      
      // Also support MM:SS.mmm format
      final shortTimingMatch = timingMatch ?? RegExp(
        r'(\d{2}):(\d{2})[.,](\d{3})\s*-->\s*(\d{2}):(\d{2})[.,](\d{3})'
      ).firstMatch(timingLine);
      
      if (shortTimingMatch == null && timingMatch == null) continue;
      
      Duration start, end;
      
      if (timingMatch != null) {
        start = Duration(
          hours: int.parse(timingMatch.group(1)!),
          minutes: int.parse(timingMatch.group(2)!),
          seconds: int.parse(timingMatch.group(3)!),
          milliseconds: int.parse(timingMatch.group(4)!),
        );
        end = Duration(
          hours: int.parse(timingMatch.group(5)!),
          minutes: int.parse(timingMatch.group(6)!),
          seconds: int.parse(timingMatch.group(7)!),
          milliseconds: int.parse(timingMatch.group(8)!),
        );
      } else {
        start = Duration(
          minutes: int.parse(shortTimingMatch!.group(1)!),
          seconds: int.parse(shortTimingMatch.group(2)!),
          milliseconds: int.parse(shortTimingMatch.group(3)!),
        );
        end = Duration(
          minutes: int.parse(shortTimingMatch.group(4)!),
          seconds: int.parse(shortTimingMatch.group(5)!),
          milliseconds: int.parse(shortTimingMatch.group(6)!),
        );
      }
      
      // Parse text
      final text = lines.sublist(timingLineIndex + 1).join('\n').trim();
      final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '');
      
      index++;
      entries.add(SubtitleEntry(
        index: index,
        start: start,
        end: end,
        text: cleanText,
      ));
    }
    
    return SubtitleTrack(entries: entries);
  }

  /// Parse ASS/SSA format (basic support)
  static SubtitleTrack _parseASS(String content) {
    final entries = <SubtitleEntry>[];
    var index = 0;
    
    final lines = content.split('\n');
    
    for (final line in lines) {
      // Look for Dialogue lines
      if (!line.startsWith('Dialogue:')) continue;
      
      // Format: Dialogue: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
      final parts = line.substring(10).split(',');
      if (parts.length < 10) continue;
      
      final startStr = parts[1].trim();
      final endStr = parts[2].trim();
      final text = parts.sublist(9).join(',').trim();
      
      // Parse timing: H:MM:SS.CC
      final start = _parseASSTime(startStr);
      final end = _parseASSTime(endStr);
      
      if (start == null || end == null) continue;
      
      // Remove ASS style tags {\...}
      final cleanText = text.replaceAll(RegExp(r'\{[^}]*\}'), '');
      
      index++;
      entries.add(SubtitleEntry(
        index: index,
        start: start,
        end: end,
        text: cleanText.replaceAll('\\N', '\n'),
      ));
    }
    
    return SubtitleTrack(entries: entries);
  }

  /// Parse ASS time format (H:MM:SS.CC)
  static Duration? _parseASSTime(String time) {
    final match = RegExp(r'(\d+):(\d{2}):(\d{2})[.,](\d{2})').firstMatch(time);
    if (match == null) return null;
    
    return Duration(
      hours: int.parse(match.group(1)!),
      minutes: int.parse(match.group(2)!),
      seconds: int.parse(match.group(3)!),
      milliseconds: int.parse(match.group(4)!) * 10,
    );
  }
}

/// Generate SRT content from subtitle track
String generateSRT(SubtitleTrack track) {
  final buffer = StringBuffer();
  
  for (final entry in track.entries) {
    buffer.writeln(entry.index);
    buffer.writeln('${_formatSRTTime(entry.start)} --> ${_formatSRTTime(entry.end)}');
    buffer.writeln(entry.text);
    buffer.writeln();
  }
  
  return buffer.toString();
}

String _formatSRTTime(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
  
  return '$hours:$minutes:$seconds,$milliseconds';
}

/// Generate VTT content from subtitle track
String generateVTT(SubtitleTrack track) {
  final buffer = StringBuffer();
  buffer.writeln('WEBVTT');
  buffer.writeln();
  
  for (final entry in track.entries) {
    buffer.writeln('${_formatVTTTime(entry.start)} --> ${_formatVTTTime(entry.end)}');
    buffer.writeln(entry.text);
    buffer.writeln();
  }
  
  return buffer.toString();
}

String _formatVTTTime(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
  
  return '$hours:$minutes:$seconds.$milliseconds';
}
