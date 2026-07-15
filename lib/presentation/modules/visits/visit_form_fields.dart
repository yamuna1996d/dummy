import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/presentation/controllers/visit_controller.dart';
import 'package:kincare/presentation/modules/visits/widgets/document_upload_box.dart';
import 'package:kincare/presentation/modules/visits/widgets/document_upload_tile.dart';
import 'package:kincare/presentation/widgets/custom_dropdown_field.dart';
import 'package:kincare/presentation/widgets/custom_text_field.dart';
import 'package:kincare/presentation/widgets/form_screen_scaffold.dart'
    show formFieldOrderStep;

final _dateFormat = DateFormat('MM/dd/yyyy');

/// Visit type/date/purpose/physician/hospital/documents/comment fields
/// shared by Add and Edit Visit — the only difference between those two
/// screens is what happens on save, not the form itself.
class VisitFormFields extends StatelessWidget {
  const VisitFormFields({
    super.key,
    required this.controller,
    this.autofocusPurpose = false,
  });

  final VisitController controller;
  final bool autofocusPurpose;

  @override
  Widget build(BuildContext context) {
    assert(7 <= formFieldOrderStep, 'fields must fit within one order slot');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ordered(
          0,
          Obx(
            () => CustomDropdownField<String>(
              label: AppStrings.child,
              hint: AppStrings.selectChild,
              initialValue: controller.selectedChildId.value,
              items: controller.children
                  .map(
                    (child) =>
                        DropdownMenuItem(value: child.id, child: Text(child.name)),
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
          1,
          Obx(
            () => CustomDropdownField<String>(
              label: AppStrings.visitType,
              hint: AppStrings.selectVisitType,
              initialValue: controller.selectedVisitType.value,
              items: VisitController.visitTypeOptions
                  .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
              onChanged: (value) => controller.selectedVisitType.value = value,
              validator: (v) =>
                  v == null || v.isEmpty ? AppStrings.visitTypeRequired : null,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(2, _VisitDateField(controller: controller)),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(
          3,
          CustomTextField(
            label: AppStrings.purpose,
            controller: controller.purposeController,
            hint: AppStrings.purposeHint,
            autofocus: autofocusPurpose,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? AppStrings.purposeRequired : null,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(
          4,
          CustomTextField(
            label: AppStrings.physicianTreatmentProvider,
            controller: controller.physicianController,
            hint: AppStrings.physicianHint,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _ordered(
          5,
          CustomTextField(
            label: AppStrings.hospitalFacility,
            controller: controller.hospitalController,
            hint: AppStrings.hospitalHint,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        _ordered(6, _VisitSummarySection(controller: controller)),
        const SizedBox(height: AppDimensions.spacingLg),
        _ordered(
          7,
          Text(
            AppStrings.comment,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        _ordered(
          8,
          CustomTextField(
            label: '',
            controller: controller.commentController,
            hint: AppStrings.enterComment,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            semanticLabel: AppStrings.comment,
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

class _VisitDateField extends StatelessWidget {
  const _VisitDateField({required this.controller});

  final VisitController controller;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) controller.selectedDate.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = controller.selectedDate.value;
      final displayText = date != null ? _dateFormat.format(date) : 'MM/DD/YYYY';

      return Semantics(
        button: true,
        label: date != null
            ? '${AppStrings.visitDate}: $displayText'
            : AppStrings.selectVisitDate,
        excludeSemantics: true,
        onTap: () => _pickDate(context),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          onTap: () => _pickDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              displayText,
              style: date != null
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class _VisitSummarySection extends StatelessWidget {
  const _VisitSummarySection({required this.controller});

  final VisitController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.visitSummary,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        DocumentUploadBox(onTap: controller.pickDocument),
        const SizedBox(height: AppDimensions.spacingSm),
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.supportedFiles,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              AppStrings.maxFileSize,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Obx(
          () => Column(
            children: controller.documents
                .map(
                  (item) => DocumentUploadTile(
                    item: item,
                    onDelete: () => controller.removeDocument(item),
                    onRetry: () => controller.retryUpload(item),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
