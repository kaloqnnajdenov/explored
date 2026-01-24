import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/visited_grid/data/models/fog_of_war_style.dart';
import 'package:explored/features/visited_grid/data/services/fog_of_war_tile_raster_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Raster service returns PNG bytes for polygons', () async {
    final service = FogOfWarTileRasterService();
    final bytes = await service.rasterizeTile(
      polygons: [
        [
          const ui.Offset(8, 8),
          const ui.Offset(56, 8),
          const ui.Offset(56, 56),
          const ui.Offset(8, 56),
        ],
      ],
      tileSize: 64,
      style: const FogOfWarStyle(
        highlightColor: Color(0xFF1E88E5),
        highlightOpacity: 0.6,
        blurSigma: 3,
      ),
    );

    expect(bytes, isNotEmpty);
  });
}
