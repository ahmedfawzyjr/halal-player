// Halal Player - Setup Wizard
//
// First-run experience for language, privacy, and filter mode selection

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/language_provider.dart';
import '../../core/config.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../modules/subtitles/subtitle_provider.dart';
import '../../providers.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Window Controls Row
            Container(
              height: 40,
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/img/logo-icon.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.play_circle, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Halal Player Setup',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.minimize, size: 18),
                    onPressed: () {
                      // Minimize window - requires window_manager
                    },
                    tooltip: 'Minimize',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Close',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            
            // Progress Indicator (5 steps now)
            LinearProgressIndicator(
              value: (_currentPage + 1) / 5,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildLanguagePage(context, ref),
                  _buildPrivacyPage(context, l10n),
                  _buildFilterModePage(context, ref, l10n),
                  _buildSubtitlePage(context, l10n),
                  _buildFinishPage(context, l10n),
                ],
              ),
            ),
            
            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(l10n.goBack),
                    )
                  else
                    const SizedBox.shrink(),
                    
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 4) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeSetup();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _currentPage == 4 ? 'Start Using App' : 'Continue',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: isMobile ? const EdgeInsets.all(16.0) : const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.language, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            'Select Language',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                childAspectRatio: isMobile ? 2.8 : 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: supportedLanguages.length,
              itemBuilder: (context, index) {
                final lang = supportedLanguages[index];
                final isSelected = currentLocale.languageCode == lang.code;
                
                return InkWell(
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage(lang.code);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : null,
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      lang.nativeName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 12.5 : 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPage(BuildContext context, AppLocalizations l10n) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: isMobile ? const EdgeInsets.all(16.0) : const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 80, color: Colors.green),
          const SizedBox(height: 32),
          Text(
            l10n.privacy,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                _buildFeatureItem(
                  context,
                  Icons.wifi_off,
                  '100% Offline',
                  'All AI processing happens locally on your device.',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  Icons.cloud_off,
                  'No Cloud Uploads',
                  'Your photos and videos never leave your computer.',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  Icons.visibility_off,
                  'No Tracking',
                  'We do not track your usage or collect personal data.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterModePage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: isMobile ? const EdgeInsets.all(16.0) : const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          Text(
            l10n.filteringMode,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your initial protection level',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ListView(
                children: [
                  _buildModeTile(
                    context,
                    ref,
                    FilterMode.strictIslamic,
                    'Strict Islamic',
                    'Blocks all inappropriate content immediately.',
                    Icons.mosque,
                  ),
                  _buildModeTile(
                    context,
                    ref,
                    FilterMode.family,
                    'Family Safe',
                    'Blurs inappropriate content. Good for families.',
                    Icons.family_restroom,
                  ),
                  _buildModeTile(
                    context,
                    ref,
                    FilterMode.teen,
                    'Teen / Moderate',
                    'Allows mild content but blocks explicit scenes.',
                    Icons.school,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTile(
    BuildContext context,
    WidgetRef ref,
    FilterMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final currentMode = ref.watch(appConfigProvider).mode;
    final isSelected = currentMode == mode;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(appConfigProvider.notifier).setMode(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(subtitle),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitlePage(BuildContext context, AppLocalizations l10n) {
    final subtitleSettings = ref.watch(subtitleSettingsProvider);
    final notifier = ref.read(subtitleSettingsProvider.notifier);
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Language options for subtitles
    const langOptions = [
      ('ar', 'العربية'),
      ('en', 'English'),
    ];

    return Padding(
      padding: isMobile ? const EdgeInsets.all(16.0) : const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.subtitles, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            'Subtitle Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure subtitle preferences',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          // Auto-download toggle
          Directionality(
            textDirection: TextDirection.ltr,
            child: Card(
              child: SwitchListTile(
                title: Text(AppLocalizations.of(context)!.autoDownload),
                subtitle: Text(AppLocalizations.of(context)!.downloadSubtitlesDesc),
                value: subtitleSettings.autoDownload,
                onChanged: notifier.setAutoDownload,
                secondary: const Icon(Icons.download),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Language selector
          Directionality(
            textDirection: TextDirection.ltr,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.preferredSubtitleLanguage),
                          const SizedBox(height: 4),
                          DropdownButton<String>(
                            value: subtitleSettings.preferredLanguage,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: langOptions
                                .map((l) => DropdownMenuItem(
                                      value: l.$1,
                                      child: Text(l.$2),
                                    ))
                                .toList(),
                            onChanged: (code) {
                              if (code != null) {
                                notifier.setPreferredLanguage(code);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Islamic filter toggle
          Directionality(
            textDirection: TextDirection.ltr,
            child: Card(
              child: SwitchListTile(
                title: Text(AppLocalizations.of(context)!.islamicSafeMode),
                subtitle: Text(AppLocalizations.of(context)!.filterInappropriateWords),
                value: subtitleSettings.islamicFilter,
                onChanged: notifier.setIslamicFilter,
                secondary: const Icon(Icons.mosque),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishPage(BuildContext context, AppLocalizations l10n) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: isMobile ? const EdgeInsets.all(16.0) : const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          const SizedBox(height: 32),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Text(
                  'You are all set!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Halal Player is ready to protect your media experience.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSetup() async {
    final box = await Hive.openBox('halal_player');
    await box.put('is_first_run', false);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationView()),
      );
    }
  }
}
