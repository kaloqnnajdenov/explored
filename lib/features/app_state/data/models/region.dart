import 'package:latlong2/latlong.dart';

class RegionFeatureProgress {
  const RegionFeatureProgress({required this.total, required this.completed});

  final int total;
  final int completed;

  RegionFeatureProgress copyWith({int? total, int? completed}) {
    return RegionFeatureProgress(
      total: total ?? this.total,
      completed: completed ?? this.completed,
    );
  }
}

class RegionFeatures {
  const RegionFeatures({
    required this.trails,
    required this.peaks,
    required this.huts,
  });

  final RegionFeatureProgress trails;
  final RegionFeatureProgress peaks;
  final RegionFeatureProgress huts;

  RegionFeatures copyWith({
    RegionFeatureProgress? trails,
    RegionFeatureProgress? peaks,
    RegionFeatureProgress? huts,
  }) {
    return RegionFeatures(
      trails: trails ?? this.trails,
      peaks: peaks ?? this.peaks,
      huts: huts ?? this.huts,
    );
  }
}

class Region {
  const Region({
    required this.id,
    required this.name,
    required this.totalArea,
    required this.exploredArea,
    required this.isDownloaded,
    required this.center,
    required this.bounds,
    required this.features,
  });

  final String id;
  final String name;
  final double totalArea;
  final double exploredArea;
  final bool isDownloaded;
  final LatLng center;
  final List<LatLng> bounds;
  final RegionFeatures features;

  Region copyWith({
    String? id,
    String? name,
    double? totalArea,
    double? exploredArea,
    bool? isDownloaded,
    LatLng? center,
    List<LatLng>? bounds,
    RegionFeatures? features,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      totalArea: totalArea ?? this.totalArea,
      exploredArea: exploredArea ?? this.exploredArea,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      center: center ?? this.center,
      bounds: bounds ?? this.bounds,
      features: features ?? this.features,
    );
  }
}
