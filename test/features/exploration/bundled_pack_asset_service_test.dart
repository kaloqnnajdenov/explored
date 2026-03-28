import 'dart:convert';

import 'package:explored/features/exploration/data/services/bundled_pack_asset_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this.assets);

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

const String _countryEntityNdjson = '''
{"entity_id":"country:relation:1","type":"country","osm_type":"relation","osm_id":1,"area_id":"1001","name":"Albania","admin_level":2,"bbox":[10.0,45.0,14.0,48.0],"centroid":[12.0,46.5],"country_id":null,"region_id":null,"city_id":null,"geometry":{"type":"Polygon","coordinates":[[[10.0,45.0],[14.0,45.0],[14.0,48.0],[10.0,48.0],[10.0,45.0]]]},"country_slug":"albania","pack_version":"2026.03.21"}
''';

const String _totalsNdjson = '''
{"entity_id":"country:relation:1","peaks_count":1,"huts_count":2,"monuments_count":3,"roads_drivable_length_m":4.0,"roads_walkable_length_m":5.0,"roads_cycleway_length_m":6.0}
''';

void main() {
  test('discovers packs from region_packs and falls back per layer', () async {
    final manifest = jsonEncode({
      'assets/region_packs/regions/albania/entities.ndjson': [
        'assets/region_packs/regions/albania/entities.ndjson',
      ],
      'assets/region_packs/objects/albania/peaks.ndjson': [
        'assets/region_packs/objects/albania/peaks.ndjson',
      ],
      'assets/entity_packs/stats/albania/entity_object_totals.ndjson': [
        'assets/entity_packs/stats/albania/entity_object_totals.ndjson',
      ],
      'assets/region_packs/regions/austria/entities.ndjson': [
        'assets/region_packs/regions/austria/entities.ndjson',
      ],
      'assets/region_packs/objects/austria/peaks.ndjson': [
        'assets/region_packs/objects/austria/peaks.ndjson',
      ],
    });
    final service = BundleBundledPackAssetService(
      assetBundle: _FakeAssetBundle({
        'AssetManifest.json': manifest,
        'assets/region_packs/regions/albania/entities.ndjson':
            _countryEntityNdjson,
        'assets/region_packs/objects/albania/peaks.ndjson':
            '{"object_id":"peak:node:1","category":"peak","geometry":{"type":"Point","coordinates":[11.0,46.0]},"country_slug":"albania"}\n',
        'assets/entity_packs/stats/albania/entity_object_totals.ndjson':
            _totalsNdjson,
        'assets/region_packs/regions/austria/entities.ndjson':
            _countryEntityNdjson
                .replaceAll('"albania"', '"austria"')
                .replaceAll('"Albania"', '"Austria"'),
        'assets/region_packs/objects/austria/peaks.ndjson':
            '{"object_id":"peak:node:2","category":"peak","geometry":{"type":"Point","coordinates":[11.0,46.0]},"country_slug":"austria"}\n',
      }),
    );

    final packs = await service.listCountryPacks();
    final albaniaObjects = await service.loadObjectPacks('albania');
    final albaniaTotals = await service.loadTotalsPack('albania');
    final austriaTotals = await service.loadTotalsPack('austria');

    expect(
      packs.map((pack) => pack.countrySlug),
      containsAll(<String>['albania', 'austria']),
    );
    expect(albaniaObjects.keys, contains('peaks.ndjson'));
    expect(albaniaTotals, _totalsNdjson);
    expect(austriaTotals, isEmpty);
  });
}
