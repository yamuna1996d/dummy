import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/core/widgets/custom_text_field.dart';
import 'package:kincare/core/widgets/primary_button.dart';
import 'package:kincare/presentation/controllers/auth_controller.dart';

/// LOGIN SCREEN
///
/// Flow: app entry screen when there's no active session. The user enters
/// email + password and taps "Log in". On success, the session is saved
/// and the app navigates to the Dashboard, replacing the navigation stack
/// (so there's no "back" into this screen afterwards). On failure, an
/// inline error banner appears above the form so the user can retry.
///
/// Reached from: app launch when not logged in, or tapping "Logout" in the
/// navigation drawer (available from Dashboard/Children/Medications/
/// Profile/Help/About).
/// Leads to: Dashboard (only on a successful login).
class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = ResponsiveHelper.isTabletOrLarger(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.horizontalPadding(context),
              vertical: AppDimensions.paddingLg,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 440 : double.infinity,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo icon
                  Semantics(
                    image: true,
                    label: '${AppStrings.appName} logo',
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
                  const SizedBox(height: AppDimensions.spacingLg),
                  Semantics(
                    headingLevel: 1,
                    child: Text(
                      AppStrings.welcomeBack,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    "Continue managing your child's health\nwith Clinical Compassion.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Login card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingLg),
                      child: Form(
                        key: controller.formKey,
                        child: AutofillGroup(
                          // AutofillGroup lets iOS/Android fill email+password
                          // together from the password manager in one step.
                          child: FocusTraversalGroup(
                            // OrderedTraversalPolicy + NumericFocusOrder below
                            // pins keyboard/switch-control tab order to:
                            // email (0) → password (1) → login button (2).
                            policy: OrderedTraversalPolicy(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  final error = controller.errorMessage.value;
                                  if (error == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppDimensions.spacingMd,
                                    ),
                                    child: Semantics(
                                      // liveRegion=true tells TalkBack/VoiceOver
                                      // to announce the error immediately when
                                      // it appears, without the user navigating
                                      // to it.
                                      liveRegion: true,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppDimensions.paddingSm,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              theme.colorScheme.errorContainer,
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusMd,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: theme.colorScheme.error,
                                              size: 18,
                                            ),
                                            const SizedBox(
                                              width: AppDimensions.spacingSm,
                                            ),
                                            Expanded(
                                              child: Text(
                                                error,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onErrorContainer,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                Text(
                                  'Email Address',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingSm),
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(0),
                                  child: CustomTextField(
                                    label: '',
                                    hint: 'parent@example.com',
                                    controller: controller.emailController,
                                    focusNode: controller.emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: Icons.mail_outline,
                                    validator: controller.validateEmail,
                                    semanticLabel: 'Email address',
                                    onSubmitted: (_) {
                                      // Move focus to password field when the
                                      // user presses "next" on the keyboard.
                                      controller.passwordFocusNode
                                          .requestFocus();
                                    },
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingMd),
                                Text(
                                  'Password',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingSm),
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(1),
                                  child: Obx(
                                    () => CustomTextField(
                                      label: '',
                                      hint: '',
                                      controller: controller.passwordController,
                                      focusNode: controller.passwordFocusNode,
                                      obscureText:
                                          controller.obscurePassword.value,
                                      textInputAction: TextInputAction.done,
                                      prefixIcon: Icons.lock_outline,
                                      validator: controller.validatePassword,
                                      semanticLabel: 'Password',
                                      suffixIcon: Semantics(
                                        button: true,
                                        label: controller.obscurePassword.value
                                            ? 'Show password'
                                            : 'Hide password',
                                        child: IconButton(
                                          icon: Icon(
                                            controller.obscurePassword.value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          onPressed: controller
                                              .togglePasswordVisibility,
                                        ),
                                      ),
                                      onSubmitted: (_) => controller.login(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingLg),
                                FocusTraversalOrder(
                                  order: const NumericFocusOrder(2),
                                  child: Obx(
                                    () => PrimaryButton(
                                      label: 'Log in',
                                      onPressed: controller.login,
                                      isLoading: controller.isLoading.value,
                                      semanticLabel: 'Log in',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    'Demo: admin@kincare.com / password',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
