import 'package:flutter_map/flutter_map.dart';

/// Describes how to fetch map tiles, independent of any specific provider.
class MapTileSource {
  const MapTileSource({
    required this.urlTemplate,
    required this.subdomains,
    required this.userAgentPackageName,
    this.tileProvider,
  });

  final String urlTemplate;
  final List<String> subdomains;
  final String userAgentPackageName;
  final TileProvider? tileProvider;
}
