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

/// EDIT VISIT SCREEN
///
/// Flow: form pre-filled from the visit passed as the route argument.
/// Previously uploaded documents show as already-uploaded rows; newly
/// added ones go through the same upload/retry flow as Add Visit. Same
/// discard-changes protection as Add Visit, tracked against the visit's
/// original values captured when the screen opened.
///
/// Reached from: Visit Details ("Edit").
/// Leads to: back to Visit Details.
class EditVisitScreen extends StatefulWidget {
  const EditVisitScreen({super.key});

  @override
  State<EditVisitScreen> createState() => _EditVisitScreenState();
}

class _EditVisitScreenState extends State<EditVisitScreen> {
  final controller = Get.find<VisitController>();
  VisitEntity? _visit;

  late String _initialPurpose;
  late String _initialPhysician;
  late String _initialHospital;
  late String _initialComment;
  String? _initialChildId;
  String? _initialVisitType;
  DateTime? _initialDate;
  late int _initialDocumentCount;

  @override
  void initState() {
    super.initState();
    _visit = Get.arguments as VisitEntity?;
    if (_visit != null) {
      controller.populateForm(_visit!);
    }
    _initialPurpose = controller.purposeController.text;
    _initialPhysician = controller.physicianController.text;
    _initialHospital = controller.hospitalController.text;
    _initialComment = controller.commentController.text;
    _initialChildId = controller.selectedChildId.value;
    _initialVisitType = controller.selectedVisitType.value;
    _initialDate = controller.selectedDate.value;
    _initialDocumentCount = controller.documents.length;
  }

  bool get _hasUnsavedChanges =>
      controller.purposeController.text != _initialPurpose ||
      controller.physicianController.text != _initialPhysician ||
      controller.hospitalController.text != _initialHospital ||
      controller.commentController.text != _initialComment ||
      controller.selectedChildId.value != _initialChildId ||
      controller.selectedVisitType.value != _initialVisitType ||
      controller.selectedDate.value != _initialDate ||
      controller.documents.length != _initialDocumentCount;

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesScope(
      hasUnsavedChanges: () => _hasUnsavedChanges,
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            headingLevel: 1,
            child: const Text(AppStrings.editVisit),
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
                    child: VisitFormFields(controller: controller),
                  ),
                ),
                VisitFormFooter(
                  controller: controller,
                  saveLabel: AppStrings.saveChanges,
                  onSave: () => _save(_visit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(VisitEntity? original) async {
    if (!controller.formKey.currentState!.validate()) return;

    final updated = VisitEntity(
      id: original?.id ?? '',
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

    final success = await controller.updateVisit(updated);
    if (success) {
      Get.back();
      AppSnackbar.success(AppStrings.visitUpdatedSuccess);
    }
  }
}
