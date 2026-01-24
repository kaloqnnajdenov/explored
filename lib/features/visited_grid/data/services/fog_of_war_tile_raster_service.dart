import 'dart:typed_data';
import 'dart:ui' as ui;

import '../models/fog_of_war_style.dart';

class FogOfWarTileRasterService {
  Future<Uint8List> rasterizeTile({
    required List<List<ui.Offset>> polygons,
    required int tileSize,
    required FogOfWarStyle style,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()
      ..color = style.highlightColor
          .withValues(alpha: style.highlightOpacity)
      ..style = ui.PaintingStyle.fill
      ..isAntiAlias = true;
    final blurPaint = ui.Paint()
      ..color = style.highlightColor
          .withValues(alpha: style.highlightOpacity)
      ..style = ui.PaintingStyle.fill
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, style.blurSigma)
      ..isAntiAlias = true;

    for (final polygon in polygons) {
      if (polygon.length < 3) {
        continue;
      }
      final path = ui.Path()..addPolygon(polygon, true);
      canvas.drawPath(path, blurPaint);
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(tileSize, tileSize);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List() ?? Uint8List(0);
  }
}
