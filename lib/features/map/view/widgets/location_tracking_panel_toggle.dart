import 'package:flutter/material.dart';

/// Minimal toggle to restore the full location tracking panel.
class LocationTrackingPanelToggle extends StatelessWidget {
  const LocationTrackingPanelToggle({
    required this.onTap,
    required this.label,
    required this.tooltip,
    super.key,
  });

  final VoidCallback onTap;
  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
