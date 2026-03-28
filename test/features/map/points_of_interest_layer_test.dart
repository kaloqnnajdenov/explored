import 'package:explored/domain/objects/object_category.dart';
import 'package:explored/features/map/data/models/map_point_of_interest_marker.dart';
import 'package:explored/features/map/view/widgets/points_of_interest_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../test_utils/map_test_doubles.dart';

void main() {
  testWidgets('renders count bubble for clustered markers', (tester) async {
    final app = MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          height: 240,
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(42.0, 23.0),
              initialZoom: 6,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
                subdomains: const ['a'],
                userAgentPackageName: 'com.explored.test',
                tileProvider: TestTileProvider(),
              ),
              PointsOfInterestLayer(
                pointMarkers: [
                  MapPointOfInterestMarker.cluster(
                    id: 'monuments-1',
                    category: ObjectCategory.monument,
                    position: const LatLng(42.0, 23.0),
                    count: 12,
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

    expect(find.text('12'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance), findsNothing);
  });
}
