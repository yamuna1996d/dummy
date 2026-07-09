import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_strings.dart';

import 'confirm_dialog.dart';

/// Wraps a form screen so that leaving it — back arrow, system back
/// gesture/button — while [hasUnsavedChanges] is true shows a "Discard
/// changes?" confirmation first. Leaving with no unsaved changes exits
/// immediately.
class UnsavedChangesScope extends StatelessWidget {
  const UnsavedChangesScope({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
  });

  final bool Function() hasUnsavedChanges;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: child,
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    if (!hasUnsavedChanges()) {
      Get.back();
      return;
    }
    final discard = await ConfirmDialog.show(
      context,
      title: AppStrings.discardChanges,
      message: AppStrings.unsavedChangesMessage,
      confirmLabel: AppStrings.discard,
      cancelLabel: AppStrings.keepEditing,
      isDestructive: true,
    );
    if (discard) Get.back();
  }
}
