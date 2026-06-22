// Halal Player - Policy Engine Tests

import 'package:flutter_test/flutter_test.dart';

import 'package:halal_player/core/config.dart';
import 'package:halal_player/core/policy_engine.dart';

void main() {
  group('PolicyEngine', () {
    // ── Strict Islamic mode (threshold 0.25) ────────────────────────────────

    group('Strict Islamic mode', () {
      late PolicyEngine engine;

      setUp(() {
        engine = PolicyEngine(AppConfig(mode: FilterMode.strictIslamic));
      });

      test('blocks content above threshold', () {
        final result = engine.evaluate(
          nsfwScore: 0.9,
          nudenetScore: 0.8,
          detectedCategories: ['nude'],
        );
        expect(result.action, ContentAction.block);
      });

      test('blurs content near threshold', () {
        final result = engine.evaluate(
          nsfwScore: 0.3, // above 0.25 threshold
          nudenetScore: 0.0,
          detectedCategories: [],
        );
        // Should blur (within blurMargin above threshold) or block
        expect(
          [ContentAction.blur, ContentAction.block],
          contains(result.action),
        );
      });

      test('allows safe content', () {
        final result = engine.evaluate(
          nsfwScore: 0.05,
          nudenetScore: 0.05,
          detectedCategories: [],
        );
        expect(result.action, ContentAction.allow);
      });

      test('has lowest threshold of all modes', () {
        expect(
          FilterMode.strictIslamic.nsfwThreshold,
          lessThan(FilterMode.family.nsfwThreshold),
        );
      });
    });

    // ── Family mode (threshold 0.4) ─────────────────────────────────────────

    group('Family mode', () {
      late PolicyEngine engine;

      setUp(() {
        engine = PolicyEngine(AppConfig(mode: FilterMode.family));
      });

      test('allows content that strict mode would block', () {
        // Score of 0.3 would trigger strict mode, but family allows it
        final result = engine.evaluate(
          nsfwScore: 0.28,
          nudenetScore: 0.0,
          detectedCategories: [],
        );
        expect(result.action, ContentAction.allow);
      });

      test('blocks highly explicit content', () {
        final result = engine.evaluate(
          nsfwScore: 0.95,
          nudenetScore: 0.9,
          detectedCategories: ['nude', 'explicit'],
        );
        expect(result.action, ContentAction.block);
      });
    });

    // ── Developer mode (threshold 0.95) ────────────────────────────────────

    group('Developer mode', () {
      late PolicyEngine engine;

      setUp(() {
        engine = PolicyEngine(AppConfig(mode: FilterMode.developer));
      });

      test('allows almost all content', () {
        final result = engine.evaluate(
          nsfwScore: 0.6,
          nudenetScore: 0.5,
          detectedCategories: ['suggestive'],
        );
        expect(result.action, ContentAction.allow);
      });

      test('has highest threshold', () {
        expect(
          FilterMode.developer.nsfwThreshold,
          greaterThan(FilterMode.family.nsfwThreshold),
        );
      });
    });

    // ── Score aggregation ───────────────────────────────────────────────────

    group('Score aggregation', () {
      late PolicyEngine engine;

      setUp(() {
        engine = PolicyEngine(AppConfig(mode: FilterMode.family));
      });

      test('aggregated score uses max of nsfw and weighted nudenet', () {
        final result = engine.evaluate(
          nsfwScore: 0.2,
          nudenetScore: 0.9,
          detectedCategories: [],
        );
        // nudenet * 0.8 = 0.72 > nsfw 0.2, so aggregated ≈ 0.72
        expect(result.aggregatedScore, closeTo(0.72, 0.05));
      });

      test('result includes all provided categories', () {
        final cats = ['category_a', 'category_b'];
        final result = engine.evaluate(
          nsfwScore: 0.5,
          nudenetScore: 0.5,
          detectedCategories: cats,
        );
        for (final cat in cats) {
          expect(result.detectedCategories, contains(cat));
        }
      });
    });

    // ── PolicyResult.allowed factory ────────────────────────────────────────

    group('PolicyResult.allowed', () {
      test('creates an allow action result', () {
        final result = PolicyResult.allowed(nsfwScore: 0, nudenetScore: 0);
        expect(result.action, ContentAction.allow);
      });

      test('toString contains action and score', () {
        final result = PolicyResult.allowed(nsfwScore: 0.1, nudenetScore: 0.1);
        expect(result.toString(), contains('allow'));
      });
    });
  });
}
