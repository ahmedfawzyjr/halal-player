// Halal Player - Settings Screen Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_player/core/config.dart';
import 'package:halal_player/providers.dart';
import 'package:halal_player/ui/settings/settings_screen.dart';
import 'package:halal_player/l10n/app_localizations.dart';
import 'package:halal_player/core/language_provider.dart';

class FakeAppConfigNotifier extends AppConfigNotifier {
  FakeAppConfigNotifier(this.initialConfig);
  final AppConfig initialConfig;

  @override
  AppConfig build() {
    state = initialConfig;
    return initialConfig;
  }
}

class FakeThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() {
    state = ThemeMode.dark;
    return ThemeMode.dark;
  }
}

class FakeLanguageNotifier extends LanguageNotifier {
  @override
  Locale build() {
    state = const Locale('en');
    return const Locale('en');
  }
}

void main() {
  testWidgets('SettingsScreen displays settings section titles', (WidgetTester tester) async {
    final initialConfig = AppConfig(
      mode: FilterMode.family,
      enableLogging: true,
      showExplanations: true,
      enableBlurEffect: true,
      autoSkipFlagged: false,
      frameAnalysisInterval: 1000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWith(() => FakeAppConfigNotifier(initialConfig)),
          themeModeProvider.overrideWith(() => FakeThemeModeNotifier()),
          languageProvider.overrideWith(() => FakeLanguageNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SettingsScreen(),
          ),
        ),
      ),
    );

    // Verify sections are displayed
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Filtering Mode'), findsOneWidget);
    expect(find.text('AI Behavior'), findsOneWidget);
  });
}
