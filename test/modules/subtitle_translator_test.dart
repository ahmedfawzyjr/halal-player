// Halal Player - Subtitle Translator Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:halal_player/modules/subtitles/subtitle_model.dart';
import 'package:halal_player/modules/translation/translation_service.dart';

// ── Fake translation service ─────────────────────────────────────────────────

class _FakeTranslationService implements TranslationService {
  final List<String> _calls = [];

  List<String> get translatedTexts => List.unmodifiable(_calls);

  @override
  Future<String> translate(
    String text,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    final result = '[$targetLanguage] $text';
    _calls.add(result);
    return result;
  }

  @override
  Future<String> detectLanguage(String text) async => 'en';

  @override
  Future<List<String>> getSupportedLanguages() async => ['en', 'ar'];

  @override
  Future<bool> isAvailable() async => true;
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('SubtitleTranslator', () {
    late _FakeTranslationService fakeService;
    late SubtitleTranslator translator;

    SubtitleTrack makeTrack(List<String> texts) {
      return SubtitleTrack(
        entries: texts.asMap().entries.map((e) {
          return SubtitleEntry(
            index: e.key + 1,
            start: Duration(seconds: e.key * 2),
            end: Duration(seconds: e.key * 2 + 1),
            text: e.value,
          );
        }).toList(),
      );
    }

    setUp(() {
      fakeService = _FakeTranslationService();
      translator = SubtitleTranslator(translationService: fakeService);
    });

    test('translates all entries', () async {
      final track = makeTrack(['Hello', 'World', 'Foo']);
      final translated = await translator.translateTrack(track, 'ar');
      expect(translated.entries.length, 3);
    });

    test('translated text contains target language prefix', () async {
      final track = makeTrack(['Hello']);
      final translated = await translator.translateTrack(track, 'ar');
      expect(translated.entries[0].text, contains('[ar]'));
    });

    test('preserves entry indices', () async {
      final track = makeTrack(['A', 'B', 'C']);
      final translated = await translator.translateTrack(track, 'fr');
      expect(translated.entries[0].index, 1);
      expect(translated.entries[1].index, 2);
      expect(translated.entries[2].index, 3);
    });

    test('preserves entry timestamps', () async {
      final track = makeTrack(['Hello']);
      final translated = await translator.translateTrack(track, 'ar');
      expect(translated.entries[0].start, track.entries[0].start);
      expect(translated.entries[0].end, track.entries[0].end);
    });

    test('reports progress correctly', () async {
      final track = makeTrack(['A', 'B', 'C', 'D']);
      final progress = <int>[];
      await translator.translateTrack(
        track,
        'ar',
        onProgress: (cur, total) => progress.add(cur),
      );
      expect(progress, [1, 2, 3, 4]);
    });

    test('handles empty track without error', () async {
      final track = SubtitleTrack(entries: []);
      final translated = await translator.translateTrack(track, 'ar');
      expect(translated.entries, isEmpty);
    });

    test('sets target language on translated track', () async {
      final track = makeTrack(['Hello']);
      final translated = await translator.translateTrack(track, 'ar');
      expect(translated.language, 'ar');
    });

    test('translation service is called for each entry', () async {
      final track = makeTrack(['A', 'B', 'C']);
      await translator.translateTrack(track, 'ar');
      expect(fakeService.translatedTexts.length, 3);
    });
  });
}
