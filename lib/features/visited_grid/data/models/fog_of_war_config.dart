import 'dart:ui';

import 'fog_of_war_style.dart';

class FogOfWarConfig {
  const FogOfWarConfig({
    this.minZoom = 2,
    this.maxZoom = 18,
    this.defaultTileSize = 256,
    this.cacheMaxEntries = 200,
    this.specialModeMaxZoom = 8,
    this.lowZoomOpacityMultiplier = 1.6,
    FogOfWarStyle? style,
  }) : style = style ?? const FogOfWarStyle(
          highlightColor: Color(0xFF1E88E5),
          highlightOpacity: 0.5,
          blurSigma: 18.0,
        );

  final int minZoom;
  final int maxZoom;
  final int defaultTileSize;
  final int cacheMaxEntries;
  final int specialModeMaxZoom;
  final double lowZoomOpacityMultiplier;
  final FogOfWarStyle style;
}
