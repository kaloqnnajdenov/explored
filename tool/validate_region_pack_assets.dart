import 'dart:convert';
import 'dart:io';

const List<String> _requiredAssetPaths = <String>[
  'assets/region_packs/austria/manifest.json',
  'assets/region_packs/austria/regions/tyrol/metadata.json',
  'assets/region_packs/austria/regions/tyrol/cities/innsbruck/city.geojson',
];

Future<void> main() async {
  final assetManifestFile = File(
    'build${Platform.pathSeparator}unit_test_assets${Platform.pathSeparator}AssetManifest.json',
  );
  if (!assetManifestFile.existsSync()) {
    stderr.writeln(
      'Missing build/unit_test_assets/AssetManifest.json. Run a Flutter test or build first.',
    );
    exitCode = 1;
    return;
  }

  final rawManifest = await assetManifestFile.readAsString();
  final manifest = jsonDecode(rawManifest) as Map<String, dynamic>;
  final manifestKeys = manifest.keys.toSet();
  final missingPaths = _requiredAssetPaths
      .where((assetPath) => !manifestKeys.contains(assetPath))
      .toList(growable: false);

  if (missingPaths.isNotEmpty) {
    stderr.writeln('Missing region-pack assets from built AssetManifest.json:');
    for (final assetPath in missingPaths) {
      stderr.writeln(assetPath);
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Validated ${_requiredAssetPaths.length} representative region-pack assets in build/unit_test_assets/AssetManifest.json.',
  );
}
