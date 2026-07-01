import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';

/// List tile for recent activity items.
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.activity});

  final ActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(activity.timestamp);

    return Semantics(
      label: '${activity.title}, ${activity.description}, $timeAgo',
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            _iconForType(activity.icon),
            color: theme.colorScheme.onPrimaryContainer,
            size: AppDimensions.iconMd,
          ),
        ),
        title: Text(
          activity.title,
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          activity.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          timeAgo,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String? type) {
    return switch (type) {
      'medication' => Icons.medication,
      'appointment' => Icons.calendar_today,
      'profile' => Icons.person,
      'child' => Icons.child_care,
      _ => Icons.notifications_outlined,
    };
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(timestamp);
  }
}
