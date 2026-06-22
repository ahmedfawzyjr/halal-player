// Halal Player - Logs Screen
//
// Displays content analysis history from contentLogsProvider.
// Stats cards are live; list entries come from the actual provider state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(contentLogsProvider);
    final notifier = ref.watch(contentLogsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Content Logs',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filter'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: logs.isEmpty
                        ? null
                        : () => _showClearConfirmation(context, ref),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Clear All'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards — live from provider
          _buildStatsRow(context, notifier),
          const SizedBox(height: 24),

          // Privacy note
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: Colors.green[300], size: 16),
                const SizedBox(width: 12),
                Text(
                  'Logs are stored in memory only and never leave your device.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.green[300]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Logs List
          Expanded(
            child:
                logs.isEmpty ? _buildEmpty(context) : _buildList(context, logs),
          ),
        ],
      ),
    );
  }

  // ── Stats row ────────────────────────────────────────────────────────────────

  Widget _buildStatsRow(
      BuildContext context, ContentLogsNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Analyzed',
            value: '${notifier.totalAnalyzed}',
            icon: Icons.analytics,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Allowed',
            value: '${notifier.totalAllowed}',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Blurred',
            value: '${notifier.totalBlurred}',
            icon: Icons.blur_on,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Blocked',
            value: '${notifier.totalBlocked}',
            icon: Icons.block,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
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
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'No logs yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Content analysis logs will appear here as you open media',
              textAlign: TextAlign.center,
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

  // ── Log list ─────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, List<ContentLogEntry> logs) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListView.separated(
        itemCount: logs.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Colors.white10),
        itemBuilder: (context, i) => _LogItem(entry: logs[i]),
      ),
    );
  }

  // ── Clear confirmation ───────────────────────────────────────────────────────

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Logs?'),
        content: const Text(
          'This will permanently delete all content logs from memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(contentLogsProvider.notifier).clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('All logs cleared'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// ─── Log item ─────────────────────────────────────────────────────────────────

class _LogItem extends StatelessWidget {
  const _LogItem({required this.entry});
  final ContentLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final (actionIcon, actionColor) = switch (entry.action) {
      'allow' => (Icons.check_circle, Colors.green),
      'blur' => (Icons.blur_on, Colors.orange),
      'block' => (Icons.block, Colors.red),
      _ => (Icons.info, Colors.grey),
    };

    final (typeIcon) = switch (entry.contentType) {
      'video' => Icons.videocam,
      'audio' => Icons.audiotrack,
      'image' => Icons.image,
      _ => Icons.insert_drive_file,
    };

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: actionColor, size: 20),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: actionColor,
                shape: BoxShape.circle,
              ),
              child: Icon(actionIcon, color: Colors.white, size: 10),
            ),
          ),
        ],
      ),
      title: Text(
        entry.fileName,
        style: const TextStyle(fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        entry.reason ?? 'Allowed — content is safe',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(entry.timestamp),
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${(entry.score * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: actionColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
