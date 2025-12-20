import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AttributionBanner extends StatelessWidget {
  const AttributionBanner({
    required this.text,
    required this.linkLabel,
    required this.tapRecognizer,
    super.key,
  });

  final String text;
  final String linkLabel;
  final GestureRecognizer tapRecognizer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
      height: 1.1,
    );

    final linkStyle = baseStyle?.copyWith(
      color: theme.colorScheme.primary.withValues(alpha: 0.85),
      decoration: TextDecoration.none, // more discreet than underline
      fontWeight: FontWeight.w600,
    );

    return SafeArea(
      minimum: const EdgeInsets.only(left: 12, bottom: 12),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Material(
          color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text.rich(
              TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: text),
                  const TextSpan(text: ' · '),
                  TextSpan(
                    text: linkLabel,
                    style: linkStyle,
                    recognizer: tapRecognizer,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
