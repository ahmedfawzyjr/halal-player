// Halal Player - Settings Screen
//
// User preferences and filtering mode configuration
// All state is read from and written to Riverpod providers (persisted via Hive)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/keyboard_shortcuts.dart';
import '../../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live state from providers
    final config = ref.watch(appConfigProvider);
    final themeMode = ref.watch(themeModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // ── Appearance ────────────────────────────────────────────────────
          _buildSection(
            context,
            title: 'Appearance',
            icon: Icons.palette,
            child: _buildAppearanceSettings(context, ref, themeMode),
          ),
          const SizedBox(height: 16),

          // ── Filtering Mode ────────────────────────────────────────────────
          _buildSection(
            context,
            title: 'Filtering Mode',
            icon: Icons.shield,
            child: _buildFilterModeSelector(context, ref, config),
          ),
          const SizedBox(height: 16),

          // ── AI Behavior ───────────────────────────────────────────────────
          _buildSection(
            context,
            title: 'AI Behavior',
            icon: Icons.memory,
            child: _buildAIBehaviorSettings(context, ref, config),
          ),
          const SizedBox(height: 16),

          // ── Privacy ───────────────────────────────────────────────────────
          _buildSection(
            context,
            title: 'Privacy',
            icon: Icons.lock,
            child: _buildPrivacySettings(context, ref, config),
          ),
          const SizedBox(height: 16),

          // ── Keyboard Shortcuts ────────────────────────────────────────────
          _buildSection(
            context,
            title: 'Keyboard Shortcuts',
            icon: Icons.keyboard,
            child: _buildKeyboardShortcutsSection(context),
          ),
          const SizedBox(height: 16),

          // ── About ─────────────────────────────────────────────────────────
          _buildSection(
            context,
            title: 'About',
            icon: Icons.info,
            child: _buildAboutSection(context),
          ),
        ],
      ),
    );
  }

  // ── Appearance ──────────────────────────────────────────────────────────────

  Widget _buildAppearanceSettings(
      BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(
                themeMode == ThemeMode.dark
                    ? 'Dark mode'
                    : themeMode == ThemeMode.light
                        ? 'Light mode'
                        : 'System default',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode, size: 18),
              label: Text('Light'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode, size: 18),
              label: Text('Dark'),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto, size: 18),
              label: Text('Auto'),
            ),
          ],
          selected: {themeMode},
          onSelectionChanged: (Set<ThemeMode> selected) {
            ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
          },
        ),
      ],
    );
  }

  // ── Filter Mode ─────────────────────────────────────────────────────────────

  Widget _buildFilterModeSelector(
      BuildContext context, WidgetRef ref, AppConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your preferred filtering level',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),
        ...FilterMode.values
            .map((mode) => _buildModeOption(context, ref, mode, config)),
      ],
    );
  }

  Widget _buildModeOption(
      BuildContext context, WidgetRef ref, FilterMode mode, AppConfig config) {
    final isSelected = config.mode == mode;
    final thresholdColor = _getThresholdColor(mode.nsfwThreshold);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () =>
              ref.read(appConfigProvider.notifier).setMode(mode),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.white12,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Radio<FilterMode>(
                  value: mode,
                  groupValue: config.mode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appConfigProvider.notifier).setMode(value);
                    }
                  },
                  activeColor: Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: thresholdColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Threshold: ${(mode.nsfwThreshold * 100).toInt()}%',
                    style: TextStyle(
                      color: thresholdColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getThresholdColor(double threshold) {
    if (threshold <= 0.3) return Colors.red;
    if (threshold <= 0.5) return Colors.orange;
    if (threshold <= 0.7) return Colors.yellow.shade700;
    return Colors.green;
  }

  // ── AI Behavior ─────────────────────────────────────────────────────────────

  Widget _buildAIBehaviorSettings(
      BuildContext context, WidgetRef ref, AppConfig config) {
    return Column(
      children: [
        _buildToggleSetting(
          context,
          title: 'Blur Effect',
          subtitle: 'Use blur instead of blocking content',
          value: config.enableBlurEffect,
          onChanged: (value) =>
              ref.read(appConfigProvider.notifier).setEnableBlurEffect(value),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          title: 'Auto Skip Flagged',
          subtitle: 'Automatically skip detected content',
          value: config.autoSkipFlagged,
          onChanged: (value) =>
              ref.read(appConfigProvider.notifier).setAutoSkipFlagged(value),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          title: 'AI Explanations',
          subtitle: 'Show why content was blocked',
          value: config.showExplanations,
          onChanged: (value) =>
              ref.read(appConfigProvider.notifier).setShowExplanations(value),
        ),
        const SizedBox(height: 16),
        // Frame analysis interval slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Frame Analysis Interval',
                    style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  '${config.frameAnalysisInterval}ms',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'How often to scan video frames (lower = more accurate but slower)',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
            Slider(
              value: config.frameAnalysisInterval.toDouble(),
              min: 500,
              max: 5000,
              divisions: 9,
              activeColor: Colors.green,
              label: '${config.frameAnalysisInterval}ms',
              onChanged: (value) => ref
                  .read(appConfigProvider.notifier)
                  .setFrameAnalysisInterval(value.round()),
            ),
          ],
        ),
      ],
    );
  }

  // ── Privacy ─────────────────────────────────────────────────────────────────

  Widget _buildPrivacySettings(
      BuildContext context, WidgetRef ref, AppConfig config) {
    return Column(
      children: [
        _buildToggleSetting(
          context,
          title: 'Enable Logging',
          subtitle: 'Keep record of analyzed content (local only)',
          value: config.enableLogging,
          onChanged: (value) =>
              ref.read(appConfigProvider.notifier).setEnableLogging(value),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, color: Colors.green[300], size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All processing happens locally. Your media never leaves your device.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.green[300]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Keyboard Shortcuts ──────────────────────────────────────────────────────

  Widget _buildKeyboardShortcutsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick reference for keyboard shortcuts',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[500]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ShortcutChip(keys: 'Space / K', label: 'Play/Pause'),
            _ShortcutChip(keys: '→ / L', label: '+10 sec'),
            _ShortcutChip(keys: '← / J', label: '-10 sec'),
            _ShortcutChip(keys: '↑ / ↓', label: 'Volume'),
            _ShortcutChip(keys: 'M', label: 'Mute'),
            _ShortcutChip(keys: 'F', label: 'Fullscreen'),
            _ShortcutChip(keys: 'Ctrl+O', label: 'Open File'),
            _ShortcutChip(keys: 'Ctrl+H', label: 'Home'),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const KeyboardShortcutsDialog(),
          ),
          icon: const Icon(Icons.keyboard, size: 18),
          label: const Text('View All Shortcuts'),
        ),
      ],
    );
  }

  // ── About ───────────────────────────────────────────────────────────────────

  Widget _buildAboutSection(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.play_circle_filled,
              size: 24, color: Colors.green),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halal Player',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Version 1.0.5 — Privacy-first media player',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  // ── Shared Helpers ──────────────────────────────────────────────────────────

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF3A3A3A)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
      ],
    );
  }
}

// ─── Helper widget ────────────────────────────────────────────────────────────

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({required this.keys, required this.label});
  final String keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.green),
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[400])),
        ],
      ),
    );
  }
}
