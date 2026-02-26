import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'map_tile_service.dart';

enum MapProviderType { mapTiler, openStreetMapFallback }

class ResolvedMapProvider {
  const ResolvedMapProvider({
    required this.type,
    required this.tileService,
    required this.attributionUri,
  });

  final MapProviderType type;
  final MapTileService tileService;
  final Uri attributionUri;

  bool get isFallback => type == MapProviderType.openStreetMapFallback;
}

abstract class MapProviderSelectionService {
  Future<ResolvedMapProvider> resolveForSession({required String mapTilerKey});
}

/// Resolves map provider once per app launch:
/// try MapTiler first, otherwise use OpenStreetMap fallback.
class HttpMapProviderSelectionService implements MapProviderSelectionService {
  HttpMapProviderSelectionService({
    http.Client? client,
    Duration timeout = const Duration(seconds: 4),
  }) : _client = client ?? http.Client(),
       _timeout = timeout;

  final http.Client _client;
  final Duration _timeout;

  static final Uri _mapTilerAttributionUri = Uri.parse(
    'https://www.maptiler.com/copyright/',
  );
  static final Uri _osmAttributionUri = Uri.parse(
    'https://www.openstreetmap.org/copyright',
  );

  @override
  Future<ResolvedMapProvider> resolveForSession({
    required String mapTilerKey,
  }) async {
    final key = mapTilerKey.trim();
    if (key.isEmpty) {
      return _fallback('MAPTILER_KEY is missing.');
    }

    final styleUri = Uri.parse(
      'https://api.maptiler.com/maps/streets-v2/style.json?key=$key',
    );

    try {
      final response = await _client.get(styleUri).timeout(_timeout);
      if (response.statusCode == 200 && _looksLikeStyleJson(response.body)) {
        return ResolvedMapProvider(
          type: MapProviderType.mapTiler,
          tileService: MapTilerTileService(apiKey: key),
          attributionUri: _mapTilerAttributionUri,
        );
      }

      return _fallback(
        'MapTiler style probe returned status ${response.statusCode}.',
      );
    } on TimeoutException {
      return _fallback('MapTiler style probe timed out.');
    } catch (error) {
      return _fallback('MapTiler style probe failed: $error');
    }
  }

  bool _looksLikeStyleJson(String value) {
    return value.contains('"version"') && value.contains('"sources"');
  }

  ResolvedMapProvider _fallback(String reason) {
    debugPrint(
      'MapTiler unavailable for this session. Falling back to OSM: $reason',
    );
    return ResolvedMapProvider(
      type: MapProviderType.openStreetMapFallback,
      tileService: OpenStreetMapTileService(),
      attributionUri: _osmAttributionUri,
    );
  }
}
