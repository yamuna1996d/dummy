import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';

/// Reusable text field with accessibility and validation support.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Full accessible name for the field, e.g. "Email address, tap and
  /// enter your email". When provided, this fully replaces the default
  /// TextFormField semantics (see build() for why).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final needsCustomSemantics = semanticLabel != null;
    final hasSuffix = suffixIcon != null;

    // When we need custom semantics AND there's a suffix icon (e.g. the
    // password show/hide toggle), we reserve the visual space for it
    // inside the field but render the *real* interactive icon separately
    // on top — otherwise ExcludeSemantics below would swallow its
    // button role along with the field's default semantics.
    final useOverlaySuffix = needsCustomSemantics && hasSuffix;

    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        // FIX: Only set labelText when non-empty. An empty string still
        // counts as an active label in Flutter, which suppresses hintText
        // until the field is focused. By omitting it, hintText is always
        // visible when the field is empty.
        labelText: label.isNotEmpty ? label : null,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: AppDimensions.iconMd)
            : null,
        suffixIcon: hasSuffix
            ? (useOverlaySuffix
            ? const IgnorePointer(child: SizedBox(width: 48))
            : suffixIcon)
            : null,
        errorMaxLines: 2,
      ),
    );

    if (!needsCustomSemantics) {
      return field;
    }

    final combinedLabel = [
      semanticLabel,
      if (errorText != null) 'Error: $errorText',
    ].join(', ');

    final semanticField = controller != null
        ? AnimatedBuilder(
      animation: controller!,
      builder: (context, _) => Semantics(
        textField: true,
        label: combinedLabel,
        value: obscureText ? null : controller!.text,
        onTap: () => focusNode?.requestFocus(),
        child: ExcludeSemantics(child: field),
      ),
    )
        : Semantics(
      textField: true,
      label: combinedLabel,
      onTap: () => focusNode?.requestFocus(),
      child: ExcludeSemantics(child: field),
    );

    if (!useOverlaySuffix) {
      return semanticField;
    }

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        semanticField,
        Padding(padding: const EdgeInsets.only(right: 12), child: suffixIcon),
      ],
    );
  }
}