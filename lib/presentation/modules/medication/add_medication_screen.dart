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

/// ADD MEDICATION SCREEN
///
/// Flow: form to create a medication, optionally pre-scoped to a child
/// when opened with that child's id as the route argument (e.g. from a
/// Child Profile's "+" button). If the user tries to leave — back arrow,
/// system back gesture/button — while there's unsaved input, a "Discard
/// changes?" dialog blocks the exit until confirmed; leaving with no
/// changes (or a child preselection only) exits immediately. On save,
/// returns to whichever screen opened it with a success snackbar.
///
/// Reached from: Medication list ("Add medication"), Child Profile ("+").
/// Leads to: back to whichever screen opened it.
class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final controller = Get.find<MedicationController>();
  String? _initialChildId;

  @override
  void initState() {
    super.initState();
    controller.clearForm();
    // If opened from a Child Profile's "+" button, the child's id arrives as
    // a String argument and is pre-selected in the dropdown.
    final preselectedChildId = Get.arguments;
    if (preselectedChildId is String) {
      controller.selectedChildId.value = preselectedChildId;
    }
    // Capture the child id AFTER preselection so that a pre-scoped child alone
    // does not count as an "unsaved change" — only changes the user types do.
    _initialChildId = controller.selectedChildId.value;
  }

  // Returns true if the user has entered anything beyond the automatic
  // preselection. A pre-scoped child (no text changes) should let the user
  // leave without a "Discard changes?" prompt.
  bool get _hasUnsavedChanges =>
      controller.nameController.text.trim().isNotEmpty ||
          controller.dosageController.text.trim().isNotEmpty ||
          controller.notesController.text.trim().isNotEmpty ||
          controller.selectedChildId.value != _initialChildId ||
          controller.selectedFrequency.value != null;

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesScope(
      // UnsavedChangesScope wraps the Scaffold in a PopScope that intercepts
      // the back gesture/button. If hasUnsavedChanges() returns true, it shows
      // a "Discard changes?" dialog before allowing navigation to proceed.
      hasUnsavedChanges: () => _hasUnsavedChanges,
      child: FormScreenScaffold(
        title: const Text(AppStrings.addMedication),
        formKey: controller.formKey,
        children: [
          MedicationFormFields(controller: controller, autofocusName: true),
          const SizedBox(height: AppDimensions.spacingXl),
          Obx(
                () => PrimaryButton(
              label: AppStrings.saveMedication,
              isLoading: controller.isSaving.value,
              semanticLabel: AppStrings.saveMedication,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!controller.formKey.currentState!.validate()) return;

    final medication = MedicationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: controller.nameController.text.trim(),
      dosage: controller.dosageController.text.trim().isNotEmpty
          ? controller.dosageController.text.trim()
          : null,
      frequency: controller.selectedFrequency.value,
      childId: controller.selectedChildId.value,
      notes: controller.notesController.text.trim().isNotEmpty
          ? controller.notesController.text.trim()
          : null,
    );

    final success = await controller.createMedication(medication);
    if (success) {
      Get.back();
      AppSnackbar.success(AppStrings.medicationAddedSuccess);
    }
  }
}