import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_strings.dart';

/// Reusable confirmation dialog with proper focus trapping.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  /// Shows the dialog and returns true if confirmed, false otherwise.
  static Future<bool> show(
      BuildContext context, {
        required String title,
        required String message,
        String confirmLabel = AppStrings.confirm,
        String cancelLabel = AppStrings.cancel,
        bool isDestructive = false,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Semantics(header: true, child: Text(title)),
      content: Text(message),
      actions: [
        Semantics(
          button: true,
          label: cancelLabel,
          hint: AppStrings.dismissDialogHint,
          excludeSemantics: true,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
        ),
        Semantics(
          button: true,
          label: confirmLabel,
          hint: isDestructive
              ? AppStrings.confirmDestructiveHint
              : AppStrings.confirmActionHint,
          excludeSemantics: true,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive ? theme.colorScheme.error : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}