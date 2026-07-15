import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/presentation/controllers/visit_controller.dart';
import 'package:kincare/presentation/modules/visits/widgets/document_download_tile.dart';
import 'package:kincare/presentation/widgets/error_view.dart';
import 'package:kincare/presentation/widgets/loading_view.dart';
import 'package:kincare/presentation/widgets/primary_button.dart';

final _dateFormat = DateFormat('MM/dd/yyyy');

/// VISIT DETAIL SCREEN
///
/// Flow: read-only summary of one visit — type, date, purpose, physician,
/// hospital, comment, and its uploaded documents (each downloadable). The
/// "Edit" button opens Edit Visit pre-filled with this record; "+ Add
/// Visit" opens Add Visit pre-scoped to the same child.
///
/// Always navigated to with the visit's id (a `String`) as `Get.arguments`
/// — the screen fetches the full record itself via [VisitController]
/// rather than receiving the whole object, so a loading spinner shows
/// briefly while that fetch is in flight.
///
/// Reached from: Visit list (card tap).
/// Leads to: Edit Visit, Add Visit.
class VisitDetailsScreen extends StatelessWidget {
  const VisitDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visitId = Get.arguments as String?;
    final controller = Get.find<VisitController>();

    if (visitId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.visitDetails)),
        body: const Center(child: Text(AppStrings.noData)),
      );
    }

    // Avoids a redundant fetch when navigating back to the same visit.
    if (controller.selectedVisit.value?.id != visitId) {
      controller.loadVisitDetails(visitId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          headingLevel: 1,
          child: const Text(AppStrings.visitDetails),
        ),
      ),
      body: Obx(() {
        final visit = controller.selectedVisit.value;
        if (visit == null || visit.id != visitId) {
          if (controller.errorMessage.value != null) {
            return ErrorView(
              message: controller.errorMessage.value!,
              onRetry: () => controller.loadVisitDetails(visitId),
            );
          }
          return const LoadingView();
        }
        return _VisitDetailBody(visit: visit);
      }),
    );
  }
}

class _VisitDetailBody extends StatelessWidget {
  const _VisitDetailBody({required this.visit});

  final VisitEntity visit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(visit: visit),
                const SizedBox(height: AppDimensions.spacingLg),
                if (visit.purpose != null) ...[
                  _DetailField(label: AppStrings.purpose, value: visit.purpose!),
                  const SizedBox(height: AppDimensions.spacingMd),
                ],
                if (visit.physician != null) ...[
                  _DetailField(
                    label: AppStrings.physicianTreatmentProvider,
                    value: visit.physician!,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                ],
                if (visit.hospital != null) ...[
                  _DetailField(
                    label: AppStrings.hospitalFacility,
                    value: visit.hospital!,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                ],
                if (visit.comment != null) ...[
                  _DetailField(label: AppStrings.comment, value: visit.comment!),
                  const SizedBox(height: AppDimensions.spacingMd),
                ],
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  AppStrings.documents,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                if (visit.documents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMd,
                    ),
                    child: Text(
                      AppStrings.noDocumentsUploaded,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ...visit.documents.map(
                    (doc) => DocumentDownloadTile(
                      document: doc,
                      onDownload: () => Get.snackbar(
                        AppStrings.documents,
                        AppStrings.downloadDocumentLabel(doc.fileName),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _AddVisitFooter(childId: visit.childId),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.visit});

  final VisitEntity visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.visitType,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (visit.visitDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.asOf} ${_dateFormat.format(visit.visitDate!)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Semantics(
          button: true,
          label: AppStrings.editVisit,
          excludeSemantics: true,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Get.toNamed(AppRoutes.editVisit, arguments: visit);
              Get.find<VisitController>().loadVisitDetails(visit.id);
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text(AppStrings.edit),
          ),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _AddVisitFooter extends StatelessWidget {
  const _AddVisitFooter({required this.childId});

  final String? childId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: AppStrings.addVisit,
          icon: Icons.add,
          onPressed: () => Get.toNamed(AppRoutes.addVisit, arguments: childId),
        ),
      ),
    );
  }
}
