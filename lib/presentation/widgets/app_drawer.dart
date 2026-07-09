import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/presentation/controllers/auth_controller.dart';

import 'confirm_dialog.dart';

/// Navigation drawer with accessibility support.
///
/// Uses plain [ListTile]s instead of [NavigationDrawer]/
/// [NavigationDrawerDestination]. Flutter's built-in destination widget
/// bakes in its own extra `Semantics` node that announces each item's
/// position, e.g. "Dashboard, Tab 1 of 5" — there's no public way to
/// override or remove that announcement without replacing the widget, so
/// screen reader users heard the item label followed by unexplained
/// numbers. Building the tiles ourselves means only the label and
/// selected state we set are ever announced.
///
/// The content is laid out with [SingleChildScrollView] + [Column], not
/// [ListView]. A [ListView] is backed by a sliver multi-box viewport that
/// tags every direct child with its scroll position, so a screen reader
/// announces "in list, item 1 of 7" for each row — the same kind of
/// unwanted number this file already works around above. A
/// [SingleChildScrollView] only ever has one child (the [Column]), so no
/// per-item index gets attached, while still scrolling if content
/// overflows on a small screen or with large system text sizes.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: AppStrings.navigationMenu,
      child: Drawer(
        width: AppDimensions.drawerWidth,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingLg,
                    AppDimensions.paddingLg,
                    AppDimensions.paddingMd,
                    AppDimensions.paddingSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        image: true,
                        label: AppStrings.logoLabel,
                        child: CircleAvatar(
                          radius: AppDimensions.avatarMd / 2,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.family_restroom,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      Text(
                        AppStrings.appName,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        AppStrings.appDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _destination(
                  context,
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: AppStrings.dashboard,
                ),
                _destination(
                  context,
                  index: 1,
                  icon: Icons.medication_outlined,
                  selectedIcon: Icons.medication,
                  label: AppStrings.medications,
                ),
                _destination(
                  context,
                  index: 2,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: AppStrings.profile,
                ),
                _destination(
                  context,
                  index: 3,
                  icon: Icons.help_outline,
                  selectedIcon: Icons.help,
                  label: AppStrings.help,
                ),
                _destination(
                  context,
                  index: 4,
                  icon: Icons.info_outline,
                  selectedIcon: Icons.info,
                  label: AppStrings.about,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSm,
                    vertical: AppDimensions.spacingXxs,
                  ),
                  child: Semantics(
                    button: true,
                    label: AppStrings.logout,
                    excludeSemantics: true,
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        AppStrings.logout,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      onTap: () => _handleLogout(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _destination(
      BuildContext context, {
        required int index,
        required IconData icon,
        required IconData selectedIcon,
        required String label,
      }) {
    final theme = Theme.of(context);
    final selected = index == _selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSm,
        vertical: AppDimensions.spacingXxs,
      ),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        onTap: () => _onDestinationSelected(context, index),
        child: Material(
          color: selected ? theme.colorScheme.secondaryContainer : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            onTap: () => _onDestinationSelected(context, index),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              leading: Icon(
                selected ? selectedIcon : icon,
                color: selected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int get _selectedIndex {
    final route = Get.currentRoute;
    if (route.startsWith(AppRoutes.dashboard)) return 0;
    if (route.startsWith(AppRoutes.medications)) return 1;
    if (route.startsWith(AppRoutes.profile)) return 2;
    if (route.startsWith(AppRoutes.help)) return 3;
    if (route.startsWith(AppRoutes.about)) return 4;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    Navigator.of(context).pop(); // close drawer

    final routes = [
      AppRoutes.dashboard,
      AppRoutes.medications,
      AppRoutes.profile,
      AppRoutes.help,
      AppRoutes.about,
    ];

    if (index >= routes.length) return;

    final target = routes[index];

    // Already on this route — just close the drawer.
    if (Get.currentRoute == target) return;

    if (index == 0) {
      // Dashboard is the root — clear everything back to it.
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      // Push on top of dashboard so back button returns there.
      Get.offNamedUntil(target, (route) {
        return route.settings.name == AppRoutes.dashboard;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.of(context).pop();

    final confirmed = await ConfirmDialog.show(
      context,
      title: AppStrings.logout,
      message: AppStrings.logoutConfirmation,
      confirmLabel: AppStrings.logout,
      isDestructive: true,
    );

    if (confirmed) {
      final authController = Get.find<AuthController>();
      await authController.logout();
    }
  }
}