import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';

/// Reusable empty state view with icon, message, and optional action.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                icon,
                size: AppDimensions.iconXl * 1.5,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Semantics(
              label: semanticLabel,
              excludeSemantics: semanticLabel != null,
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              Semantics(
                button: true,
                label: actionLabel,
                excludeSemantics: true,
                child: FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
