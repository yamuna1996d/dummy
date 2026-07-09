import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/presentation/widgets/back_to_dashboard_app_bar.dart';

import '../../widgets/section_label.dart';

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
///
/// Uses SingleChildScrollView + Column (not ListView) deliberately: this
/// screen is a single page of mixed static content, not a homogeneous
/// data list. ListView exposes collection semantics to TalkBack ("item
/// 2 of 15"), which is correct for real lists but wrong here — it would
/// announce a spurious position count on every heading, card, and tile.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      appBar: BackToDashboardAppBar(title: Text(AppStrings.help)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppDimensions.spacingMd),

            // The body repeats "Help & Support" as a large page heading
            // alongside the AppBar's compact title. headingLevel: 1 marks
            // it as the top-level heading for screen-reader users
            // navigating by headings (the normal way to skim a static
            // content screen like this one).
            Semantics(
              headingLevel: 1,
              container: true,
              child: Text(
                AppStrings.help,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
            // "Getting started" and all three steps are read as one
            // combined stop — the same pattern used for "Today at a
            // glance" on the Dashboard — instead of the heading and each
            // step landing as four disconnected fragments.
            Semantics(
              headingLevel: 2,
              label: AppStrings.gettingStartedLabel(),
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel(AppStrings.gettingStartedSection),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NumberedStep(
                            number: '1.',
                            text: AppStrings.gettingStartedSteps[0],
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          _NumberedStep(
                            number: '2.',
                            text: AppStrings.gettingStartedSteps[1],
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          _NumberedStep(
                            number: '3.',
                            text: AppStrings.gettingStartedSteps[2],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),

            // ACCESSIBILITY
            // "Accessibility" and its note are read as one combined stop,
            // same pattern as "Getting started" and "Today at a glance".
            Semantics(
              headingLevel: 2,
              label: AppStrings.accessibilityLabel(),
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel(AppStrings.accessibilitySection),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.accessibilityBody,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          Text(
                            AppStrings.accessibilityHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),

            // CONTACT
            const SectionLabel(AppStrings.contactSection),
            const SizedBox(height: AppDimensions.spacingMd),
            Card(
              child: Semantics(
                label: AppStrings.emailSupportLabel(AppStrings.helpEmail),
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
                      borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Icon(
                      Icons.mail_outline,
                      color: AppColors.secondaryLight,
                    ),
                  ),
                  title: Text(
                    AppStrings.emailSupport,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.helpEmail,
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
    // "1." and the step text previously read as two separate stops
    // ("1.", then "Add a child profile..."). Merged into one: "Step 1:
    // Add a child profile from the Children screen."
    final stepNumber = number.replaceAll('.', '');
    return Semantics(
      label: AppStrings.stepLabel(stepNumber, text),
      excludeSemantics: true,
      child: Row(
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
      ),
    );
  }
}