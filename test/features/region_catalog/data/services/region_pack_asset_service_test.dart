import 'dart:convert';

import 'package:explored/features/region_catalog/data/services/region_pack_asset_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw StateError('Missing asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}

void main() {
  test('loadAssetKeys keeps only region pack assets', () async {
    final manifest = jsonEncode({
      'assets/region_packs/testland/manifest.json': [
        'assets/region_packs/testland/manifest.json',
      ],
      'assets/region_packs/testland/country.geojson': [
        'assets/region_packs/testland/country.geojson',
      ],
      'assets/translations/en.json': ['assets/translations/en.json'],
    });
    final service = BundleRegionPackAssetService(
      assetBundle: FakeAssetBundle({'AssetManifest.json': manifest}),
    );

    final assetKeys = await service.loadAssetKeys();

    expect(assetKeys, hasLength(2));
    expect(assetKeys, contains('assets/region_packs/testland/manifest.json'));
    expect(assetKeys, isNot(contains('assets/translations/en.json')));
  });

  test('loadBoundary parses multipolygons and holes', () async {
    final geoJson = jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'MultiPolygon',
            'coordinates': [
              [
                [
                  [0.0, 0.0],
                  [2.0, 0.0],
                  [2.0, 2.0],
                  [0.0, 2.0],
                  [0.0, 0.0],
                ],
                [
                  [0.5, 0.5],
                  [1.5, 0.5],
                  [1.5, 1.5],
                  [0.5, 1.5],
                  [0.5, 0.5],
                ],
              ],
              [
                [
                  [3.0, 3.0],
                  [4.0, 3.0],
                  [4.0, 4.0],
                  [3.0, 4.0],
                  [3.0, 3.0],
                ],
              ],
            ],
          },
        },
      ],
    });
    final service = BundleRegionPackAssetService(
      assetBundle: FakeAssetBundle({
        'AssetManifest.json': jsonEncode({}),
        'assets/region_packs/testland/country.geojson': geoJson,
      }),
    );

    final boundary = await service.loadBoundary(
      'assets/region_packs/testland/country.geojson',
    );

    expect(boundary.polygons, hasLength(2));
    expect(boundary.polygons.first.outerRing, hasLength(4));
    expect(boundary.polygons.first.holeRings, hasLength(1));
    expect(boundary.polygons.first.holeRings.first, hasLength(4));
  });
}
