import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/domain/entities/visit_document_entity.dart';

/// A read-only document row shown on the Visit Detail screen, with a
/// trailing download action.
class DocumentDownloadTile extends StatelessWidget {
  const DocumentDownloadTile({
    super.key,
    required this.document,
    required this.onDownload,
  });

  final VisitDocumentEntity document;
  final VoidCallback onDownload;

  String get _sizeLabel =>
      '${(document.fileSizeBytes / (1024 * 1024)).ceil()}MB';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
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
                  document.fileName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _sizeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: AppStrings.downloadDocumentLabel(document.fileName),
            excludeSemantics: true,
            child: IconButton(
              icon: const Icon(Icons.file_download_outlined),
              iconSize: AppDimensions.iconMd,
              constraints: const BoxConstraints(
                minWidth: AppDimensions.minTouchTarget,
                minHeight: AppDimensions.minTouchTarget,
              ),
              onPressed: onDownload,
            ),
          ),
        ],
      ),
    );
  }
}
