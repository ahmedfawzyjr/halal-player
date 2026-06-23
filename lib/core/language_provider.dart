// Halal Player - Language Provider
//
// Manages app language and locale preferences

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Supported languages with their display names
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isRTL = false,
  });

  final String code;
  final String name;
  final String nativeName;
  final bool isRTL;

  Locale get locale => Locale(code);
}

/// All supported languages
const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: 'en', name: 'English', nativeName: 'English'),
  AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', isRTL: true),
];

/// Get list of supported locales
List<Locale> get supportedLocales => 
    supportedLanguages.map((l) => l.locale).toList();

/// Get language by code
AppLanguage? getLanguageByCode(String code) {
  try {
    return supportedLanguages.firstWhere((l) => l.code == code);
  } catch (_) {
    return null;
  }
}

/// Language provider
final languageProvider = NotifierProvider<LanguageNotifier, Locale>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<Locale> {
  static const String _storageKey = 'app_language';

  @override
  Locale build() {
    _loadFromStorage();
    return const Locale('en'); // Default to English
  }

  Future<void> _loadFromStorage() async {
    try {
      final box = await Hive.openBox('halal_player');
      final code = box.get(_storageKey) as String?;
      if (code != null) {
        state = Locale(code);
      }
    } catch (_) {
      // Keep default
    }
  }

  Future<void> _saveToStorage(String code) async {
    try {
      final box = await Hive.openBox('halal_player');
      await box.put(_storageKey, code);
    } catch (_) {
      // Ignore errors
    }
  }

  void setLanguage(String code) {
    state = Locale(code);
    _saveToStorage(code);
  }

  void setLocale(Locale locale) {
    state = locale;
    _saveToStorage(locale.languageCode);
  }

  /// Check if current language is RTL
  bool get isRTL {
    final lang = getLanguageByCode(state.languageCode);
    return lang?.isRTL ?? false;
  }
}

/// Widget to select language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Language', 
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: supportedLanguages.map((lang) {
            final isSelected = currentLocale.languageCode == lang.code;
            return ChoiceChip(
              label: Text(lang.nativeName),
              selected: isSelected,
              onSelected: (_) {
                ref.read(languageProvider.notifier).setLanguage(lang.code);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Dropdown language selector (more compact)
class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    
    return DropdownButton<String>(
      value: currentLocale.languageCode,
      items: supportedLanguages.map((lang) {
        return DropdownMenuItem(
          value: lang.code,
          child: Text('${lang.nativeName} (${lang.name})'),
        );
      }).toList(),
      onChanged: (code) {
        if (code != null) {
          ref.read(languageProvider.notifier).setLanguage(code);
        }
      },
    );
  }
}
