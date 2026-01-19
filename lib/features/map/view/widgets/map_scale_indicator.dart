import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../translations/locale_keys.g.dart';

/// Fixed-length map scale with a live distance label.
class MapScaleIndicator extends StatelessWidget {
  const MapScaleIndicator({
    this.barLength = 100,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.only(right: 16, bottom: 88),
    super.key,
  });

  final double barLength;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final size = camera.nonRotatedSize;
    if (size.x <= 0 || size.y <= 0 || barLength <= 0) {
      return const SizedBox.shrink();
    }

    final centerX = size.x / 2;
    final centerY = size.y / 2;
    final halfLength = barLength / 2;
    final start = Point<double>(centerX - halfLength, centerY);
    final end = Point<double>(centerX + halfLength, centerY);
    const distance = Distance();
    final meters = distance.as(
      LengthUnit.Meter,
      camera.pointToLatLng(start),
      camera.pointToLatLng(end),
    );
    final label = _formatDistanceLabel(context, meters);

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: _ScaleBar(label: label, length: barLength),
        ),
      ),
    );
  }

  String _formatDistanceLabel(BuildContext context, double meters) {
    if (meters >= 1000) {
      final kilometers = meters / 1000;
      final rounded = kilometers >= 10
          ? kilometers.round().toString()
          : kilometers.toStringAsFixed(1);
      final value = rounded.endsWith('.0')
          ? rounded.substring(0, rounded.length - 2)
          : rounded;
      return LocaleKeys.map_scale_kilometers.tr(namedArgs: {'value': value});
    }

    return LocaleKeys.map_scale_meters
        .tr(namedArgs: {'value': meters.round().toString()});
  }
}

class _ScaleBar extends StatelessWidget {
  const _ScaleBar({
    required this.label,
    required this.length,
  });

  final String label;
  final double length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.onSurface.withValues(alpha: 0.85);
    final textStyle = theme.textTheme.labelSmall?.copyWith(
      color: lineColor,
      fontWeight: FontWeight.w600,
    );

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _ScaleBarLine(length: length, color: lineColor),
          ],
        ),
      ),
    );
  }
}

class _ScaleBarLine extends StatelessWidget {
  const _ScaleBarLine({
    required this.length,
    required this.color,
  });

  final double length;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: length,
      height: 8,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 2, color: color),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(width: 2, height: 6, color: color),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(width: 2, height: 6, color: color),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(width: 2, height: 4, color: color),
          ),
        ],
      ),
    );
  }
}
