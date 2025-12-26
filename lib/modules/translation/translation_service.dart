// Halal Player - AI Translation Service
//
// Offline translation using Argos Translate or LibreTranslate

import 'dart:io';
import 'package:dio/dio.dart';

import '../subtitles/subtitle_model.dart';
import '../subtitles/subtitle_parser.dart';

/// Translation service interface
abstract class TranslationService {
  Future<String> translate(String text, String targetLanguage, {String? sourceLanguage});
  Future<String> detectLanguage(String text);
  Future<List<String>> getSupportedLanguages();
  Future<bool> isAvailable();
}

/// Argos Translate service (offline)
/// Note: Requires Python subprocess with argostranslate installed
class ArgosTranslateService implements TranslationService {
  ArgosTranslateService();

  @override
  Future<String> translate(
    String text, 
    String targetLanguage, 
    {String? sourceLanguage}
  ) async {
    // This would call argostranslate via Python subprocess
    // For now, return placeholder
    // TODO: Implement actual Argos Translate integration
    return text; // Placeholder
  }

  @override
  Future<String> detectLanguage(String text) async {
    // TODO: Implement language detection
    return 'en';
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    return ['en', 'ar', 'fr', 'de', 'es', 'tr', 'ru', 'zh', 'ja'];
  }

  @override
  Future<bool> isAvailable() async {
    // TODO: Check if Argos Translate is installed
    return false;
  }
}

/// LibreTranslate service (self-hosted or cloud)
class LibreTranslateService implements TranslationService {
  LibreTranslateService({
    this.baseUrl = 'http://localhost:5000',
    this.apiKey,
  }) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  final String baseUrl;
  final String? apiKey;
  final Dio _dio;

  @override
  Future<String> translate(
    String text, 
    String targetLanguage, 
    {String? sourceLanguage}
  ) async {
    try {
      final response = await _dio.post('/translate', data: {
        'q': text,
        'source': sourceLanguage ?? 'auto',
        'target': targetLanguage,
        if (apiKey != null) 'api_key': apiKey,
      });

      if (response.statusCode == 200) {
        return response.data['translatedText'] as String;
      }
      return text;
    } catch (e) {
      return text;
    }
  }

  @override
  Future<String> detectLanguage(String text) async {
    try {
      final response = await _dio.post('/detect', data: {
        'q': text,
        if (apiKey != null) 'api_key': apiKey,
      });

      if (response.statusCode == 200) {
        final detections = response.data as List;
        if (detections.isNotEmpty) {
          return detections.first['language'] as String;
        }
      }
      return 'en';
    } catch (e) {
      return 'en';
    }
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    try {
      final response = await _dio.get('/languages');
      if (response.statusCode == 200) {
        final languages = response.data as List;
        return languages.map((e) => e['code'] as String).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _dio.get('/languages');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Subtitle translator - translates entire subtitle tracks
class SubtitleTranslator {
  SubtitleTranslator({
    required this.translationService,
  });

  final TranslationService translationService;

  /// Translate entire subtitle track
  Future<SubtitleTrack> translateTrack(
    SubtitleTrack track,
    String targetLanguage, {
    String? sourceLanguage,
    void Function(int current, int total)? onProgress,
  }) async {
    final translatedEntries = <SubtitleEntry>[];
    final total = track.entries.length;

    for (var i = 0; i < total; i++) {
      final entry = track.entries[i];
      
      final translatedText = await translationService.translate(
        entry.text,
        targetLanguage,
        sourceLanguage: sourceLanguage,
      );

      translatedEntries.add(SubtitleEntry(
        index: entry.index,
        start: entry.start,
        end: entry.end,
        text: translatedText,
      ));

      onProgress?.call(i + 1, total);
    }

    return SubtitleTrack(
      entries: translatedEntries,
      language: targetLanguage,
      title: '${track.title ?? "Subtitles"} ($targetLanguage)',
    );
  }

  /// Translate and save to file
  Future<String?> translateAndSave(
    String inputPath,
    String targetLanguage, {
    String? outputPath,
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      // Parse input
      final track = await SubtitleParser.parseFile(inputPath);
      
      // Translate
      final translated = await translateTrack(
        track,
        targetLanguage,
        onProgress: onProgress,
      );

      // Generate output path
      final outPath = outputPath ?? inputPath.replaceFirst(
        RegExp(r'\.srt$'),
        '.$targetLanguage.srt',
      );

      // Save
      final content = generateSRT(translated);
      await File(outPath).writeAsString(content);

      return outPath;
    } catch (e) {
      return null;
    }
  }
}

/// Language names mapping
const Map<String, String> languageNames = {
  'en': 'English',
  'ar': 'العربية',
  'fr': 'Français',
  'de': 'Deutsch',
  'es': 'Español',
  'tr': 'Türkçe',
  'id': 'Bahasa Indonesia',
  'ms': 'Bahasa Melayu',
  'ur': 'اردو',
  'fa': 'فارسی',
  'bn': 'বাংলা',
  'zh': '中文',
  'ja': '日本語',
  'ru': 'Русский',
  'hi': 'हिंदी',
  'ko': '한국어',
  'pt': 'Português',
  'it': 'Italiano',
  'nl': 'Nederlands',
  'pl': 'Polski',
};
