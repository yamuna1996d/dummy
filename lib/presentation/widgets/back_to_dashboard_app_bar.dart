import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';

/// App bar with a back arrow that pops normally when possible, or returns
/// to the Dashboard otherwise. Used by screens (Profile, Help, About)
/// that are reached via the navigation drawer, which clears the
/// navigation stack — so there's usually nothing to pop into.
class BackToDashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BackToDashboardAppBar({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: Semantics(
        button: true,
        label: AppStrings.back,
        hint: AppStrings.backToDashboardHint,
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).canPop()
              ? Get.back()
              : Get.offAllNamed(AppRoutes.dashboard),
        ),
      ),
      title: Semantics(headingLevel: 1, child: title),
      actions: actions,
    );
  }
}