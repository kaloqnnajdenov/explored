import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../domain/objects/object_category.dart';
import '../../../../ui/core/app_colors.dart';
import '../../data/models/map_point_of_interest.dart';

class PointsOfInterestLayer extends StatelessWidget {
  const PointsOfInterestLayer({required this.pointsOfInterest, super.key});

  final List<MapPointOfInterest> pointsOfInterest;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        for (final pointOfInterest in pointsOfInterest)
          Marker(
            point: pointOfInterest.position,
            width: 30,
            height: 30,
            child: IgnorePointer(
              child: _PointOfInterestMarker(pointOfInterest: pointOfInterest),
            ),
          ),
      ],
    );
  }
}

class _PointOfInterestMarker extends StatelessWidget {
  const _PointOfInterestMarker({required this.pointOfInterest});

  final MapPointOfInterest pointOfInterest;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(pointOfInterest.category);
    final backgroundColor = _backgroundColor(pointOfInterest.category);

    return Container(
      key: ValueKey<String>('poi-${pointOfInterest.id}'),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.7),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _icon(pointOfInterest.category),
          size: 16,
          color: accentColor,
        ),
      ),
    );
  }

  IconData _icon(ObjectCategory category) {
    switch (category) {
      case ObjectCategory.peak:
        return Icons.landscape;
      case ObjectCategory.hut:
        return Icons.home;
      case ObjectCategory.monument:
        return Icons.account_balance;
      case ObjectCategory.roadSegment:
        return Icons.place;
    }
  }

  Color _accentColor(ObjectCategory category) {
    switch (category) {
      case ObjectCategory.peak:
        return AppColors.amber600;
      case ObjectCategory.hut:
        return AppColors.indigo600;
      case ObjectCategory.monument:
        return AppColors.rose600;
      case ObjectCategory.roadSegment:
        return AppColors.slate600;
    }
  }

  Color _backgroundColor(ObjectCategory category) {
    switch (category) {
      case ObjectCategory.peak:
        return AppColors.amber50.withValues(alpha: 0.96);
      case ObjectCategory.hut:
        return AppColors.indigo50.withValues(alpha: 0.96);
      case ObjectCategory.monument:
        return AppColors.rose50.withValues(alpha: 0.96);
      case ObjectCategory.roadSegment:
        return Colors.white.withValues(alpha: 0.96);
    }
  }
}
