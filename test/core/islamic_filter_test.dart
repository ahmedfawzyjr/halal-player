// Halal Player - Islamic Subtitle Filter Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:halal_player/modules/subtitles/subtitle_model.dart';
import 'package:halal_player/modules/subtitles/subtitle_provider.dart';

void main() {
  group('IslamicSubtitleFilter', () {
    group('filter()', () {
      test('replaces exact blocked word with ***', () {
        final result = IslamicSubtitleFilter.filter('You sex me off');
        expect(result, contains('***'));
        expect(result, isNot(contains('sex')));
      });

      test('is case-insensitive', () {
        final upper = IslamicSubtitleFilter.filter('SEX and violence');
        final lower = IslamicSubtitleFilter.filter('sex and violence');
        expect(upper, contains('***'));
        expect(lower, contains('***'));
      });

      test('does not modify clean text', () {
        const clean = 'This is a clean subtitle';
        expect(IslamicSubtitleFilter.filter(clean), clean);
      });

      test('replaces multiple occurrences in same line', () {
        final result = IslamicSubtitleFilter.filter('nude nude nude');
        // Every occurrence should be replaced
        expect(result, isNot(contains('nude')));
      });

      test('handles empty string', () {
        expect(IslamicSubtitleFilter.filter(''), '');
      });
    });

    group('filterTrack()', () {
      SubtitleTrack makeTrack(List<String> texts) {
        return SubtitleTrack(
          entries: texts.asMap().entries.map((e) {
            return SubtitleEntry(
              index: e.key + 1,
              start: Duration(seconds: e.key),
              end: Duration(seconds: e.key + 1),
              text: e.value,
            );
          }).toList(),
        );
      }

      test('filters all entries in the track', () {
        final track = makeTrack(['Clean text', 'This is sex']);
        final filtered = IslamicSubtitleFilter.filterTrack(track);
        expect(filtered.entries[0].text, 'Clean text');
        expect(filtered.entries[1].text, contains('***'));
        expect(filtered.entries[1].text, isNot(contains('sex')));
      });

      test('preserves timestamps after filtering', () {
        final track = makeTrack(['nude', 'clean']);
        final filtered = IslamicSubtitleFilter.filterTrack(track);
        expect(filtered.entries[0].start, track.entries[0].start);
        expect(filtered.entries[0].end, track.entries[0].end);
      });

      test('preserves entry indices', () {
        final track = makeTrack(['text a', 'text b', 'text c']);
        final filtered = IslamicSubtitleFilter.filterTrack(track);
        for (int i = 0; i < 3; i++) {
          expect(filtered.entries[i].index, track.entries[i].index);
        }
      });

      test('empty track returns empty track', () {
        final track = SubtitleTrack(entries: []);
        final filtered = IslamicSubtitleFilter.filterTrack(track);
        expect(filtered.entries, isEmpty);
      });
    });
  });
}
