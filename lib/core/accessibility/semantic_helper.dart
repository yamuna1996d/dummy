import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utility methods for consistent semantic annotations.
abstract final class SemanticHelper {
  /// Wraps a widget with button semantics including label, hint, and role.
  static Widget button({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onTap,
      excludeSemantics: true,
      child: child,
    );
  }

  /// Wraps a widget with image semantics.
  static Widget image({required Widget child, required String label}) {
    return Semantics(image: true, label: label, child: child);
  }

  /// Wraps a widget with header semantics.
  static Widget header({required Widget child, required String label}) {
    return Semantics(header: true, label: label, child: child);
  }

  /// Wraps a widget with text field semantics.
  static Widget textField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      value: value,
      excludeSemantics: true,
      child: child,
    );
  }

  /// Excludes a widget from the semantic tree.
  static Widget exclude({required Widget child}) {
    return ExcludeSemantics(child: child);
  }

  /// Merges child semantics into a single node.
  static Widget merge({required Widget child}) {
    return MergeSemantics(child: child);
  }

  /// Creates a semantic announce for screen readers.
  static Future<void> announce(BuildContext context, String message) {
    final view = View.of(context);
    return SemanticsService.sendAnnouncement(view, message, TextDirection.ltr);
  }
}
