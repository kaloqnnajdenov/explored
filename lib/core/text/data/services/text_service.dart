import 'package:flutter/services.dart';

/// Low-level text loader abstraction (asset/network); keeps IO away from
/// repositories.
abstract class TextService {
  Future<String> fetchText({required String locale, required String key});
}

/// AssetBundle-backed text loader for simple key->file lookups.
class AssetTextService implements TextService {
  AssetTextService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  @override
  Future<String> fetchText({
    required String locale,
    required String key,
  }) async {
    final path = 'assets/text/$locale/$key.txt';
    final content = await _bundle.loadString(path);
    return content.trim();
  }
}
