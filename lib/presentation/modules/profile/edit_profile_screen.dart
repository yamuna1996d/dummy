import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/core/widgets/app_snackbar.dart';
import 'package:kincare/core/widgets/custom_text_field.dart';
import 'package:kincare/core/widgets/form_screen_scaffold.dart';
import 'package:kincare/core/widgets/primary_button.dart';
import 'package:kincare/presentation/controllers/profile_controller.dart';

/// EDIT PROFILE SCREEN
///
/// Flow: form to update the user's profile fields. On save, returns to
/// the Profile screen with a success snackbar.
///
/// Reached from: Profile screen (edit/pencil icon).
/// Leads to: back to Profile.
class EditProfileScreen extends GetView<ProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: const Text(AppStrings.editProfile),
      formKey: controller.formKey,
      children: [
        CustomTextField(
          label: AppStrings.name,
          controller: controller.nameController,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.person,
          semanticLabel: 'Full name',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        CustomTextField(
          label: AppStrings.email,
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email,
          semanticLabel: 'Email address',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!regex.hasMatch(v.trim())) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        CustomTextField(
          label: AppStrings.phone,
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.phone,
          semanticLabel: 'Phone number',
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        Obx(
          () => PrimaryButton(
            label: AppStrings.saveChanges,
            isLoading: controller.isSaving.value,
            semanticLabel: 'Save profile changes',
            semanticHint: 'Double tap to save',
            onPressed: () async {
              final success = await controller.saveProfile();
              if (success) {
                Get.back();
                AppSnackbar.success('Profile updated successfully');
              }
            },
          ),
        ),
      ],
    );
  }
}
