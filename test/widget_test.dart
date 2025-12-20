import 'dart:typed_data';

import 'package:explored/core/text/data/repositories/text_repository.dart';
import 'package:explored/core/text/data/services/text_service.dart';
import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/map/view/map_view.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MapView renders OpenStreetMap layer on launch', (
    WidgetTester tester,
  ) async {
    final viewModel = MapViewModel(
      mapRepository: MapRepository(
        tileService: _FakeMapTileService(),
        attributionService: _FakeMapAttributionService(),
      ),
      textRepository: TextRepository(textService: _FakeTextService()),
      locale: const Locale('en'),
    );

    await tester.pumpWidget(MaterialApp(home: MapView(viewModel: viewModel)));

    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Map data from') &&
            widget.text.toPlainText().contains('OpenStreetMap'),
      ),
      findsOneWidget,
    );
  });
}

/// Simple fake that returns a deterministic tile source.
class _FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.example.test',
      tileProvider: _FakeTileProvider(),
    );
  }
}

/// Returns a fixed attribution text for widget test scaffolding.
class _FakeTextService implements TextService {
  @override
  Future<String> fetchText({
    required String locale,
    required String key,
  }) async {
    if (key == 'map_attribution') {
      return 'Map data from';
    }

    if (key == 'map_attribution_source') {
      return 'OpenStreetMap';
    }

    return 'Test text';
  }
}

/// In-memory tile provider that serves a transparent 1x1 PNG to avoid network.
class _FakeTileProvider extends TileProvider {
  static final Uint8List _transparentImage = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1f,
    0x15,
    0xc4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0a,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9c,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0d,
    0x0a,
    0x2d,
    0xb4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4e,
    0x44,
    0xae,
    0x42,
    0x60,
    0x82,
  ]);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MemoryImage(_transparentImage);
  }
}

class _FakeMapAttributionService implements MapAttributionService {
  @override
  Future<void> openAttribution() async {}
}
