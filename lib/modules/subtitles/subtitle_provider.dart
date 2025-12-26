// Halal Player - Subtitle Provider
//
// State management for subtitles

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'subtitle_model.dart';
import 'subtitle_parser.dart';
import 'opensubtitles_api.dart';

/// Subtitle settings provider
final subtitleSettingsProvider = NotifierProvider<SubtitleSettingsNotifier, SubtitleSettings>(
  SubtitleSettingsNotifier.new,
);

class SubtitleSettings {
  const SubtitleSettings({
    this.enabled = true,
    this.style = const SubtitleStyle(),
    this.preferredLanguage = 'en',
    this.autoDownload = true,
    this.islamicFilter = false,
  });

  final bool enabled;
  final SubtitleStyle style;
  final String preferredLanguage;
  final bool autoDownload;
  final bool islamicFilter;

  SubtitleSettings copyWith({
    bool? enabled,
    SubtitleStyle? style,
    String? preferredLanguage,
    bool? autoDownload,
    bool? islamicFilter,
  }) {
    return SubtitleSettings(
      enabled: enabled ?? this.enabled,
      style: style ?? this.style,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      autoDownload: autoDownload ?? this.autoDownload,
      islamicFilter: islamicFilter ?? this.islamicFilter,
    );
  }
}

class SubtitleSettingsNotifier extends Notifier<SubtitleSettings> {
  static const String _storageKey = 'subtitle_settings';

  @override
  SubtitleSettings build() {
    _loadFromStorage();
    return const SubtitleSettings();
  }

  Future<void> _loadFromStorage() async {
    try {
      final box = await Hive.openBox('halal_player');
      final data = box.get(_storageKey) as Map?;
      if (data != null) {
        state = SubtitleSettings(
          enabled: data['enabled'] ?? true,
          preferredLanguage: data['preferredLanguage'] ?? 'en',
          autoDownload: data['autoDownload'] ?? true,
          islamicFilter: data['islamicFilter'] ?? false,
          style: SubtitleStyle(
            fontSize: (data['fontSize'] ?? 20.0).toDouble(),
            position: SubtitlePosition.values[data['position'] ?? 2],
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final box = await Hive.openBox('halal_player');
      await box.put(_storageKey, {
        'enabled': state.enabled,
        'preferredLanguage': state.preferredLanguage,
        'autoDownload': state.autoDownload,
        'islamicFilter': state.islamicFilter,
        'fontSize': state.style.fontSize,
        'position': state.style.position.index,
      });
    } catch (_) {}
  }

  void setEnabled(bool value) {
    state = state.copyWith(enabled: value);
    _saveToStorage();
  }

  void setStyle(SubtitleStyle style) {
    state = state.copyWith(style: style);
    _saveToStorage();
  }

  void setPreferredLanguage(String lang) {
    state = state.copyWith(preferredLanguage: lang);
    _saveToStorage();
  }

  void setAutoDownload(bool value) {
    state = state.copyWith(autoDownload: value);
    _saveToStorage();
  }

  void setIslamicFilter(bool value) {
    state = state.copyWith(islamicFilter: value);
    _saveToStorage();
  }
}

/// Current subtitle track - using simple notifier for mutable state
class SubtitleTrackNotifier extends Notifier<SubtitleTrack?> {
  @override
  SubtitleTrack? build() => null;
  
  void setTrack(SubtitleTrack? track) {
    state = track;
  }
}

final currentSubtitleProvider = NotifierProvider<SubtitleTrackNotifier, SubtitleTrack?>(
  SubtitleTrackNotifier.new,
);

/// Subtitle loading state
enum SubtitleLoadingState {
  idle,
  loading,
  loaded,
  error,
  notFound,
}

class SubtitleLoadingNotifier extends Notifier<SubtitleLoadingState> {
  @override
  SubtitleLoadingState build() => SubtitleLoadingState.idle;
  
  void setState(SubtitleLoadingState newState) {
    state = newState;
  }
}

final subtitleLoadingStateProvider = NotifierProvider<SubtitleLoadingNotifier, SubtitleLoadingState>(
  SubtitleLoadingNotifier.new,
);

/// OpenSubtitles API provider
final openSubtitlesProvider = Provider<OpenSubtitlesAPI>((ref) {
  // Note: API key should be configured in settings
  return OpenSubtitlesAPI();
});

/// Subtitle download manager provider
final subtitleDownloadManagerProvider = Provider<SubtitleDownloadManager>((ref) {
  final api = ref.watch(openSubtitlesProvider);
  return SubtitleDownloadManager(api: api);
});

/// Load subtitle for a video file
Future<SubtitleTrack?> loadSubtitleForVideo(
  WidgetRef ref,
  String videoPath,
) async {
  final settings = ref.read(subtitleSettingsProvider);
  
  ref.read(subtitleLoadingStateProvider.notifier).setState(SubtitleLoadingState.loading);

  try {
    // First check for local subtitle files
    final localPath = await _findLocalSubtitle(videoPath);
    if (localPath != null) {
      final track = await SubtitleParser.parseFile(localPath);
      ref.read(currentSubtitleProvider.notifier).setTrack(track);
      ref.read(subtitleLoadingStateProvider.notifier).setState(SubtitleLoadingState.loaded);
      return track;
    }

    // Auto-download if enabled
    if (settings.autoDownload) {
      final downloadManager = ref.read(subtitleDownloadManagerProvider);
      final downloadedPath = await downloadManager.findAndDownload(
        videoPath,
        preferredLanguage: settings.preferredLanguage,
      );

      if (downloadedPath != null) {
        final track = await SubtitleParser.parseFile(downloadedPath);
        ref.read(currentSubtitleProvider.notifier).setTrack(track);
        ref.read(subtitleLoadingStateProvider.notifier).setState(SubtitleLoadingState.loaded);
        return track;
      }
    }

    ref.read(subtitleLoadingStateProvider.notifier).setState(SubtitleLoadingState.notFound);
    return null;
  } catch (e) {
    ref.read(subtitleLoadingStateProvider.notifier).setState(SubtitleLoadingState.error);
    return null;
  }
}

/// Find local subtitle file next to video
Future<String?> _findLocalSubtitle(String videoPath) async {
  final basePath = videoPath.replaceFirst(RegExp(r'\.[^.]+$'), '');
  
  for (final ext in ['srt', 'vtt', 'ass', 'ssa']) {
    final subPath = '$basePath.$ext';
    if (await File(subPath).exists()) {
      return subPath;
    }
  }
  
  return null;
}

/// Islamic profanity filter for subtitles
class IslamicSubtitleFilter {
  static const List<String> _blockedWords = [
    // Add profanity and inappropriate words here
    // This is a placeholder - should be configured
  ];

  static String filter(String text) {
    var filtered = text;
    for (final word in _blockedWords) {
      filtered = filtered.replaceAll(
        RegExp(word, caseSensitive: false),
        '***',
      );
    }
    return filtered;
  }

  static SubtitleTrack filterTrack(SubtitleTrack track) {
    return SubtitleTrack(
      entries: track.entries.map((e) => SubtitleEntry(
        index: e.index,
        start: e.start,
        end: e.end,
        text: filter(e.text),
      )).toList(),
      language: track.language,
      title: track.title,
    );
  }
}
