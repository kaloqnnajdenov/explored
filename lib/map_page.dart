import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

/// `tile.openstreetmap.org` is suitable as a fallback/demo tile source.
/// For production scale traffic, use a proper tile provider or self-host tiles.
const String kOsmRasterStyle = '''
{
  "version": 8,
  "sources": {
    "osm": {
      "type": "raster",
      "tiles": ["https://tile.openstreetmap.org/{z}/{x}/{y}.png"],
      "tileSize": 256,
      "attribution": "© OpenStreetMap contributors"
    }
  },
  "layers": [
    {
      "id": "osm-tiles",
      "type": "raster",
      "source": "osm"
    }
  ]
}
''';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _mapTilerStyleEndpoint =
      'https://api.maptiler.com/maps/streets-v2/style.json';

  String _styleString = kOsmRasterStyle;
  bool _usingOsmFallback = true;
  bool _styleReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStyle());
  }

  Future<void> _loadStyle() async {
    final key = (dotenv.env['MAPTILER_KEY'] ?? '').trim();
    if (key.isEmpty) {
      _useOsmFallback('missing MAPTILER_KEY');
      return;
    }

    final uri = Uri.parse('$_mapTilerStyleEndpoint?key=$key');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      final body = response.body;
      final shouldUseMapTiler =
          response.statusCode == 200 && _looksLikeMapStyle(body);

      if (shouldUseMapTiler) {
        if (!mounted) {
          return;
        }
        setState(() {
          _styleString = body;
          _usingOsmFallback = false;
          _styleReady = true;
        });
        return;
      }

      _useOsmFallback(
        'MapTiler style request failed with status ${response.statusCode}',
      );
    } on TimeoutException {
      _useOsmFallback('MapTiler style request timed out');
    } catch (error) {
      _useOsmFallback('MapTiler style request error: $error');
    }
  }

  bool _looksLikeMapStyle(String rawStyleJson) {
    return rawStyleJson.contains('"version"') &&
        rawStyleJson.contains('"sources"');
  }

  void _useOsmFallback(String reason) {
    debugPrint(
      'MapTiler unavailable. Falling back to OSM raster style: $reason',
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _styleString = kOsmRasterStyle;
      _usingOsmFallback = true;
      _styleReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_styleReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _styleString,
            initialCameraPosition: const CameraPosition(
              target: LatLng(52.52, 13.405),
              zoom: 11,
            ),
            onStyleLoadedCallback: () {
              debugPrint('Map style loaded.');
            },
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: AttributionPill(
              text: _usingOsmFallback
                  ? '© OpenStreetMap contributors'
                  : '© MapTiler © OpenStreetMap contributors',
            ),
          ),
        ],
      ),
    );
  }
}

class AttributionPill extends StatelessWidget {
  const AttributionPill({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
