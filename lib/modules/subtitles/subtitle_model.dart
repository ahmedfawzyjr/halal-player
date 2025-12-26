// Halal Player - Subtitle Model
//
// Data models for subtitle entries and tracks

import 'package:flutter/material.dart';

/// Single subtitle entry with timing
class SubtitleEntry {
  const SubtitleEntry({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
    this.style,
  });

  final int index;
  final Duration start;
  final Duration end;
  final String text;
  final TextStyle? style;

  /// Check if this entry should be shown at given time
  bool isActiveAt(Duration position) {
    return position >= start && position <= end;
  }

  /// Duration of this subtitle
  Duration get duration => end - start;

  @override
  String toString() => 'SubtitleEntry($index: $start -> $end: $text)';
}

/// Subtitle track containing all entries
class SubtitleTrack {
  const SubtitleTrack({
    required this.entries,
    this.language,
    this.title,
    this.isDefault = false,
  });

  final List<SubtitleEntry> entries;
  final String? language;
  final String? title;
  final bool isDefault;

  /// Get active subtitle at position
  SubtitleEntry? getActiveEntry(Duration position) {
    for (final entry in entries) {
      if (entry.isActiveAt(position)) {
        return entry;
      }
    }
    return null;
  }

  /// Check if track has entries
  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  /// Total count of entries
  int get length => entries.length;

  /// Total duration of subtitles
  Duration get totalDuration {
    if (entries.isEmpty) return Duration.zero;
    return entries.last.end;
  }
}

/// Subtitle format enum
enum SubtitleFormat {
  srt,
  vtt,
  ass,
  unknown,
}

/// Detect subtitle format from file extension
SubtitleFormat detectFormat(String path) {
  final ext = path.split('.').last.toLowerCase();
  switch (ext) {
    case 'srt':
      return SubtitleFormat.srt;
    case 'vtt':
    case 'webvtt':
      return SubtitleFormat.vtt;
    case 'ass':
    case 'ssa':
      return SubtitleFormat.ass;
    default:
      return SubtitleFormat.unknown;
  }
}

/// Subtitle style settings
class SubtitleStyle {
  const SubtitleStyle({
    this.fontSize = 20.0,
    this.fontColor = Colors.white,
    this.backgroundColor = Colors.black54,
    this.fontFamily,
    this.position = SubtitlePosition.bottom,
    this.outlineColor = Colors.black,
    this.outlineWidth = 1.5,
  });

  final double fontSize;
  final Color fontColor;
  final Color backgroundColor;
  final String? fontFamily;
  final SubtitlePosition position;
  final Color outlineColor;
  final double outlineWidth;

  SubtitleStyle copyWith({
    double? fontSize,
    Color? fontColor,
    Color? backgroundColor,
    String? fontFamily,
    SubtitlePosition? position,
    Color? outlineColor,
    double? outlineWidth,
  }) {
    return SubtitleStyle(
      fontSize: fontSize ?? this.fontSize,
      fontColor: fontColor ?? this.fontColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      position: position ?? this.position,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
    );
  }

  TextStyle toTextStyle() {
    return TextStyle(
      fontSize: fontSize,
      color: fontColor,
      fontFamily: fontFamily,
      shadows: [
        Shadow(
          color: outlineColor,
          blurRadius: outlineWidth,
          offset: const Offset(1, 1),
        ),
        Shadow(
          color: outlineColor,
          blurRadius: outlineWidth,
          offset: const Offset(-1, -1),
        ),
      ],
    );
  }
}

/// Subtitle position on screen
enum SubtitlePosition {
  top,
  center,
  bottom,
}
