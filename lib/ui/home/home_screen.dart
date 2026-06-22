// Halal Player - Home Screen
//
// Main dashboard wired to real Riverpod state:
//  • Recent Files list from recentFilesProvider — tapping opens the right player
//  • Quick Action cards use FilePicker and navigate to the matching player screen

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/audio_player/audio_player_screen.dart';
import '../../modules/image_viewer/image_viewer_screen.dart';
import '../../modules/video_player/video_player_screen.dart';
import '../../services/recent_files.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFiles = ref.watch(recentFilesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          _buildWelcomeBanner(context),
          const SizedBox(height: 32),

          // Quick Actions
          _buildSectionHeader(context, 'Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActions(context, ref),
          const SizedBox(height: 32),

          // Recent Files
          _buildSectionHeader(context, 'Recent Files',
              trailing: recentFiles.isNotEmpty
                  ? TextButton(
                      onPressed: () =>
                          ref.read(recentFilesProvider.notifier).clearAll(),
                      child: const Text('Clear All',
                          style: TextStyle(color: Colors.red)),
                    )
                  : null),
          const SizedBox(height: 16),
          Expanded(child: _buildRecentFiles(context, ref, recentFiles)),
        ],
      ),
    );
  }

  // ── Welcome banner ────────────────────────────────────────────────────────────

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, size: 48, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Halal Player',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Privacy-first media player with AI content protection',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green[100]),
                const SizedBox(width: 4),
                Text(
                  'Protected',
                  style: TextStyle(
                      color: Colors.green[100],
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title,
      {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.videocam,
            title: 'Open Video',
            subtitle: 'Play with AI protection',
            color: Colors.blue,
            onTap: () => _pickAndOpen(context, ref, FileType.video),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.audiotrack,
            title: 'Open Audio',
            subtitle: 'Listen safely',
            color: Colors.purple,
            onTap: () => _pickAndOpen(context, ref, FileType.audio),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.image,
            title: 'View Image',
            subtitle: 'AI-scanned before display',
            color: Colors.teal,
            onTap: () => _pickAndOpen(context, ref, FileType.image),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.folder_open,
            title: 'Open Folder',
            subtitle: 'Browse media library',
            color: Colors.orange,
            onTap: () => _pickFolder(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndOpen(
      BuildContext context, WidgetRef ref, FileType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
    );

    if (result != null &&
        result.files.isNotEmpty &&
        context.mounted) {
      final path = result.files.first.path;
      if (path == null) return;
      final name = result.files.first.name;

      // Record in recent files using string type
      await ref.read(recentFilesProvider.notifier).addFile(
            path,
            name,
            _typeToString(type),
          );

      // Navigate to the appropriate player
      _navigateToPlayer(context, path, _typeToString(type));
    }
  }

  Future<void> _pickFolder(BuildContext context, WidgetRef ref) async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Folder selected: $dir'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToPlayer(
      BuildContext context, String path, String type) {
    Widget screen;
    switch (type) {
      case 'video':
        screen = VideoPlayerScreen(initialPath: path);
      case 'audio':
        screen = AudioPlayerScreen(initialPath: path);
      case 'image':
        screen = ImageViewerScreen(imagePath: path);
      default:
        return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  String _typeToString(FileType type) {
    switch (type) {
      case FileType.video: return 'video';
      case FileType.audio: return 'audio';
      case FileType.image: return 'image';
      default: return 'other';
    }
  }

  // ── Recent Files ──────────────────────────────────────────────────────────────

  Widget _buildRecentFiles(
      BuildContext context, WidgetRef ref, List<RecentFile> files) {
    if (files.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                'No recent files',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Open a file to get started',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListView.separated(
        itemCount: files.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Colors.white10),
        itemBuilder: (context, i) {
          final file = files[i];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _colorForType(file.type).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForType(file.type),
                color: _colorForType(file.type),
                size: 22,
              ),
            ),
            title: Text(
              file.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              file.path,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              _formatDate(file.openedAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
            onTap: () {
              ref.read(recentFilesProvider.notifier).addFile(
                    file.path,
                    file.name,
                    file.type,
                  );
              _navigateToPlayer(context, file.path, file.type);
            },
          );
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  IconData _iconForType(String type) {
    switch (type) {
      case 'video': return Icons.videocam;
      case 'audio': return Icons.audiotrack;
      case 'image': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'video': return Colors.blue;
      case 'audio': return Colors.purple;
      case 'image': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ─── Action Card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
