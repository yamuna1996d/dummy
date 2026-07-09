import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/presentation/controllers/medication_controller.dart';
import 'package:kincare/presentation/modules/medication/medication_form_fields.dart';

import '../../widgets/app_snackbar.dart';
import '../../widgets/form_screen_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/unsaved_changes_scope.dart';

/// EDIT MEDICATION SCREEN
///
/// Flow: form pre-filled from the medication passed as the route
/// argument. Same discard-changes protection as Add Medication, tracked
/// against the medication's original values captured when the screen
/// opened. On save, returns to the medication list with a success
/// snackbar.
///
/// Reached from: Medication list (pencil/edit icon on a medication card).
/// Leads to: back to the medication list.
class EditMedicationScreen extends StatefulWidget {
  const EditMedicationScreen({super.key});

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final controller = Get.find<MedicationController>();
  MedicationEntity? _medication;

  late String _initialName;
  late String _initialDosage;
  late String _initialNotes;
  String? _initialChildId;
  String? _initialFrequency;

  @override
  void initState() {
    super.initState();
    // The medication to edit is passed as the route argument from the
    // medication list's edit button.
    _medication = Get.arguments as MedicationEntity?;
    if (_medication != null) {
      controller.populateForm(_medication!);
    }
    // Snapshot the form state immediately after population. These values
    // act as the "original" baseline — _hasUnsavedChanges compares the
    // current controller state against them to decide whether to show
    // the "Discard changes?" dialog on back navigation.
    _initialName = controller.nameController.text;
    _initialDosage = controller.dosageController.text;
    _initialNotes = controller.notesController.text;
    _initialChildId = controller.selectedChildId.value;
    _initialFrequency = controller.selectedFrequency.value;
  }

  // Compares live controller values against the snapshot taken in initState.
  // Any single field differing from its baseline means the form is dirty.
  bool get _hasUnsavedChanges =>
      controller.nameController.text != _initialName ||
          controller.dosageController.text != _initialDosage ||
          controller.notesController.text != _initialNotes ||
          controller.selectedChildId.value != _initialChildId ||
          controller.selectedFrequency.value != _initialFrequency;

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesScope(
      hasUnsavedChanges: () => _hasUnsavedChanges,
      child: FormScreenScaffold(
        title: const Text(AppStrings.editMedication),
        formKey: controller.formKey,
        children: [
          MedicationFormFields(controller: controller),
          const SizedBox(height: AppDimensions.spacingXl),
          Obx(
                () => PrimaryButton(
              label: AppStrings.saveChanges,
              isLoading: controller.isSaving.value,
              semanticLabel: AppStrings.saveChanges,
              onPressed: () => _save(_medication),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(MedicationEntity? original) async {
    if (!controller.formKey.currentState!.validate()) return;

    // Build a new entity that carries over read-only fields (id, isActive,
    // startDate, endDate) from the original while applying the user's edits.
    final updated = MedicationEntity(
      id: original?.id ?? '',
      name: controller.nameController.text.trim(),
      dosage: controller.dosageController.text.trim().isNotEmpty
          ? controller.dosageController.text.trim()
          : null,
      frequency: controller.selectedFrequency.value,
      isActive: original?.isActive ?? true,
      childId: controller.selectedChildId.value,
      notes: controller.notesController.text.trim().isNotEmpty
          ? controller.notesController.text.trim()
          : null,
      startDate: original?.startDate,
      endDate: original?.endDate,
    );

    final success = await controller.updateMedication(updated);
    if (success) {
      Get.back();
      AppSnackbar.success(AppStrings.medicationUpdatedSuccess);
    }
  }
}