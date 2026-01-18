enum VisitedOverlayRenderMode {
  perCell,
  merged;

  String toWire() {
    return switch (this) {
      VisitedOverlayRenderMode.perCell => 'perCell',
      VisitedOverlayRenderMode.merged => 'merged',
    };
  }

  static VisitedOverlayRenderMode fromWire(String value) {
    return switch (value) {
      'perCell' => VisitedOverlayRenderMode.perCell,
      'merged' => VisitedOverlayRenderMode.merged,
      _ => throw ArgumentError.value(
          value,
          'value',
          'Unknown render mode',
        ),
    };
  }
}
