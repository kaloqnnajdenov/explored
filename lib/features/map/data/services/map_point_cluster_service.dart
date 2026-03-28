import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../../../domain/objects/object_category.dart';
import '../models/map_point_of_interest.dart';
import '../models/map_point_of_interest_marker.dart';

abstract class MapPointClusterService {
  List<MapPointOfInterestMarker> buildMarkers({
    required List<MapPointOfInterest> pointsOfInterest,
    required double zoom,
  });
}

class GridMapPointClusterService implements MapPointClusterService {
  const GridMapPointClusterService({
    this.clusterCellSize = 64,
    this.clusterBelowZoom = 12,
    this.minimumClusterPointCount = 24,
  });

  final double clusterCellSize;
  final double clusterBelowZoom;
  final int minimumClusterPointCount;

  @override
  List<MapPointOfInterestMarker> buildMarkers({
    required List<MapPointOfInterest> pointsOfInterest,
    required double zoom,
  }) {
    if (pointsOfInterest.isEmpty) {
      return const <MapPointOfInterestMarker>[];
    }

    if (pointsOfInterest.length < minimumClusterPointCount ||
        zoom >= clusterBelowZoom) {
      return [
        for (final point in pointsOfInterest)
          MapPointOfInterestMarker.single(point),
      ];
    }

    final buckets = <_ClusterBucketKey, _ClusterBucket>{};
    for (final point in pointsOfInterest) {
      final projected = _project(point.position, zoom);
      final cellX = (projected.x / clusterCellSize).floor();
      final cellY = (projected.y / clusterCellSize).floor();
      final key = _ClusterBucketKey(
        cellX: cellX,
        cellY: cellY,
        category: point.category,
      );
      final bucket = buckets[key];
      if (bucket == null) {
        buckets[key] = _ClusterBucket(cellX: cellX, cellY: cellY, point: point);
      } else {
        bucket.add(point);
      }
    }

    return [for (final bucket in buckets.values) bucket.toMarker()];
  }

  math.Point<double> _project(LatLng position, double zoom) {
    final scale = 256.0 * math.pow(2, zoom).toDouble();
    final latitude = position.latitude.clamp(-85.05112878, 85.05112878);
    final latitudeRadians = latitude * (math.pi / 180.0);
    final sinLatitude = math.sin(latitudeRadians);
    final x = (position.longitude + 180.0) / 360.0 * scale;
    final y =
        (0.5 -
            math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * math.pi)) *
        scale;
    return math.Point<double>(x, y);
  }
}

class _ClusterBucket {
  _ClusterBucket({
    required this.cellX,
    required this.cellY,
    required MapPointOfInterest point,
  }) : _firstPoint = point,
       _latitudeSum = point.position.latitude,
       _longitudeSum = point.position.longitude,
       _count = 1;

  final int cellX;
  final int cellY;
  final MapPointOfInterest _firstPoint;
  double _latitudeSum;
  double _longitudeSum;
  int _count;

  void add(MapPointOfInterest point) {
    _latitudeSum += point.position.latitude;
    _longitudeSum += point.position.longitude;
    _count += 1;
  }

  MapPointOfInterestMarker toMarker() {
    if (_count == 1) {
      return MapPointOfInterestMarker.single(_firstPoint);
    }

    return MapPointOfInterestMarker.cluster(
      id: '${_firstPoint.category.name}-$cellX-$cellY',
      category: _firstPoint.category,
      position: LatLng(_latitudeSum / _count, _longitudeSum / _count),
      count: _count,
    );
  }
}

class _ClusterBucketKey {
  const _ClusterBucketKey({
    required this.cellX,
    required this.cellY,
    required this.category,
  });

  final int cellX;
  final int cellY;
  final ObjectCategory category;

  @override
  bool operator ==(Object other) {
    return other is _ClusterBucketKey &&
        other.cellX == cellX &&
        other.cellY == cellY &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(cellX, cellY, category);
}
