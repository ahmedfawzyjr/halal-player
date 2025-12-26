// Halal Player - Recent Files Manager
//
// Manage and persist recent media files

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Recent file entry
class RecentFile {
  RecentFile({
    required this.path,
    required this.name,
    required this.type,
    required this.lastOpened,
    this.thumbnail,
    this.duration,
  });

  final String path;
  final String name;
  final MediaType type;
  final DateTime lastOpened;
  final String? thumbnail;
  final Duration? duration;

  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'type': type.name,
    'lastOpened': lastOpened.toIso8601String(),
    'thumbnail': thumbnail,
    'duration': duration?.inMilliseconds,
  };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
    path: json['path'] as String,
    name: json['name'] as String,
    type: MediaType.values.firstWhere((e) => e.name == json['type']),
    lastOpened: DateTime.parse(json['lastOpened'] as String),
    thumbnail: json['thumbnail'] as String?,
    duration: json['duration'] != null 
        ? Duration(milliseconds: json['duration'] as int) 
        : null,
  );
}

/// Media type enum
enum MediaType {
  video,
  audio,
  image,
}

extension MediaTypeExtension on MediaType {
  String get label {
    switch (this) {
      case MediaType.video: return 'Video';
      case MediaType.audio: return 'Audio';
      case MediaType.image: return 'Image';
    }
  }

  List<String> get extensions {
    switch (this) {
      case MediaType.video:
        return ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm'];
      case MediaType.audio:
        return ['mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg', 'wma'];
      case MediaType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    }
  }
}

/// Get media type from file path
MediaType? getMediaType(String path) {
  final extension = path.split('.').last.toLowerCase();
  for (final type in MediaType.values) {
    if (type.extensions.contains(extension)) {
      return type;
    }
  }
  return null;
}

/// Recent files provider
final recentFilesProvider = NotifierProvider<RecentFilesNotifier, List<RecentFile>>(
  RecentFilesNotifier.new,
);

class RecentFilesNotifier extends Notifier<List<RecentFile>> {
  static const String _storageKey = 'recent_files';
  static const int _maxRecentFiles = 50;

  @override
  List<RecentFile> build() {
    _loadFromStorage();
    return [];
  }

  /// Load recent files from storage
  Future<void> _loadFromStorage() async {
    try {
      final box = await Hive.openBox('halal_player');
      final jsonList = box.get(_storageKey) as List<dynamic>?;
      if (jsonList != null) {
        state = jsonList
            .map((e) => RecentFile.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      // Handle storage errors gracefully
      state = [];
    }
  }

  /// Save to storage
  Future<void> _saveToStorage() async {
    try {
      final box = await Hive.openBox('halal_player');
      await box.put(_storageKey, state.map((e) => e.toJson()).toList());
    } catch (e) {
      // Handle storage errors
    }
  }

  /// Add a file to recent list
  void addFile({
    required String path,
    required MediaType type,
    Duration? duration,
  }) {
    // Remove if already exists
    final existing = state.where((f) => f.path == path).toList();
    for (final file in existing) {
      state = state.where((f) => f.path != file.path).toList();
    }

    // Extract file name
    final name = path.split('/').last.split('\\').last;

    // Add to beginning
    final newFile = RecentFile(
      path: path,
      name: name,
      type: type,
      lastOpened: DateTime.now(),
      duration: duration,
    );

    state = [newFile, ...state];

    // Limit to max files
    if (state.length > _maxRecentFiles) {
      state = state.sublist(0, _maxRecentFiles);
    }

    _saveToStorage();
  }

  /// Remove a file from recent list
  void removeFile(String path) {
    state = state.where((f) => f.path != path).toList();
    _saveToStorage();
  }

  /// Clear all recent files
  void clearAll() {
    state = [];
    _saveToStorage();
  }

  /// Get files by type
  List<RecentFile> getByType(MediaType type) {
    return state.where((f) => f.type == type).toList();
  }
}
