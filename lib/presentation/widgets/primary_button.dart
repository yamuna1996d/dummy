import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';

/// Reusable primary action button with accessibility support.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.semanticLabel,
    this.semanticHint,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final String? semanticLabel;
  final String? semanticHint;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: width ?? double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: AppDimensions.iconMd,
                width: AppDimensions.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconMd),
                    const SizedBox(width: AppDimensions.spacingSm),
                  ],
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );

    return Semantics(
      button: true,
      enabled: isEnabled && !isLoading,
      label: semanticLabel ?? label,
      hint: semanticHint,
      child: button,
    );
  }
}
