class FogOfWarTileKey {
  const FogOfWarTileKey({
    required this.x,
    required this.y,
    required this.z,
    required this.tileSize,
    required this.styleId,
  });

  final int x;
  final int y;
  final int z;
  final int tileSize;
  final String styleId;

  String get cacheKey => 'z$z/x$x/y$y/s$tileSize/$styleId';

  @override
  bool operator ==(Object other) {
    return other is FogOfWarTileKey && other.cacheKey == cacheKey;
  }

  @override
  int get hashCode => cacheKey.hashCode;
}
