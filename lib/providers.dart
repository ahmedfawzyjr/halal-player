// Halal Player - State Providers
//
// Riverpod providers for app state management

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config.dart';
import 'core/policy_engine.dart';
import 'core/ai_gateway.dart';
import 'ai/frame_analyzer.dart';
import 'ai/image_analyzer.dart';
import 'ai/real_detectors.dart';

// ─── Hive box name ────────────────────────────────────────────────────────────
const _kHiveBox = 'halal_player';

// ─── App Config Provider ──────────────────────────────────────────────────────

/// App configuration provider — persists to Hive automatically
final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

class AppConfigNotifier extends Notifier<AppConfig> {
  static const _kMode = 'cfg_mode';
  static const _kLogging = 'cfg_logging';
  static const _kExplanations = 'cfg_explanations';
  static const _kBlur = 'cfg_blur';
  static const _kAutoSkip = 'cfg_auto_skip';
  static const _kInterval = 'cfg_interval';

  @override
  AppConfig build() {
    _loadFromHive();
    return AppConfig();
  }

  Future<void> _loadFromHive() async {
    try {
      final box = await Hive.openBox(_kHiveBox);
      final modeName = box.get(_kMode) as String?;
      final mode = modeName != null
          ? FilterMode.values.firstWhere(
              (m) => m.name == modeName,
              orElse: () => FilterMode.family,
            )
          : FilterMode.family;

      state = AppConfig(
        mode: mode,
        enableLogging: box.get(_kLogging, defaultValue: true) as bool,
        showExplanations: box.get(_kExplanations, defaultValue: true) as bool,
        enableBlurEffect: box.get(_kBlur, defaultValue: true) as bool,
        autoSkipFlagged: box.get(_kAutoSkip, defaultValue: false) as bool,
        frameAnalysisInterval: box.get(_kInterval, defaultValue: 1000) as int,
      );
    } catch (_) {
      // Keep defaults on error
    }
  }

  Future<void> _saveToHive() async {
    try {
      final box = await Hive.openBox(_kHiveBox);
      await box.put(_kMode, state.mode.name);
      await box.put(_kLogging, state.enableLogging);
      await box.put(_kExplanations, state.showExplanations);
      await box.put(_kBlur, state.enableBlurEffect);
      await box.put(_kAutoSkip, state.autoSkipFlagged);
      await box.put(_kInterval, state.frameAnalysisInterval);
    } catch (_) {}
  }

  void setMode(FilterMode mode) {
    state = state.copyWith(mode: mode);
    _saveToHive();
  }

  void setEnableLogging(bool value) {
    state = state.copyWith(enableLogging: value);
    _saveToHive();
  }

  void setShowExplanations(bool value) {
    state = state.copyWith(showExplanations: value);
    _saveToHive();
  }

  void setEnableBlurEffect(bool value) {
    state = state.copyWith(enableBlurEffect: value);
    _saveToHive();
  }

  void setAutoSkipFlagged(bool value) {
    state = state.copyWith(autoSkipFlagged: value);
    _saveToHive();
  }

  void setFrameAnalysisInterval(int ms) {
    state = state.copyWith(frameAnalysisInterval: ms);
    _saveToHive();
  }
}

// ─── Theme Mode Provider ──────────────────────────────────────────────────────

/// Theme mode provider — persists to Hive automatically
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _kTheme = 'cfg_theme';

  @override
  ThemeMode build() {
    _loadFromHive();
    return ThemeMode.dark;
  }

  Future<void> _loadFromHive() async {
    try {
      final box = await Hive.openBox(_kHiveBox);
      final saved = box.get(_kTheme) as String?;
      if (saved != null) {
        state = ThemeMode.values.firstWhere(
          (m) => m.name == saved,
          orElse: () => ThemeMode.dark,
        );
      }
    } catch (_) {}
  }

  Future<void> _saveToHive(ThemeMode mode) async {
    try {
      final box = await Hive.openBox(_kHiveBox);
      await box.put(_kTheme, mode.name);
    } catch (_) {}
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveToHive(mode);
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    _saveToHive(next);
  }
}

// ─── AI Providers ─────────────────────────────────────────────────────────────

/// AI Gateway provider - uses real Python-based detectors
final aiGatewayProvider = Provider<AIGateway>((ref) {
  return AIGateway(
    nsfwDetector: RealNSFWDetector(),
    nudenetDetector: RealNudeNetDetector(),
  );
});

/// Policy Engine provider - rebuilds when config changes
final policyEngineProvider = Provider<PolicyEngine>((ref) {
  final config = ref.watch(appConfigProvider);
  return PolicyEngine(config);
});

/// Frame Analyzer provider - rebuilds when config changes
final frameAnalyzerProvider = Provider<FrameAnalyzer>((ref) {
  final aiGateway = ref.watch(aiGatewayProvider);
  final policyEngine = ref.watch(policyEngineProvider);
  final config = ref.watch(appConfigProvider);

  return FrameAnalyzer(
    aiGateway: aiGateway,
    policyEngine: policyEngine,
    analysisIntervalMs: config.frameAnalysisInterval,
  );
});

/// Image Analyzer provider
final imageAnalyzerProvider = Provider<ImageAnalyzer>((ref) {
  final aiGateway = ref.watch(aiGatewayProvider);
  final policyEngine = ref.watch(policyEngineProvider);

  return ImageAnalyzer(
    aiGateway: aiGateway,
    policyEngine: policyEngine,
  );
});

// ─── Content Logs Provider ────────────────────────────────────────────────────

/// A single log entry for analyzed content
class ContentLogEntry {
  ContentLogEntry({
    required this.timestamp,
    required this.contentType,
    required this.filePath,
    required this.action,
    required this.score,
    this.reason,
  });

  final DateTime timestamp;
  final String contentType; // 'video' | 'audio' | 'image'
  final String filePath;
  final String action;      // 'allow' | 'blur' | 'block'
  final double score;
  final String? reason;

  String get fileName => filePath.split(r'\').last.split('/').last;
}

/// Content logs provider — in-memory (session only, privacy-first)
final contentLogsProvider =
    NotifierProvider<ContentLogsNotifier, List<ContentLogEntry>>(
  ContentLogsNotifier.new,
);

class ContentLogsNotifier extends Notifier<List<ContentLogEntry>> {
  @override
  List<ContentLogEntry> build() => [];

  void addLog(ContentLogEntry entry) {
    state = [entry, ...state];
  }

  void clearLogs() {
    state = [];
  }

  void removeLog(int index) {
    state = [...state]..removeAt(index);
  }

  // ─── Statistics ──────────────────────────────────────────────────────────────
  int get totalAnalyzed => state.length;
  int get totalAllowed => state.where((e) => e.action == 'allow').length;
  int get totalBlurred => state.where((e) => e.action == 'blur').length;
  int get totalBlocked => state.where((e) => e.action == 'block').length;
}
