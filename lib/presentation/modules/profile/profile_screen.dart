import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/core/widgets/error_view.dart';
import 'package:kincare/core/widgets/info_tile.dart';
import 'package:kincare/core/widgets/initials_avatar.dart';
import 'package:kincare/core/widgets/loading_view.dart';
import 'package:kincare/presentation/controllers/profile_controller.dart';
import 'package:kincare/presentation/widgets/back_to_dashboard_app_bar.dart';

/// PROFILE SCREEN
///
/// Flow: read-only view of the logged-in user's profile (name, username,
/// email, phone). The back arrow pops normally if there's a real back
/// stack, otherwise returns to the Dashboard (this screen is usually
/// reached via the drawer, which clears the stack, so there's nothing to
/// pop into otherwise).
///
/// Reached from: "Profile" in the navigation drawer.
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      appBar: BackToDashboardAppBar(title: const Text(AppStrings.profile)),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();
        if (controller.errorMessage.value != null) {
          return ErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.loadProfile,
          );
        }

        final user = controller.profile.value;
        // Second null guard: profile.value starts null and is set
        // asynchronously; isLoading may have cleared before the value arrives
        // in a race, so this catches any residual null state.
        if (user == null) return const LoadingView();

        // "Name: John Doe, username @admin" — merged into one announcement
        // instead of the name and the @handle reading as two separate,
        // unlabeled stops.
        final identityLabel = user.username != null
            ? 'Name: ${user.name}, username: @${user.username}'
            : 'Name: ${user.name}';

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: AppDimensions.paddingLg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxContentWidth,
              ),
              child: Column(
                children: [
                  InitialsAvatar(
                    name: user.name,
                    radius: AppDimensions.avatarXl / 2,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    fontSize: theme.textTheme.headlineLarge?.fontSize,
                    semanticLabel: 'Profile avatar for ${user.name}',
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Semantics(
                    label: identityLabel,
                    excludeSemantics: true,
                    child: Column(
                      children: [
                        Text(
                          user.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.username != null)
                          Text(
                            '@${user.username}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  Card(
                    child: Column(
                      children: [
                        Semantics(
                          label: 'Email: ${user.email}',
                          excludeSemantics: true,
                          child: InfoTile(
                            icon: Icons.email_outlined,
                            label: AppStrings.email,
                            value: user.email,
                          ),
                        ),
                        const Divider(height: 1),
                        Semantics(
                          label: 'Phone: ${user.phone ?? "Not set"}',
                          excludeSemantics: true,
                          child: InfoTile(
                            icon: Icons.phone_outlined,
                            label: AppStrings.phone,
                            value: user.phone ?? 'Not set',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
