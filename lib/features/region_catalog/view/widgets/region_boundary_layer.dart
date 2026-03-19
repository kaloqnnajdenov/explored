import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../data/models/region_boundary.dart';

class RegionBoundaryLayer extends StatelessWidget {
  const RegionBoundaryLayer({
    required this.boundary,
    required this.fillColor,
    required this.borderColor,
    required this.borderStrokeWidth,
    super.key,
  });

  final RegionBoundary? boundary;
  final Color fillColor;
  final Color borderColor;
  final double borderStrokeWidth;

  @override
  Widget build(BuildContext context) {
    final boundary = this.boundary;
    if (boundary == null || boundary.isEmpty) {
      return const SizedBox.shrink();
    }

    return PolygonLayer(
      polygons: [
        for (final polygon in boundary.polygons)
          Polygon(
            points: polygon.outerRing,
            holePointsList: polygon.holeRings,
            color: fillColor,
            borderColor: borderColor,
            borderStrokeWidth: borderStrokeWidth,
          ),
      ],
    );
  }
}
