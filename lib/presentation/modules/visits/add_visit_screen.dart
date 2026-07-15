import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/presentation/controllers/visit_controller.dart';
import 'package:kincare/presentation/modules/visits/visit_form_fields.dart';
import 'package:kincare/presentation/modules/visits/widgets/visit_form_footer.dart';
import 'package:kincare/presentation/widgets/app_snackbar.dart';
import 'package:kincare/presentation/widgets/unsaved_changes_scope.dart';

/// ADD VISIT SCREEN
///
/// Flow: form to log a new visit (type, date, purpose, physician,
/// hospital, uploaded documents, comment), optionally pre-scoped to a
/// child when opened with that child's id as the route argument. Document
/// uploads run in the background (see [VisitController.pickDocument]) and
/// can fail if connectivity drops mid-upload — a failed row shows a retry
/// action rather than blocking the rest of the form. Only successfully
/// uploaded documents are attached when the visit is saved.
///
/// Reached from: Visit list ("Add Visit"), Visit Details ("+ Add Visit").
/// Leads to: back to whichever screen opened it.
class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final controller = Get.find<VisitController>();
  String? _initialChildId;

  @override
  void initState() {
    super.initState();
    controller.clearForm();
    final preselectedChildId = Get.arguments;
    if (preselectedChildId is String) {
      controller.selectedChildId.value = preselectedChildId;
    }
    // Capture AFTER preselection so a pre-scoped child alone doesn't count
    // as an unsaved change.
    _initialChildId = controller.selectedChildId.value;
  }

  bool get _hasUnsavedChanges =>
      controller.purposeController.text.trim().isNotEmpty ||
      controller.physicianController.text.trim().isNotEmpty ||
      controller.hospitalController.text.trim().isNotEmpty ||
      controller.commentController.text.trim().isNotEmpty ||
      controller.selectedChildId.value != _initialChildId ||
      controller.selectedDate.value != null ||
      controller.documents.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesScope(
      hasUnsavedChanges: () => _hasUnsavedChanges,
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            headingLevel: 1,
            child: const Text(AppStrings.addVisit),
          ),
        ),
        body: Form(
          key: controller.formKey,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingMd),
                    child: VisitFormFields(
                      controller: controller,
                      autofocusPurpose: true,
                    ),
                  ),
                ),
                VisitFormFooter(
                  controller: controller,
                  saveLabel: AppStrings.save,
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!controller.formKey.currentState!.validate()) return;

    final visit = VisitEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      visitType:
          controller.selectedVisitType.value ??
          VisitController.visitTypeOptions.first,
      childId: controller.selectedChildId.value,
      visitDate: controller.selectedDate.value,
      purpose: controller.purposeController.text.trim(),
      physician: controller.physicianController.text.trim().isNotEmpty
          ? controller.physicianController.text.trim()
          : null,
      hospital: controller.hospitalController.text.trim().isNotEmpty
          ? controller.hospitalController.text.trim()
          : null,
      comment: controller.commentController.text.trim().isNotEmpty
          ? controller.commentController.text.trim()
          : null,
      documents: controller.uploadedDocuments.map((d) => d.toEntity()).toList(),
    );

    final success = await controller.createVisit(visit);
    if (success) {
      Get.back();
      AppSnackbar.success(AppStrings.visitAddedSuccess);
    }
  }
}
