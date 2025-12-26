// Halal Player - Recent Files Service
//
// Tracks and displays recently opened media files

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Recent file entry
class RecentFile {
  const RecentFile({
    required this.path,
    required this.name,
    required this.type,
    required this.openedAt,
    this.thumbnailPath,
  });

  final String path;
  final String name;
  final String type; // 'video', 'audio', 'image'
  final DateTime openedAt;
  final String? thumbnailPath;

  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'type': type,
    'openedAt': openedAt.toIso8601String(),
    'thumbnailPath': thumbnailPath,
  };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
    path: json['path'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    openedAt: DateTime.parse(json['openedAt'] as String),
    thumbnailPath: json['thumbnailPath'] as String?,
  );
}

/// Recent files provider
final recentFilesProvider = NotifierProvider<RecentFilesNotifier, List<RecentFile>>(
  RecentFilesNotifier.new,
);

class RecentFilesNotifier extends Notifier<List<RecentFile>> {
  static const String _boxName = 'recent_files';
  static const int _maxRecentFiles = 20;

  @override
  List<RecentFile> build() {
    _loadFromStorage();
    return [];
  }

  Future<void> _loadFromStorage() async {
    try {
      final box = await Hive.openBox(_boxName);
      final List<dynamic> stored = box.get('files', defaultValue: []);
      
      final files = stored
          .map((e) => RecentFile.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      
      files.sort((a, b) => b.openedAt.compareTo(a.openedAt));
      state = files;
    } catch (e) {
      state = [];
    }
  }

  Future<void> addFile(String path, String name, String type) async {
    // Remove if already exists
    final filtered = state.where((f) => f.path != path).toList();
    
    // Add to beginning
    final newFile = RecentFile(
      path: path,
      name: name,
      type: type,
      openedAt: DateTime.now(),
    );
    
    filtered.insert(0, newFile);
    
    // Keep only max files
    if (filtered.length > _maxRecentFiles) {
      filtered.removeRange(_maxRecentFiles, filtered.length);
    }
    
    state = filtered;
    await _saveToStorage();
  }

  Future<void> removeFile(String path) async {
    state = state.where((f) => f.path != path).toList();
    await _saveToStorage();
  }

  Future<void> clearAll() async {
    state = [];
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put('files', state.map((f) => f.toJson()).toList());
    } catch (_) {}
  }
}

/// Recent Files Widget
class RecentFilesWidget extends ConsumerWidget {
  const RecentFilesWidget({
    super.key,
    this.onFileTap,
    this.maxItems = 5,
  });

  final void Function(RecentFile)? onFileTap;
  final int maxItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(recentFilesProvider);
    
    if (files.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_open,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No recent files',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayFiles = files.take(maxItems).toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Files',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (files.length > maxItems)
                  TextButton(
                    onPressed: () {
                      // Show all files dialog
                    },
                    child: const Text('See all'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...displayFiles.map((file) => ListTile(
            leading: _getFileIcon(file.type),
            title: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _formatDate(file.openedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                ref.read(recentFilesProvider.notifier).removeFile(file.path);
              },
            ),
            onTap: () => onFileTap?.call(file),
          )),
        ],
      ),
    );
  }

  Widget _getFileIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'video':
        icon = Icons.videocam;
        color = Colors.blue;
        break;
      case 'audio':
        icon = Icons.audiotrack;
        color = Colors.purple;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.green;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}
