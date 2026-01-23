import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/map/view/widgets/map_menu_button.dart';
import '../../test_utils/localization_test_utils.dart';

void main() {
  testWidgets('menu button text fits without overflow', (tester) async {
    MapMenuAction? selected;
    final app = await buildLocalizedTestApp(
      Scaffold(
        body: Align(
          alignment: Alignment.topRight,
          child: MapMenuButton(
            onActionSelected: (action) => selected = action,
          ),
        ),
      ),
    );
    tester.binding.window.physicalSizeTestValue = const Size(320, 640);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

    await tester.pumpWidget(app);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Permissions management'), findsOneWidget);
    expect(find.text('Import GPX file'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(selected, isNull);
    expect(tester.takeException(), isNull);
  });
}
