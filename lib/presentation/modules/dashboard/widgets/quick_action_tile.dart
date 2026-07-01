import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';

/// Quick action tile for dashboard shortcuts.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = color ?? theme.colorScheme.primary;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSm,
            horizontal: AppDimensions.paddingXs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimensions.minTouchTarget,
                height: AppDimensions.minTouchTarget,
                decoration: BoxDecoration(
                  color: tileColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: tileColor),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
