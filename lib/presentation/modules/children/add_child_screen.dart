import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';

import '../../widgets/app_snackbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/form_screen_scaffold.dart';
import '../../widgets/primary_button.dart';

/// ADD CHILD SCREEN
///
/// Flow: simple form (name + notes) to create a new child record. On
/// save, returns `true` to whichever screen opened it and shows a
/// success snackbar.
///
/// Reached from: Children list or Dashboard ("Add child").
/// Leads to: back to whichever screen opened it.
class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: const Text(AppStrings.addChild),
      formKey: _formKey,
      children: [
        CustomTextField(
          label: AppStrings.childName,
          controller: _nameController,
          focusNode: _nameFocus,
          autofocus: true,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.person,
          semanticLabel: AppStrings.childNameSemanticLabel,
          validator: (v) =>
          v == null || v.trim().isEmpty ? AppStrings.nameRequired : null,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        CustomTextField(
          label: AppStrings.description,
          controller: _descriptionController,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.notes,
          semanticLabel: AppStrings.descriptionSemanticLabel,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        PrimaryButton(
          label: AppStrings.save,
          isLoading: _isSaving,
          semanticLabel: AppStrings.saveNewChild,
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Simulate save
    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() => _isSaving = false);
    Get.back(result: true);
    AppSnackbar.success(AppStrings.childAddedSuccess);
  }
}