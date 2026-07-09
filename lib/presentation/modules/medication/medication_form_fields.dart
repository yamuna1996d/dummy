import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/presentation/widgets/form_screen_scaffold.dart'
    show formFieldOrderStep;
import 'package:kincare/presentation/controllers/medication_controller.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

/// Name/child/dosage/frequency/notes fields shared by Add and Edit
/// Medication - the only difference between those two screens is what
/// happens on save, not the form itself.
///
/// Used as a single item inside [FormScreenScaffold]'s `children`, so its
/// 5 fields get their own explicit sub-order (0-4) within the slot that
/// item occupies, keeping focus order pinned all the way down rather
/// than just at the top level.
class MedicationFormFields extends StatelessWidget {
  const MedicationFormFields({
    super.key,
    required this.controller,
    this.autofocusName = false,
  });

  final MedicationController controller;
  final bool autofocusName;

  @override
  Widget build(BuildContext context) {
    assert(5 <= formFieldOrderStep, 'fields must fit within one order slot');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ordered(
          0,
          CustomTextField(
            label: AppStrings.medicationName,
            controller: controller.nameController,
            hint: AppStrings.medicationNameHint,
            autofocus: autofocusName,
            textInputAction: TextInputAction.next,
            semanticLabel: AppStrings.medicationNameSemanticLabel,
            validator: (v) =>
            v == null || v.trim().isEmpty ? AppStrings.nameRequired : null,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(
          1,
          Obx(
                () => CustomDropdownField<String>(
              label: AppStrings.child,
              hint: AppStrings.selectChild,
              initialValue: controller.selectedChildId.value,
              items: controller.children
                  .map(
                    (child) => DropdownMenuItem(
                  value: child.id,
                  child: Text(child.name),
                ),
              )
                  .toList(),
              onChanged: (value) => controller.selectedChildId.value = value,
              validator: (v) =>
              v == null || v.isEmpty ? AppStrings.selectChild : null,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(
          2,
          CustomTextField(
            label: AppStrings.dosage,
            controller: controller.dosageController,
            hint: AppStrings.dosageHint,
            helperText: AppStrings.dosageHelper,
            textInputAction: TextInputAction.next,
            semanticLabel: AppStrings.dosageSemanticLabel,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(
          3,
          CustomDropdownField<String>(
            label: AppStrings.frequency,
            hint: AppStrings.selectFrequency,
            // Guard: only pass initialValue if it exists in the options list.
            // A value that isn't in the list causes a Flutter DropdownButton
            // assertion crash ("exactly one item must match the value").
            initialValue:
            MedicationController.frequencyOptions.contains(
              controller.selectedFrequency.value,
            )
                ? controller.selectedFrequency.value
                : null,
            items: MedicationController.frequencyOptions
                .map(
                  (option) =>
                  DropdownMenuItem(value: option, child: Text(option)),
            )
                .toList(),
            onChanged: (value) => controller.selectedFrequency.value = value,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(
          4,
          CustomTextField(
            label: AppStrings.notesOptional,
            controller: controller.notesController,
            hint: AppStrings.notesHint,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            semanticLabel: AppStrings.notesSemanticLabel,
          ),
        ),
      ],
    );
  }

  Widget _ordered(int index, Widget child) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(index.toDouble()),
      child: child,
    );
  }
}