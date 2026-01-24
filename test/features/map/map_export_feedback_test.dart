import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/translations/locale_keys.g.dart';
import '../../test_utils/localization_test_utils.dart';

void main() {
  testWidgets('export feedback snackbars render without overflow',
      (tester) async {
    final app = await buildLocalizedTestApp(
      Scaffold(
        body: Builder(
          builder: (context) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LocaleKeys.export_ready.tr()),
                      ),
                    );
                  },
                  child: const Text('show_ready'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.removeCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(LocaleKeys.export_failed.tr()),
                      ),
                    );
                  },
                  child: const Text('show_failed'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.removeCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(LocaleKeys.download_ready.tr()),
                      ),
                    );
                  },
                  child: const Text('show_download_ready'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.removeCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(LocaleKeys.download_failed.tr()),
                      ),
                    );
                  },
                  child: const Text('show_download_failed'),
                ),
              ],
            );
          },
        ),
      ),
    );

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app);

    await tester.tap(find.text('show_ready'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Export ready'), findsOneWidget);

    await tester.tap(find.text('show_failed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Export failed. Try again.'), findsOneWidget);

    await tester.tap(find.text('show_download_ready'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Download ready'), findsOneWidget);

    await tester.tap(find.text('show_download_failed'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Download failed. Try again.'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
