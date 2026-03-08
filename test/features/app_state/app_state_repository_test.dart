import 'dart:convert';

import 'package:explored/features/app_state/data/repositories/app_state_repository.dart';
import 'package:explored/features/app_state/data/services/app_state_prefs_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('load returns seeded regions and defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = DefaultAppStateRepository(
      prefsService: AppStatePrefsService(preferences: preferences),
    );

    final snapshot = await repository.load();

    expect(snapshot.hasSeenOnboarding, isFalse);
    expect(snapshot.regions.length, 6);
    expect(snapshot.currentRegionId, snapshot.regions.first.id);
    expect(snapshot.userPoints, isEmpty);
  });

  test(
    'load applies persisted region selection, downloads, and user points',
    () async {
      final points = [
        {
          'id': 'p1',
          'latitude': 47.1,
          'longitude': 11.2,
          'createdAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
      ];

      SharedPreferences.setMockInitialValues({
        AppStatePrefsService.hasSeenOnboardingKey: true,
        AppStatePrefsService.currentRegionIdKey: 'otztal-alps',
        AppStatePrefsService.downloadedRegionIdsKey: ['otztal-alps'],
        AppStatePrefsService.userPointsKey: jsonEncode(points),
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = DefaultAppStateRepository(
        prefsService: AppStatePrefsService(preferences: preferences),
      );

      final snapshot = await repository.load();

      expect(snapshot.hasSeenOnboarding, isTrue);
      expect(snapshot.currentRegionId, 'otztal-alps');
      expect(
        snapshot.regions
            .firstWhere((region) => region.id == 'otztal-alps')
            .isDownloaded,
        isTrue,
      );
      expect(snapshot.userPoints.length, 1);
      expect(snapshot.userPoints.first.id, 'p1');
    },
  );
}
