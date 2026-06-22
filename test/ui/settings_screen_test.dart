// Halal Player - Settings Screen Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halal_player/core/config.dart';
import 'package:halal_player/providers.dart';
import 'package:halal_player/ui/settings/settings_screen.dart';

class FakeAppConfigNotifier extends AppConfigNotifier {
  FakeAppConfigNotifier(this.initialConfig);
  final AppConfig initialConfig;

  @override
  AppConfig build() {
    state = initialConfig;
    return initialConfig;
  }

  @override
  Future<void> _loadFromHive() async {}

  @override
  Future<void> _saveToHive() async {}
}

class FakeThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() {
    state = ThemeMode.dark;
    return ThemeMode.dark;
  }

  @override
  Future<void> _loadFromHive() async {}

  @override
  Future<void> _saveToHive(ThemeMode mode) async {}
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
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SettingsScreen(),
          ),
        ),
      ),
    );

    // Verify sections are displayed
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Filtering Mode'), findsOneWidget);
    expect(find.text('AI Behavior'), findsOneWidget);
  });
}
