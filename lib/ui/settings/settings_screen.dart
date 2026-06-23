// Halal Player - Settings Screen
//
// User preferences and filtering mode configuration
// All state is read from and written to Riverpod providers (persisted via Hive)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/keyboard_shortcuts.dart';
import '../../core/language_provider.dart';
import '../../providers.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch live state from providers
    final config = ref.watch(appConfigProvider);
    final themeMode = ref.watch(themeModeProvider);
    final loc = AppLocalizations.of(context)!;
    final scrollPhysics = Theme.of(context).platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();

    return SingleChildScrollView(
      physics: scrollPhysics,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.settings,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // ── Appearance ────────────────────────────────────────────────────
          _buildSection(
            context,
            title: loc.appearance,
            icon: Icons.palette,
            child: _buildAppearanceSettings(context, ref, themeMode),
          ),
          const SizedBox(height: 16),

          // ── Language ──────────────────────────────────────────────────────
          _buildSection(
            context,
            title: loc.language,
            icon: Icons.language,
            child: _buildLanguageSettings(context, ref),
          ),
          const SizedBox(height: 16),

          // ── Filtering Mode ────────────────────────────────────────────────
          _buildSection(
            context,
            title: loc.filteringMode,
            icon: Icons.shield,
            child: _buildFilterModeSelector(context, ref, config),
          ),
          const SizedBox(height: 16),

          // ── AI Behavior ───────────────────────────────────────────────────
          _buildSection(
            context,
            title: loc.aiBehavior,
            icon: Icons.memory,
            child: _buildAIBehaviorSettings(context, ref, config),
          ),
          const SizedBox(height: 16),

          // ── Privacy ───────────────────────────────────────────────────────
          _buildSection(
            context,
            title: loc.privacy,
            icon: Icons.lock,
            child: _buildPrivacySettings(context, ref, config),
          ),
          const SizedBox(height: 16),

          // ── Keyboard Shortcuts ────────────────────────────────────────────
          _buildSection(
            context,
            title: loc.keyboardShortcuts,
            icon: Icons.keyboard,
            child: _buildKeyboardShortcutsSection(context),
          ),
          const SizedBox(height: 16),

          // ── About ─────────────────────────────────────────────────────────
          _buildSection(
            context,
            title: loc.about,
            icon: Icons.info,
            child: _buildAboutSection(context),
          ),
        ],
      ),
    );
  }

  // ── Language ────────────────────────────────────────────────────────────────

  Widget _buildLanguageSettings(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final loc = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

    final langInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.selectLanguage, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text(
          getLanguageByCode(currentLocale.languageCode)?.nativeName ?? '',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );

    final dropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLocale.languageCode,
          dropdownColor: Theme.of(context).cardColor,
          items: supportedLanguages.map((lang) {
            return DropdownMenuItem(
              value: lang.code,
              child: Text(
                '${lang.nativeName} (${lang.name})',
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (code) {
            if (code != null) {
              ref.read(languageProvider.notifier).setLanguage(code);
            }
          },
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          langInfo,
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: dropdown,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: langInfo),
        dropdown,
      ],
    );
  }

  // ── Appearance ──────────────────────────────────────────────────────────────

  Widget _buildAppearanceSettings(
      BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final loc = AppLocalizations.of(context)!;

    final themeInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.theme, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text(
          themeMode == ThemeMode.dark
              ? loc.darkMode
              : themeMode == ThemeMode.light
                  ? loc.lightMode
                  : loc.auto,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );

    final segmentedButton = SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(Icons.light_mode, size: 16),
          label: Text(loc.light, style: const TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: const Icon(Icons.dark_mode, size: 16),
          label: Text(loc.dark, style: const TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: const Icon(Icons.brightness_auto, size: 16),
          label: Text(loc.auto, style: const TextStyle(fontSize: 12)),
        ),
      ],
      selected: {themeMode},
      onSelectionChanged: (Set<ThemeMode> selected) {
        ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
      },
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themeInfo,
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: segmentedButton,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: themeInfo),
        segmentedButton,
      ],
    );
  }

  // ── Filter Mode ─────────────────────────────────────────────────────────────

  Widget _buildFilterModeSelector(
      BuildContext context, WidgetRef ref, AppConfig config) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.selectFilteringLevel,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),
        RadioGroup<FilterMode>(
          groupValue: config.mode,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setMode(value);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: FilterMode.values
                .map((mode) => _buildModeOption(context, ref, mode, config))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModeOption(
      BuildContext context, WidgetRef ref, FilterMode mode, AppConfig config) {
    final isSelected = config.mode == mode;
    final thresholdColor = _getThresholdColor(mode.nsfwThreshold);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final loc = AppLocalizations.of(context)!;

    String label = '';
    String description = '';
    switch (mode) {
      case FilterMode.strictIslamic:
        label = loc.strictIslamic;
        description = loc.strictIslamicDesc;
        break;
      case FilterMode.family:
        label = loc.family;
        description = loc.familyDesc;
        break;
      case FilterMode.teen:
        label = loc.teen;
        description = loc.teenDesc;
        break;
      case FilterMode.educational:
        label = loc.educational;
        description = loc.educationalDesc;
        break;
      case FilterMode.developer:
        label = loc.developer;
        description = loc.developerDesc;
        break;
    }

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
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<FilterMode>(
                            value: mode,
                            activeColor: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: thresholdColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${loc.threshold}: ${(mode.nsfwThreshold * 100).toInt()}%',
                              style: TextStyle(
                                color: thresholdColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Radio<FilterMode>(
                        value: mode,
                        activeColor: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
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
                          '${loc.threshold}: ${(mode.nsfwThreshold * 100).toInt()}%',
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
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildToggleSetting(
          context,
          title: loc.blurEffect,
          subtitle: loc.blurEffectDesc,
          value: config.enableBlurEffect,
          onChanged: (value) =>
              ref.read(appConfigProvider.notifier).setEnableBlurEffect(value),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          title: loc.autoSkipFlagged,
          subtitle: loc.autoSkipFlaggedDesc,
          value: config.autoSkipFlagged,
          onChanged: (value) =>
              ref.read(appConfigProvider.notifier).setAutoSkipFlagged(value),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          title: loc.aiExplanations,
          subtitle: loc.aiExplanationsDesc,
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
                  style: const TextStyle(
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Slider(
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
            ),
          ],
        ),
      ],
    );
  }

  // ── Privacy ─────────────────────────────────────────────────────────────────

  Widget _buildPrivacySettings(
      BuildContext context, WidgetRef ref, AppConfig config) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildToggleSetting(
          context,
          title: loc.enableLogging,
          subtitle: loc.enableLoggingDesc,
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
                  loc.privacyNote,
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
    final loc = AppLocalizations.of(context)!;
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
          label: Text(loc.viewAllShortcuts),
        ),
      ],
    );
  }

  // ── About ───────────────────────────────────────────────────────────────────

  Widget _buildAboutSection(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
              '${loc.version} 1.0.5 — Privacy-first media player',
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
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
          Divider(height: 1, color: Theme.of(context).dividerColor),
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
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
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
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ),
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
