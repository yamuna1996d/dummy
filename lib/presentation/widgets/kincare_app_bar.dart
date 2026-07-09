import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';

/// Custom app bar matching the Stitch design with avatar, title, and menu.
class KinCareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KinCareAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);

  void _openHelp(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    // Avoid pushing help on top of help if already there.
    if (currentRoute.startsWith(AppRoutes.help)) return;

    Navigator.of(context).pushNamed(AppRoutes.help);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leadingWidth: 48,
      leading: Builder(
        builder: (context) => Semantics(
          button: true,
          label: AppStrings.openNavigationMenuHint,
          child: IconButton(
            tooltip: AppStrings.menuTooltip,
            icon: Icon(Icons.menu, color: theme.colorScheme.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      title: Text(
        AppStrings.appName,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: [
        Semantics(
          button: true,
          label: AppStrings.helpButtonHint,
          child: IconButton(
            icon: Icon(Icons.help_outline, color: theme.colorScheme.primary),
            tooltip: AppStrings.helpTooltip,
            onPressed: () => _openHelp(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.paddingSm),
          child: Semantics(
            image: true,
            label: AppStrings.userAvatarLabel,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}