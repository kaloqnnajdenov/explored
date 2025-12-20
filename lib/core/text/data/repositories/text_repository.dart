import '../services/text_service.dart';

/// Caches and serves text strings; shields ViewModels from IO details.
class TextRepository {
  TextRepository({required TextService textService})
    : _textService = textService;

  final TextService _textService;
  final Map<String, String> _cache = {};

  /// Returns localized text, caching per locale/key to avoid repeated IO.
  Future<String> getText({required String key, String locale = 'en'}) async {
    final cacheKey = '$locale/$key';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final text = await _textService.fetchText(locale: locale, key: key);
    _cache[cacheKey] = text;
    return text;
  }
}
