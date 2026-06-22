// Halal Player - Subtitle Parser Tests

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:halal_player/modules/subtitles/subtitle_model.dart';
import 'package:halal_player/modules/subtitles/subtitle_parser.dart';
import 'package:path/path.dart' as p;

void main() {
  // ── Helper: write temp file ─────────────────────────────────────────────────
  Future<String> writeTempFile(String content, String ext) async {
    final dir = Directory.systemTemp;
    final file = File(p.join(dir.path, 'test_sub.$ext'));
    await file.writeAsString(content);
    return file.path;
  }

  // ── SRT Parsing ─────────────────────────────────────────────────────────────

  group('SRT Parser', () {
    const srtContent = '''
1
00:00:01,000 --> 00:00:03,000
Hello, world!

2
00:00:04,500 --> 00:00:06,000
This is a subtitle.

3
00:00:07,000 --> 00:00:09,000
Line one
Line two
''';

    test('parses correct number of entries', () async {
      final path = await writeTempFile(srtContent, 'srt');
      final track = await SubtitleParser.parseFile(path);
      expect(track.entries.length, 3);
    });

    test('parses index correctly', () async {
      final path = await writeTempFile(srtContent, 'srt');
      final track = await SubtitleParser.parseFile(path);
      expect(track.entries[0].index, 1);
      expect(track.entries[1].index, 2);
    });

    test('parses start time correctly', () async {
      final path = await writeTempFile(srtContent, 'srt');
      final track = await SubtitleParser.parseFile(path);
      expect(track.entries[0].start, const Duration(seconds: 1));
      expect(track.entries[1].start, const Duration(milliseconds: 4500));
    });

    test('parses end time correctly', () async {
      final path = await writeTempFile(srtContent, 'srt');
      final track = await SubtitleParser.parseFile(path);
      expect(track.entries[0].end, const Duration(seconds: 3));
    });

    test('parses single-line text correctly', () async {
      final path = await writeTempFile(srtContent, 'srt');
      final track = await SubtitleParser.parseFile(path);
      expect(track.entries[0].text.trim(), 'Hello, world!');
    });

    test('parses multi-line text correctly', () async {
      final path = await writeTempFile(srtContent, 'srt');
      final track = await SubtitleParser.parseFile(path);
      expect(track.entries[2].text, contains('Line one'));
      expect(track.entries[2].text, contains('Line two'));
    });

    test('returns empty track for empty file', () async {
      final path = await writeTempFile('', 'srt');
      final track = await SubtitleParser.parseFile(path);
      expect(track.entries, isEmpty);
    });

    test('handles missing file gracefully', () {
      expect(
        () => SubtitleParser.parseFile('/nonexistent/path.srt'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ── SRT Generation ───────────────────────────────────────────────────────────

  group('generateSRT', () {
    test('round-trips subtitle data', () {
      final entries = [
        SubtitleEntry(
          index: 1,
          start: const Duration(seconds: 1),
          end: const Duration(seconds: 3),
          text: 'Hello',
        ),
        SubtitleEntry(
          index: 2,
          start: const Duration(milliseconds: 4500),
          end: const Duration(seconds: 6),
          text: 'World',
        ),
      ];

      final track = SubtitleTrack(entries: entries);
      final srt = generateSRT(track);

      expect(srt, contains('00:00:01,000'));
      expect(srt, contains('Hello'));
      expect(srt, contains('World'));
    });

    test('empty track produces empty-ish string', () {
      final track = SubtitleTrack(entries: []);
      final srt = generateSRT(track);
      expect(srt.trim(), isEmpty);
    });
  });

  // ── SubtitleEntry helpers ────────────────────────────────────────────────────

  group('SubtitleEntry', () {
    test('isActiveAt returns true when position is between start and end', () {
      final entry = SubtitleEntry(
        index: 1,
        start: const Duration(seconds: 1),
        end: const Duration(seconds: 3),
        text: 'Test',
      );
      expect(entry.isActiveAt(const Duration(seconds: 2)), isTrue);
      expect(entry.isActiveAt(const Duration(milliseconds: 500)), isFalse);
      expect(entry.isActiveAt(const Duration(seconds: 4)), isFalse);
    });
  });
}
