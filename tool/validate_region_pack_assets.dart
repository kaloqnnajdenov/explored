import 'dart:convert';
import 'dart:io';

const int _minimumBundledCountryCount = 8;
const List<String> _representativeAssetPaths = <String>[
  'assets/region_packs/regions/andorra/entities.ndjson',
  'assets/region_packs/regions/albania/entities.ndjson',
  'assets/region_packs/regions/croatia/entities.ndjson',
  'assets/region_packs/objects/croatia/peaks.ndjson',
  'assets/region_packs/stats/croatia/entity_object_totals.ndjson',
];

Future<void> main() async {
  final assetManifestFile = File(
    'build${Platform.pathSeparator}flutter_assets${Platform.pathSeparator}AssetManifest.json',
  );
  if (!assetManifestFile.existsSync()) {
    stderr.writeln(
      'Missing build/flutter_assets/AssetManifest.json. Run flutter build bundle first.',
    );
    exitCode = 1;
    return;
  }

  final rawManifest = await assetManifestFile.readAsString();
  final manifest = jsonDecode(rawManifest) as Map<String, dynamic>;
  final manifestKeys = manifest.keys.toSet();
  final missingPaths = _representativeAssetPaths
      .where((assetPath) => !manifestKeys.contains(assetPath))
      .toList(growable: false);
  final bundledCountrySlugs = manifestKeys
      .where(
        (assetPath) =>
            assetPath.startsWith('assets/region_packs/regions/') &&
            assetPath.endsWith('/entities.ndjson'),
      )
      .map(_extractCountrySlug)
      .whereType<String>()
      .toSet();

  if (missingPaths.isNotEmpty) {
    stderr.writeln('Missing region-pack assets from built AssetManifest.json:');
    for (final assetPath in missingPaths) {
      stderr.writeln(assetPath);
    }
    exitCode = 1;
    return;
  }
  if (bundledCountrySlugs.length < _minimumBundledCountryCount) {
    stderr.writeln(
      'Expected at least $_minimumBundledCountryCount bundled country packs, '
      'but found ${bundledCountrySlugs.length}.',
    );
    stderr.writeln(
      'Bundled countries: ${bundledCountrySlugs.toList()..sort()}',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Validated ${bundledCountrySlugs.length} bundled country packs and '
    '${_representativeAssetPaths.length} representative assets in '
    'build/flutter_assets/AssetManifest.json.',
  );
}

String? _extractCountrySlug(String assetPath) {
  final parts = assetPath.split('/');
  if (parts.length < 5) {
    return null;
  }
  if (parts[0] != 'assets' ||
      parts[1] != 'region_packs' ||
      parts[2] != 'regions') {
    return null;
  }
  return parts[3];
}
