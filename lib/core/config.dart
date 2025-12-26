// Halal Player - Configuration
// 
// App-wide configuration and filtering modes

enum FilterMode {
  strictIslamic(
    label: 'Strict Islamic',
    description: 'Very strict filtering for maximum protection',
    nsfwThreshold: 0.3,
    nudenetThreshold: 0.3,
  ),
  family(
    label: 'Family',
    description: 'Balanced filtering for family use',
    nsfwThreshold: 0.5,
    nudenetThreshold: 0.5,
  ),
  teen(
    label: 'Teen',
    description: 'Slightly relaxed for teenagers',
    nsfwThreshold: 0.6,
    nudenetThreshold: 0.6,
  ),
  educational(
    label: 'Educational',
    description: 'Allows educational content',
    nsfwThreshold: 0.7,
    nudenetThreshold: 0.7,
  ),
  developer(
    label: 'Developer',
    description: 'Transparency mode - logs only',
    nsfwThreshold: 0.9,
    nudenetThreshold: 0.9,
  );

  const FilterMode({
    required this.label,
    required this.description,
    required this.nsfwThreshold,
    required this.nudenetThreshold,
  });

  final String label;
  final String description;
  final double nsfwThreshold;
  final double nudenetThreshold;
}

class AppConfig {
  AppConfig({
    this.mode = FilterMode.family,
    this.enableLogging = true,
    this.showExplanations = true,
    this.frameAnalysisInterval = 1000, // ms
    this.enableBlurEffect = true,
    this.autoSkipFlagged = false,
  });

  /// Current filtering mode
  FilterMode mode;

  /// Whether to log blocked content
  bool enableLogging;

  /// Show AI explanations for blocked content
  bool showExplanations;

  /// Interval between frame analyses (milliseconds)
  int frameAnalysisInterval;

  /// Use blur effect instead of blocking
  bool enableBlurEffect;

  /// Automatically skip flagged content
  bool autoSkipFlagged;

  /// Get NSFW threshold based on current mode
  double get nsfwThreshold => mode.nsfwThreshold;

  /// Get NudeNet threshold based on current mode
  double get nudenetThreshold => mode.nudenetThreshold;

  /// Create config from JSON
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      mode: FilterMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => FilterMode.family,
      ),
      enableLogging: json['enableLogging'] ?? true,
      showExplanations: json['showExplanations'] ?? true,
      frameAnalysisInterval: json['frameAnalysisInterval'] ?? 1000,
      enableBlurEffect: json['enableBlurEffect'] ?? true,
      autoSkipFlagged: json['autoSkipFlagged'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'enableLogging': enableLogging,
        'showExplanations': showExplanations,
        'frameAnalysisInterval': frameAnalysisInterval,
        'enableBlurEffect': enableBlurEffect,
        'autoSkipFlagged': autoSkipFlagged,
      };

  /// Copy with modifications
  AppConfig copyWith({
    FilterMode? mode,
    bool? enableLogging,
    bool? showExplanations,
    int? frameAnalysisInterval,
    bool? enableBlurEffect,
    bool? autoSkipFlagged,
  }) {
    return AppConfig(
      mode: mode ?? this.mode,
      enableLogging: enableLogging ?? this.enableLogging,
      showExplanations: showExplanations ?? this.showExplanations,
      frameAnalysisInterval:
          frameAnalysisInterval ?? this.frameAnalysisInterval,
      enableBlurEffect: enableBlurEffect ?? this.enableBlurEffect,
      autoSkipFlagged: autoSkipFlagged ?? this.autoSkipFlagged,
    );
  }
}
