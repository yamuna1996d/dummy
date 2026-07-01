import 'package:flutter/material.dart';

/// Circular avatar showing the first letter of [name], used for both
/// children and the caregiver profile wherever a photo isn't available.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.semanticLabel,
  });

  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Semantics(
      image: true,
      label: semanticLabel ?? 'Avatar for $name',
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: fontSize ?? radius * 0.7,
            fontWeight: fontWeight,
            color: foregroundColor ?? theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
