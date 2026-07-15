import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/presentation/controllers/visit_controller.dart';
import 'package:kincare/presentation/widgets/primary_button.dart';
import 'package:kincare/presentation/widgets/secondary_button.dart';

/// Pinned Cancel/Save action row at the bottom of the Add/Edit Visit form.
class VisitFormFooter extends StatelessWidget {
  const VisitFormFooter({
    super.key,
    required this.controller,
    required this.saveLabel,
    required this.onSave,
  });

  final VisitController controller;
  final String saveLabel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: AppStrings.cancel,
                icon: Icons.close,
                onPressed: Get.back,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Obx(
                () => PrimaryButton(
                  label: saveLabel,
                  icon: Icons.save_outlined,
                  isLoading: controller.isSaving.value,
                  onPressed: onSave,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
