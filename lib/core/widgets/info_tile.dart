import 'package:flutter/material.dart';

/// Icon + label + value row used for read-only detail lists (profile
/// fields, app info, etc). By default the value renders as a subtitle
/// below the label; pass [valueAsTrailing] to show it beside the label
/// instead.
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueAsTrailing = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool valueAsTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        title: Text(
          label,
          style: valueAsTrailing
              ? theme.textTheme.labelSmall
              : theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
        subtitle: valueAsTrailing
            ? null
            : Text(value, style: theme.textTheme.bodyLarge),
        trailing: valueAsTrailing
            ? Text(value, style: theme.textTheme.bodyMedium)
            : null,
      ),
    );
  }
}
