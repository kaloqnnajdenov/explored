import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _BundleAssetLoader extends AssetLoader {
  const _BundleAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final raw = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    return Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>);
  }
}

Future<Map<String, dynamic>> _loadEnglishTranslations() async {
  final raw = await rootBundle.loadString('assets/translations/en.json');
  return Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>);
}

Future<void> loadTestTranslations() async {
  WidgetsFlutterBinding.ensureInitialized();
  final translations = await _loadEnglishTranslations();
  Localization.load(
    const Locale('en'),
    translations: Translations(translations),
    fallbackTranslations: Translations(translations),
  );
}

Future<Widget> buildLocalizedTestApp(Widget child) async {
  await loadTestTranslations();
  return MaterialApp(home: child);
}

Future<Widget> buildLocalizedTestRoot(Widget child) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _BundleAssetLoader(),
    child: child,
  );
}
