import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/view/widgets/tracked_history_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets(
    'renders tile, tracked points, current location marker, and base layers',
    (tester) async {
      final app = MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 240,
            child: TrackedHistoryMap(
              tileSource: MapTileSource(
                urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
                subdomains: ['a'],
                userAgentPackageName: 'com.explored.test',
                tileProvider: TestTileProvider(),
              ),
              persistedSamples: [buildSample(latitude: 42.1, longitude: 23.1)],
              currentLocation: const LatLng(42.2, 23.2),
              initialCenter: const LatLng(42.0, 23.0),
              initialZoom: 10,
              baseLayers: [
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: const [
                        LatLng(42.3, 23.0),
                        LatLng(42.3, 23.3),
                        LatLng(42.0, 23.3),
                        LatLng(42.0, 23.0),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pump();

      expect(find.byType(TileLayer), findsOneWidget);
      expect(find.byType(CircleLayer), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byType(PolygonLayer), findsOneWidget);
    },
  );
}
