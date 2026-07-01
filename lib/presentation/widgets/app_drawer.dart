import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/core/widgets/confirm_dialog.dart';
import 'package:kincare/presentation/controllers/auth_controller.dart';

/// Navigation drawer with accessibility support.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Navigation menu',
      child: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
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
                  label: '${AppStrings.appName} logo',
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
                Text(AppStrings.appName, style: theme.textTheme.titleLarge),
                Text(
                  AppStrings.appDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 28, endIndent: 28),
          const NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text(AppStrings.dashboard),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.child_care_outlined),
            selectedIcon: Icon(Icons.child_care),
            label: Text(AppStrings.children),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: Text(AppStrings.medications),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text(AppStrings.profile),
          ),
          const Divider(indent: 28, endIndent: 28),
          const NavigationDrawerDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: Text(AppStrings.help),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: Text(AppStrings.about),
          ),
          const Divider(indent: 28, endIndent: 28),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLg,
            ),
            child: Semantics(
              button: true,
              label: AppStrings.logout,
              hint: 'Double tap to sign out',
              excludeSemantics: true,
              child: ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
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
    );
  }

  int get _selectedIndex {
    final route = Get.currentRoute;
    if (route.startsWith(AppRoutes.dashboard)) return 0;
    if (route.startsWith(AppRoutes.children)) return 1;
    if (route.startsWith(AppRoutes.medications)) return 2;
    if (route.startsWith(AppRoutes.profile)) return 3;
    if (route.startsWith(AppRoutes.help)) return 4;
    if (route.startsWith(AppRoutes.about)) return 5;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    Navigator.of(context).pop();

    final routes = [
      AppRoutes.dashboard,
      AppRoutes.children,
      AppRoutes.medications,
      AppRoutes.profile,
      AppRoutes.help,
      AppRoutes.about,
    ];

    if (index < routes.length) {
      Get.offAllNamed(routes[index]);
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
