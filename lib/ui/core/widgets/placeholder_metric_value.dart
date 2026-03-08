import 'package:flutter/material.dart';

import 'not_implemented_badge.dart';

class PlaceholderMetricValue extends StatelessWidget {
  const PlaceholderMetricValue({
    this.fontSize = 30,
    this.color,
    this.weight = FontWeight.w800,
    super.key,
  });

  final double fontSize;
  final Color? color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).textTheme.titleLarge?.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'XXX',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: weight,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        const NotImplementedBadge(),
      ],
    );
  }
}
