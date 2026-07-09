import 'package:flutter/material.dart';

/// Small rounded-pill badge for short status/metadata text (blood type,
/// active/inactive, age, child name tags, etc). Pass [backgroundColor]
/// for a filled pill, or [border] for an outlined one.
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.border,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
    this.semanticLabel,
  });

  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final BoxBorder? border;
  final double fontSize;
  final FontWeight fontWeight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel ?? text,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
