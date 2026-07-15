import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/presentation/modules/visits/widgets/dashed_border_box.dart';

/// The dashed drop-zone box prompting the user to choose a file to upload
/// ("Visit Summary" section of the Add/Edit Visit form).
class DocumentUploadBox extends StatelessWidget {
  const DocumentUploadBox({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '${AppStrings.chooseFile}${AppStrings.toUpload}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: DashedBorderBox(
            color: theme.colorScheme.outline,
            radius: AppDimensions.radiusLg,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingXl,
                horizontal: AppDimensions.paddingMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    size: AppDimensions.iconLg,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: AppStrings.chooseFile,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: AppStrings.toUpload),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
