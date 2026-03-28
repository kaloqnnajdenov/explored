import 'package:explored/domain/objects/object_category.dart';
import 'package:explored/features/map/data/models/map_point_of_interest.dart';
import 'package:explored/features/map/data/services/map_point_cluster_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('GridMapPointClusterService', () {
    test('clusters nearby points of the same category when zoomed out', () {
      const service = GridMapPointClusterService(
        minimumClusterPointCount: 2,
        clusterBelowZoom: 12,
      );

      final markers = service.buildMarkers(
        pointsOfInterest: [
          _point('monument-1', ObjectCategory.monument, 42.0000, 23.0000),
          _point('monument-2', ObjectCategory.monument, 42.0003, 23.0002),
          _point('monument-3', ObjectCategory.monument, 42.0004, 23.0004),
          _point('hut-1', ObjectCategory.hut, 42.0200, 23.0200),
        ],
        zoom: 6,
      );

      expect(markers, hasLength(2));
      expect(
        markers
            .where((marker) => marker.category == ObjectCategory.monument)
            .single
            .count,
        3,
      );
      expect(
        markers
            .where((marker) => marker.category == ObjectCategory.hut)
            .single
            .count,
        1,
      );
    });

    test('keeps same points separate once the zoom is high enough', () {
      const service = GridMapPointClusterService(
        minimumClusterPointCount: 2,
        clusterBelowZoom: 12,
      );

      final markers = service.buildMarkers(
        pointsOfInterest: [
          _point('monument-1', ObjectCategory.monument, 42.0000, 23.0000),
          _point('monument-2', ObjectCategory.monument, 42.0003, 23.0002),
          _point('monument-3', ObjectCategory.monument, 42.0004, 23.0004),
        ],
        zoom: 12.5,
      );

      expect(markers, hasLength(3));
      expect(markers.every((marker) => marker.count == 1), isTrue);
    });

    test('clusters each category independently inside the same area', () {
      const service = GridMapPointClusterService(
        minimumClusterPointCount: 2,
        clusterBelowZoom: 12,
      );

      final markers = service.buildMarkers(
        pointsOfInterest: [
          _point('monument-1', ObjectCategory.monument, 42.0000, 23.0000),
          _point('monument-2', ObjectCategory.monument, 42.0002, 23.0002),
          _point('hut-1', ObjectCategory.hut, 42.0001, 23.0001),
          _point('hut-2', ObjectCategory.hut, 42.0003, 23.0003),
        ],
        zoom: 5,
      );

      expect(markers, hasLength(2));
      expect(
        markers
            .where((marker) => marker.category == ObjectCategory.monument)
            .single
            .count,
        2,
      );
      expect(
        markers
            .where((marker) => marker.category == ObjectCategory.hut)
            .single
            .count,
        2,
      );
    });
  });
}

MapPointOfInterest _point(
  String id,
  ObjectCategory category,
  double latitude,
  double longitude,
) {
  return MapPointOfInterest(
    id: id,
    category: category,
    position: LatLng(latitude, longitude),
  );
}
