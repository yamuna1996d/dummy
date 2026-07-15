import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/presentation/controllers/visit_document_item.dart';

/// A single document row inside the "Visit Summary" section, reactively
/// rendering one of three states: uploading (progress bar + time left),
/// uploaded (100%), or failed (network-failure state with retry + delete).
class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onRetry,
  });

  final VisitDocumentItem item;
  final VoidCallback onDelete;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final status = item.status.value;
      final isFailed = status == DocumentUploadStatus.failed;
      final isUploading = status == DocumentUploadStatus.uploading;
      final percent = (item.progress.value * 100).round();

      final subtitle = switch (status) {
        DocumentUploadStatus.uploading =>
          '${item.fileSizeMb}MB | $percent%-${item.secondsRemaining.value}sec left',
        DocumentUploadStatus.uploaded => '${item.fileSizeMb}MB | 100%',
        DocumentUploadStatus.failed => AppStrings.uploadFailed,
      };

      final semanticLabel = switch (status) {
        DocumentUploadStatus.uploading =>
          AppStrings.uploadProgressLabel(item.fileName, percent),
        DocumentUploadStatus.uploaded => item.fileName,
        DocumentUploadStatus.failed =>
          AppStrings.uploadFailedLabel(item.fileName),
      };

      return Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          decoration: BoxDecoration(
            color: isFailed ? AppColors.errorContainerLight : theme.cardColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: isFailed
                ? null
                : Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: AppDimensions.iconMd,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.fileName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isFailed
                                ? AppColors.errorLight
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isFailed ? FontWeight.w600 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: AppStrings.deleteDocumentLabel(item.fileName),
                    excludeSemantics: true,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      iconSize: AppDimensions.iconMd,
                      constraints: const BoxConstraints(
                        minWidth: AppDimensions.minTouchTarget,
                        minHeight: AppDimensions.minTouchTarget,
                      ),
                      onPressed: onDelete,
                    ),
                  ),
                  if (isFailed)
                    Semantics(
                      button: true,
                      label: AppStrings.retryUpload,
                      excludeSemantics: true,
                      child: IconButton(
                        icon: const Icon(Icons.refresh),
                        iconSize: AppDimensions.iconMd,
                        constraints: const BoxConstraints(
                          minWidth: AppDimensions.minTouchTarget,
                          minHeight: AppDimensions.minTouchTarget,
                        ),
                        onPressed: onRetry,
                      ),
                    ),
                ],
              ),
              if (isUploading) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: item.progress.value,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
