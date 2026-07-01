import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/core/widgets/section_label.dart';
import 'package:kincare/presentation/widgets/back_to_dashboard_app_bar.dart';

/// HELP & ABOUT SCREEN
///
/// Flow: static reference content — getting-started steps, accessibility
/// notes, and a contact-support link (no live data, no actions besides
/// reading). The back arrow pops normally if there's a real back stack,
/// otherwise returns to the Dashboard (this screen is usually reached via
/// the drawer, which clears the stack). There's no drawer on this screen
/// itself.
///
/// Reached from: "Help" in the navigation drawer.
/// Leads to: back to the Dashboard.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      appBar: const BackToDashboardAppBar(title: Text('Help & about')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        children: [
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Help & about',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            '${AppStrings.appName} v${AppStrings.appVersion}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // GETTING STARTED
          const SectionLabel('GETTING STARTED'),
          const SizedBox(height: AppDimensions.spacingMd),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NumberedStep(
                    number: '1.',
                    text: 'Add a child profile from the Children screen.',
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _NumberedStep(
                    number: '2.',
                    text: 'Add their medications and set dose times.',
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _NumberedStep(
                    number: '3.',
                    text: 'Mark each dose as given from the Dashboard.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // ACCESSIBILITY
          const SectionLabel('ACCESSIBILITY'),
          const SizedBox(height: AppDimensions.spacingMd),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KinCare is built for screen readers and keyboards. Every control has a label, a focus outline, and a target at least 48 px wide.',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Adjust text size and contrast in Profile → Accessibility.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // CONTACT
          const SectionLabel('CONTACT'),
          const SizedBox(height: AppDimensions.spacingMd),
          Card(
            child: Semantics(
              label: 'Email support at help@kincare.app',
              excludeSemantics: true,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.paddingSm,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.chipOrange,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Icon(
                    Icons.mail_outline,
                    color: AppColors.secondaryLight,
                  ),
                ),
                title: Text(
                  'Email support',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'help@kincare.app',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            number,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}
