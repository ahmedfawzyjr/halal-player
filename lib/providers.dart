// Halal Player - State Providers
//
// Riverpod providers for app state management

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config.dart';
import 'core/policy_engine.dart';
import 'core/ai_gateway.dart';
import 'ai/frame_analyzer.dart';
import 'ai/image_analyzer.dart';

/// App configuration provider
final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

class AppConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() => AppConfig();

  void setMode(FilterMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setEnableLogging(bool value) {
    state = state.copyWith(enableLogging: value);
  }

  void setShowExplanations(bool value) {
    state = state.copyWith(showExplanations: value);
  }

  void setEnableBlurEffect(bool value) {
    state = state.copyWith(enableBlurEffect: value);
  }

  void setAutoSkipFlagged(bool value) {
    state = state.copyWith(autoSkipFlagged: value);
  }

  void setFrameAnalysisInterval(int ms) {
    state = state.copyWith(frameAnalysisInterval: ms);
  }
}

/// Theme mode provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/// AI Gateway provider
final aiGatewayProvider = Provider<AIGateway>((ref) {
  return AIGateway(
    nsfwDetector: PlaceholderNSFWDetector(),
    nudenetDetector: PlaceholderNudeNetDetector(),
  );
});

/// Policy Engine provider
final policyEngineProvider = Provider<PolicyEngine>((ref) {
  final config = ref.watch(appConfigProvider);
  return PolicyEngine(config);
});

/// Frame Analyzer provider
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

/// Content log entry
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
  final String contentType;
  final String filePath;
  final String action;
  final double score;
  final String? reason;
}

/// Content logs provider
final contentLogsProvider = NotifierProvider<ContentLogsNotifier, List<ContentLogEntry>>(
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

  // Statistics
  int get totalAnalyzed => state.length;
  int get totalAllowed => state.where((e) => e.action == 'allow').length;
  int get totalBlurred => state.where((e) => e.action == 'blur').length;
  int get totalBlocked => state.where((e) => e.action == 'block').length;
}
