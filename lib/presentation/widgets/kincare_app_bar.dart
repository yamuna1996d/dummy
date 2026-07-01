import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';

/// Custom app bar matching the Stitch design with avatar, title, and menu.
class KinCareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KinCareAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppDimensions.paddingMd),
        child: Semantics(
          image: true,
          label: 'User avatar',
          child: CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
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
        Builder(
          builder: (context) => Semantics(
            button: true,
            label: 'Open navigation menu',
            child: IconButton(
              icon: Icon(Icons.menu, color: theme.colorScheme.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ],
    );
  }
}
