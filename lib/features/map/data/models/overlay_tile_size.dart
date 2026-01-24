enum OverlayTileSize {
  s256(256),
  s512(512);

  const OverlayTileSize(this.size);

  final int size;

  static OverlayTileSize fromSize(int size) {
    if (size >= 512) {
      return OverlayTileSize.s512;
    }
    return OverlayTileSize.s256;
  }
}
