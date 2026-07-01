import 'package:flutter/material.dart';

/// Reusable dropdown field matching [CustomTextField]'s visual style.
class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hint,
    this.validator,
    this.semanticLabel,
  });

  final String label;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final FormFieldValidator<T>? validator;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<T>(
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      icon: const Icon(Icons.expand_more),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );

    // See CustomTextField for why this only wraps (and excludes the
    // field's own semantics) when there's an explicit override to avoid
    // announcing the label twice.
    if (semanticLabel == null) return field;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: field,
    );
  }
}
