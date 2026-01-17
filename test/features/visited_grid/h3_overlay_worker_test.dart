import 'package:flutter_test/flutter_test.dart';

import 'package:explored/domain/usecases/h3_overlay_worker.dart';

void main() {
  test('desiredResForZoom adapts and respects min resolution', () {
    const base = 12;
    const min = 6;

    expect(
      H3OverlayWorker.desiredResForZoom(
        zoom: 16,
        baseResolution: base,
        minResolution: min,
      ),
      12,
    );
    expect(
      H3OverlayWorker.desiredResForZoom(
        zoom: 15,
        baseResolution: base,
        minResolution: min,
      ),
      11,
    );
    expect(
      H3OverlayWorker.desiredResForZoom(
        zoom: 14,
        baseResolution: base,
        minResolution: min,
      ),
      10,
    );
    expect(
      H3OverlayWorker.desiredResForZoom(
        zoom: 13,
        baseResolution: base,
        minResolution: min,
      ),
      9,
    );
    expect(
      H3OverlayWorker.desiredResForZoom(
        zoom: 12,
        baseResolution: base,
        minResolution: min,
      ),
      8,
    );
    expect(
      H3OverlayWorker.desiredResForZoom(
        zoom: 10.5,
        baseResolution: base,
        minResolution: min,
      ),
      7,
    );
    expect(
      H3OverlayWorker.desiredResForZoom(
        zoom: 9,
        baseResolution: base,
        minResolution: min,
      ),
      6,
    );
  });
}
