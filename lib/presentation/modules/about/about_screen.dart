import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/presentation/widgets/back_to_dashboard_app_bar.dart';

import '../../widgets/info_tile.dart';

/// ABOUT SCREEN
///
/// Flow: static app info (version, Flutter version, developer) plus a
/// link to the open-source licenses page. Same back-button behavior as
/// the Help screen — pops normally if possible, otherwise returns to the
/// Dashboard.
///
/// Reached from: "About" in the navigation drawer.
/// Leads to: back to the Dashboard, or the licenses page.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      appBar: const BackToDashboardAppBar(title: Text(AppStrings.about)),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        children: [
          const SizedBox(height: AppDimensions.spacingLg),
          Center(
            child: Semantics(
              image: true,
              label: AppStrings.appIconLabel,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.spa, color: Colors.white, size: 36),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Center(
            child: Semantics(
              headingLevel: 2,
              child: Text(
                AppStrings.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Center(
            child: Text(
              AppStrings.appDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          Card(
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.info_outline,
                  label: AppStrings.version,
                  value: AppStrings.appVersion,
                  valueAsTrailing: true,
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                InfoTile(
                  icon: Icons.flutter_dash,
                  label: AppStrings.flutterVersion,
                  value: AppStrings.flutterVersionValue,
                  valueAsTrailing: true,
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                InfoTile(
                  icon: Icons.person_outline,
                  label: AppStrings.developer,
                  value: AppStrings.developerName,
                  valueAsTrailing: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          const SizedBox(height: AppDimensions.spacingXl),
          Center(
            child: Text(
              AppStrings.copyrightNotice(AppStrings.developerName),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
        ],
      ),
    );
  }
}
