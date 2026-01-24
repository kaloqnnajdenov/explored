import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/features/map/view/widgets/map_scale_indicator.dart';
import '../../test_utils/localization_test_utils.dart';

void main() {
  testWidgets('map scale indicator text fits without overflow', (tester) async {
    final app = await buildLocalizedTestApp(
      Scaffold(
        body: SizedBox(
          width: 320,
          height: 320,
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(0, 0),
              initialZoom: 13,
            ),
            children: const [
              MapScaleIndicator(),
            ],
          ),
        ),
      ),
    );
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app);
    await tester.pump();

    final labelFinder = find.descendant(
      of: find.byType(MapScaleIndicator),
      matching: find.byType(Text),
    );
    expect(labelFinder, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
