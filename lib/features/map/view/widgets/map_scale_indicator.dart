import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:explored/constants.dart';

import '../../../../translations/locale_keys.g.dart';

/// Fixed-length map scale with a live distance label.
class MapScaleIndicator extends StatelessWidget {
  const MapScaleIndicator({
    this.barLength = 100,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.only(
      right: kMapScaleDefaultPaddingRight,
      bottom: kMapScaleDefaultPaddingBottom,
    ),
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

    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.onSurface.withValues(alpha: 0.85);
    final baseStyle =
        theme.textTheme.labelSmall ?? DefaultTextStyle.of(context).style;
    final textStyle = baseStyle.copyWith(
      color: lineColor,
      fontWeight: FontWeight.w600,
    );
    final lineCenter = _lineCenter(context, size, textStyle);
    if (lineCenter == null) {
      return const SizedBox.shrink();
    }

    final halfLength = barLength / 2;
    final start = Point<double>(lineCenter.dx - halfLength, lineCenter.dy);
    final end = Point<double>(lineCenter.dx + halfLength, lineCenter.dy);
    final meters = Distance().as(
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
          child: _ScaleBar(
            label: label,
            length: barLength,
            textStyle: textStyle,
            lineColor: lineColor,
          ),
        ),
      ),
    );
  }

  Offset? _lineCenter(
    BuildContext context,
    Point<double> mapSize,
    TextStyle textStyle,
  ) {
    final safePadding = MediaQuery.paddingOf(context);
    final safeWidth = mapSize.x - safePadding.left - safePadding.right;
    final safeHeight = mapSize.y - safePadding.top - safePadding.bottom;
    if (safeWidth <= 0 || safeHeight <= 0) {
      return null;
    }

    final textHeight = _measureTextHeight(context, textStyle);
    final scaleBarSize = Size(
      barLength +
          kMapScaleBarPaddingHorizontal +
          kMapScaleBarPaddingHorizontal,
      textHeight +
          kMapScaleLabelLineSpacing +
          kMapScaleLineHeight +
          kMapScaleBarPaddingVertical +
          kMapScaleBarPaddingVertical,
    );
    final paddedSize = Size(
      scaleBarSize.width + padding.horizontal,
      scaleBarSize.height + padding.vertical,
    );

    final extraWidth = safeWidth - paddedSize.width;
    final extraHeight = safeHeight - paddedSize.height;
    final alignOffset = Offset(
      (alignment.x + 1) / 2 * extraWidth,
      (alignment.y + 1) / 2 * extraHeight,
    );

    final scaleBarTopLeft = Offset(
      safePadding.left + alignOffset.dx + padding.left,
      safePadding.top + alignOffset.dy + padding.top,
    );

    return Offset(
      scaleBarTopLeft.dx + kMapScaleBarPaddingHorizontal + barLength / 2,
      scaleBarTopLeft.dy +
          kMapScaleBarPaddingVertical +
          textHeight +
          kMapScaleLabelLineSpacing +
          kMapScaleLineHeight / 2,
    );
  }

  double _measureTextHeight(BuildContext context, TextStyle textStyle) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.size.height;
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
    required this.textStyle,
    required this.lineColor,
  });

  final String label;
  final double length;
  final TextStyle textStyle;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: kMapScaleBarPaddingHorizontal,
          vertical: kMapScaleBarPaddingVertical,
        ),
        child: SizedBox(
          width: length,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: kMapScaleLabelLineSpacing),
              _ScaleBarLine(length: length, color: lineColor),
            ],
          ),
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
      height: kMapScaleLineHeight,
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
