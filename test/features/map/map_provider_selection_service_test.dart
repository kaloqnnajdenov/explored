import 'package:explored/features/map/data/services/map_provider_selection_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('HttpMapProviderSelectionService', () {
    test('falls back to OSM when MAPTILER_KEY is missing', () async {
      var requested = false;
      final service = HttpMapProviderSelectionService(
        client: MockClient((request) async {
          requested = true;
          return http.Response('', 500);
        }),
      );

      final result = await service.resolveForSession(mapTilerKey: '  ');

      expect(requested, isFalse);
      expect(result.type, MapProviderType.openStreetMapFallback);
      expect(result.tileService, isA<OpenStreetMapTileService>());
    });

    test(
      'uses MapTiler when style probe succeeds with valid style json',
      () async {
        final service = HttpMapProviderSelectionService(
          client: MockClient((request) async {
            expect(
              request.url.toString(),
              'https://api.maptiler.com/maps/streets-v2/style.json?key=live-key',
            );
            return http.Response('{"version":8,"sources":{}}', 200);
          }),
        );

        final result = await service.resolveForSession(mapTilerKey: 'live-key');

        expect(result.type, MapProviderType.mapTiler);
        expect(result.tileService, isA<MapTilerTileService>());
        expect(
          result.tileService.getTileSource().urlTemplate,
          'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=live-key',
        );
      },
    );

    test('falls back to OSM when style probe returns non-200', () async {
      final service = HttpMapProviderSelectionService(
        client: MockClient((request) async {
          return http.Response('Unauthorized', 401);
        }),
      );

      final result = await service.resolveForSession(mapTilerKey: 'dead-key');

      expect(result.type, MapProviderType.openStreetMapFallback);
      expect(result.tileService, isA<OpenStreetMapTileService>());
    });

    test(
      'falls back to OSM when response is 200 but not a style json',
      () async {
        final service = HttpMapProviderSelectionService(
          client: MockClient((request) async {
            return http.Response('not-a-style', 200);
          }),
        );

        final result = await service.resolveForSession(
          mapTilerKey: 'bad-style',
        );

        expect(result.type, MapProviderType.openStreetMapFallback);
        expect(result.tileService, isA<OpenStreetMapTileService>());
      },
    );

    test('falls back to OSM when style probe times out', () async {
      final service = HttpMapProviderSelectionService(
        client: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 25));
          return http.Response('{"version":8,"sources":{}}', 200);
        }),
        timeout: const Duration(milliseconds: 1),
      );

      final result = await service.resolveForSession(mapTilerKey: 'slow-key');

      expect(result.type, MapProviderType.openStreetMapFallback);
      expect(result.tileService, isA<OpenStreetMapTileService>());
    });
  });
}
