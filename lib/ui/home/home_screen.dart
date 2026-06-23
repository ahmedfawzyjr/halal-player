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
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFiles = ref.watch(recentFilesProvider);
    final scrollPhysics = Theme.of(context).platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();

    return SingleChildScrollView(
      physics: scrollPhysics,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            _buildWelcomeBanner(context),
            const SizedBox(height: 32),

            // Quick Actions
            _buildSectionHeader(context, AppLocalizations.of(context)!.quickActions),
            const SizedBox(height: 16),
            _buildQuickActions(context, ref),
            const SizedBox(height: 32),

            // Recent Files
            _buildSectionHeader(context, AppLocalizations.of(context)!.recentFiles,
                trailing: recentFiles.isNotEmpty
                    ? TextButton(
                        onPressed: () =>
                            ref.read(recentFilesProvider.notifier).clearAll(),
                        child: Text(AppLocalizations.of(context)!.clearAll,
                            style: const TextStyle(color: Colors.red)),
                      )
                    : null),
            const SizedBox(height: 16),
            _buildRecentFiles(context, ref, recentFiles),
          ],
        ),
      ),
    );
  }

  // ── Welcome banner ────────────────────────────────────────────────────────────
 
  Widget _buildWelcomeBanner(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

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
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield, size: 40, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.welcomeTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.welcomeSubtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green[100]),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.protected,
                          style: TextStyle(
                              color: Colors.green[100],
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.shield, size: 48, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcomeTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.welcomeSubtitle,
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
                        AppLocalizations.of(context)!.protected,
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
        children: [
          _ActionCard(
            icon: Icons.videocam,
            title: AppLocalizations.of(context)!.openVideo,
            subtitle: AppLocalizations.of(context)!.playWithProtection,
            color: Colors.blue,
            onTap: () => _pickAndOpen(context, ref, FileType.video),
          ),
          _ActionCard(
            icon: Icons.audiotrack,
            title: AppLocalizations.of(context)!.openAudio,
            subtitle: AppLocalizations.of(context)!.listenSafely,
            color: Colors.purple,
            onTap: () => _pickAndOpen(context, ref, FileType.audio),
          ),
          _ActionCard(
            icon: Icons.image,
            title: AppLocalizations.of(context)!.viewImage,
            subtitle: AppLocalizations.of(context)!.aiScanned,
            color: Colors.teal,
            onTap: () => _pickAndOpen(context, ref, FileType.image),
          ),
          _ActionCard(
            icon: Icons.folder_open,
            title: AppLocalizations.of(context)!.openFolder,
            subtitle: AppLocalizations.of(context)!.browseLibrary,
            color: Colors.orange,
            onTap: () => _pickFolder(context, ref),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.videocam,
            title: AppLocalizations.of(context)!.openVideo,
            subtitle: AppLocalizations.of(context)!.playWithProtection,
            color: Colors.blue,
            onTap: () => _pickAndOpen(context, ref, FileType.video),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.audiotrack,
            title: AppLocalizations.of(context)!.openAudio,
            subtitle: AppLocalizations.of(context)!.listenSafely,
            color: Colors.purple,
            onTap: () => _pickAndOpen(context, ref, FileType.audio),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.image,
            title: AppLocalizations.of(context)!.viewImage,
            subtitle: AppLocalizations.of(context)!.aiScanned,
            color: Colors.teal,
            onTap: () => _pickAndOpen(context, ref, FileType.image),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.folder_open,
            title: AppLocalizations.of(context)!.openFolder,
            subtitle: AppLocalizations.of(context)!.browseLibrary,
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

      if (!context.mounted) return;

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
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noRecentFiles,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.openFileToStart,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: files.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, i) {
          final file = files[i];
          return _RecentFileItem(
            file: file,
            icon: _iconForType(file.type),
            color: _colorForType(file.type),
            formattedDate: _formatDate(context, file.openedAt),
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

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final loc = AppLocalizations.of(context)!;
    if (diff.inMinutes < 1) return loc.justNow;
    if (diff.inHours < 1) return loc.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return loc.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return loc.daysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ─── Action Card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatefulWidget {
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
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _isHovered ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.color.withValues(alpha: _isHovered ? 0.4 : 0.2),
                width: 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: _isHovered ? 0.3 : 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 26),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentFileItem extends StatefulWidget {
  const _RecentFileItem({
    required this.file,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.formattedDate,
  });

  final RecentFile file;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final String formattedDate;

  @override
  State<_RecentFileItem> createState() => _RecentFileItemState();
}

class _RecentFileItemState extends State<_RecentFileItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.color.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _isHovered ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: 22,
            ),
          ),
          title: Text(
            widget.file.name,
            style: TextStyle(
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            widget.file.path,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            widget.formattedDate,
            style: TextStyle(
              color: _isHovered ? widget.color : Colors.grey[600],
              fontSize: 11,
              fontWeight: _isHovered ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
