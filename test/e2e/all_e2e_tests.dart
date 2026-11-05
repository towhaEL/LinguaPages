import 'package:flutter_test/flutter_test.dart';

import 'tier1_features/audio_settings_paywall_test.dart' as t1_audio;
import 'tier1_features/library_and_books_test.dart' as t1_library;
import 'tier1_features/onboarding_carousel_test.dart' as t1_onboarding;
import 'tier1_features/reader_and_overlays_test.dart' as t1_reader;
import 'tier1_features/tokens_and_theme_test.dart' as t1_tokens;
import 'tier2_boundary/boundary_and_corners_test.dart' as t2_boundary;
import 'tier3_cross_feature/cross_feature_sync_test.dart' as t3_cross;
import 'tier4_scenarios/user_journeys_test.dart' as t4_journeys;

void main() {
  group('OpenPages E2E Test Suite - Master Suite', () {
    group('Tier 1: Feature Coverage (Features 1–32)', () {
      t1_tokens.main();
      t1_onboarding.main();
      t1_library.main();
      t1_reader.main();
      t1_audio.main();
    });

    group('Tier 2: Boundary & Corner Cases', () {
      t2_boundary.main();
    });

    group('Tier 3: Cross-Feature Combinations', () {
      t3_cross.main();
    });

    group('Tier 4: Real-World Application Scenarios', () {
      t4_journeys.main();
    });
  });
}
