import 'package:explored/features/onboarding/view/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test_utils/localization_test_utils.dart';

void main() {
  testWidgets('skip and next actions navigate correctly', (tester) async {
    await loadTestTranslations();

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const OnboardingView()),
        GoRoute(
          path: '/permissions',
          builder: (_, __) => const Scaffold(body: Text('permissions_screen')),
        ),
      ],
    );

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text("Track where you've been"), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(router.routeInformationProvider.value.uri.path, '/permissions');
    expect(tester.takeException(), isNull);
  });
}
