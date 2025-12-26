// Halal Player - Settings Screen
// 
// User preferences and filtering mode configuration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  FilterMode _selectedMode = FilterMode.family;
  bool _enableLogging = true;
  bool _showExplanations = true;
  bool _enableBlurEffect = true;
  bool _autoSkipFlagged = false;

  @override
  Widget build(BuildContext context) {
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

          // Appearance Section (Theme)
          _buildSection(
            context,
            title: 'Appearance',
            icon: Icons.palette,
            child: _buildAppearanceSettings(context),
          ),
          const SizedBox(height: 24),

          // Filtering Mode
          _buildSection(
            context,
            title: 'Filtering Mode',
            icon: Icons.shield,
            child: _buildFilterModeSelector(context),
          ),
          const SizedBox(height: 24),

          // AI Behavior
          _buildSection(
            context,
            title: 'AI Behavior',
            icon: Icons.memory,
            child: _buildAIBehaviorSettings(context),
          ),
          const SizedBox(height: 24),

          // Privacy
          _buildSection(
            context,
            title: 'Privacy',
            icon: Icons.lock,
            child: _buildPrivacySettings(context),
          ),
          const SizedBox(height: 24),

          // About
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

  Widget _buildAppearanceSettings(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    isDark ? 'Dark mode' : 'Light mode',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
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
        ),
      ],
    );
  }

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

  Widget _buildFilterModeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your preferred filtering level',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
        ),
        const SizedBox(height: 16),
        ...FilterMode.values.map((mode) => _buildModeOption(context, mode)),
      ],
    );
  }

  Widget _buildModeOption(BuildContext context, FilterMode mode) {
    final isSelected = _selectedMode == mode;
    final thresholdColor = _getThresholdColor(mode.nsfwThreshold);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? Colors.green.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => setState(() => _selectedMode = mode),
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
                  groupValue: _selectedMode,
                  onChanged: (value) => setState(() => _selectedMode = value!),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildAIBehaviorSettings(BuildContext context) {
    return Column(
      children: [
        _buildToggleSetting(
          context,
          title: 'Blur Effect',
          subtitle: 'Use blur instead of blocking content',
          value: _enableBlurEffect,
          onChanged: (value) => setState(() => _enableBlurEffect = value),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          title: 'Auto Skip Flagged',
          subtitle: 'Automatically skip detected content',
          value: _autoSkipFlagged,
          onChanged: (value) => setState(() => _autoSkipFlagged = value),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(BuildContext context) {
    return Column(
      children: [
        _buildToggleSetting(
          context,
          title: 'Enable Logging',
          subtitle: 'Keep record of blocked content (local only)',
          value: _enableLogging,
          onChanged: (value) => setState(() => _enableLogging = value),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          title: 'AI Explanations',
          subtitle: 'Show why content was blocked',
          value: _showExplanations,
          onChanged: (value) => setState(() => _showExplanations = value),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, color: Colors.green[300], size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All processing happens locally. Your media never leaves your device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[300],
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
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

  Widget _buildAboutSection(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.play_circle_filled, size: 24, color: Colors.green),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halal Player',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
