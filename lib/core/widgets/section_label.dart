import 'package:flutter/material.dart';
import 'package:kincare/app/theme/app_colors.dart';

/// Small uppercase, letter-spaced section header used throughout the app
/// (e.g. "TODAY AT A GLANCE", "HEALTH METRICS"). Pass [trailing] to render
/// an action (e.g. a "View History" button) aligned to the end of the row.
///
/// Marked as a level-2 heading (not [header]/level-1) so it reads as a
/// subsection under the screen's one true page title, rather than
/// competing with it as another top-level heading.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Semantics(
      headingLevel: 2,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.sectionLabel,
        ),
      ),
    );

    if (trailing == null) return text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [text, trailing!],
    );
  }
}
