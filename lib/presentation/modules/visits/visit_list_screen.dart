import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/presentation/controllers/visit_controller.dart';
import 'package:kincare/presentation/widgets/empty_view.dart';
import 'package:kincare/presentation/widgets/error_view.dart';
import 'package:kincare/presentation/widgets/loading_view.dart';
import 'package:kincare/presentation/widgets/pill_badge.dart';

final _dateFormat = DateFormat('MMM d, yyyy');

/// VISIT LIST SCREEN
///
/// Flow: shows a child's logged visits (most recent first) as tappable
/// cards leading to Visit Details. Opened with
/// `{'childId': ..., 'childName': ...}` arguments from a Child Profile's
/// "Visits" section — mirrors [MedicationListScreen]'s filtered mode.
///
/// Reached from: Child Profile ("View all" on Visits).
/// Leads to: Visit Details, Add Visit.
class VisitListScreen extends GetView<VisitController> {
  const VisitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.horizontalPadding(context);

    final args = Get.arguments;
    final childId = args is Map ? args['childId'] as String? : null;
    final childName = args is Map ? args['childName'] as String? : null;
    controller.setChildFilter(childId);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          headingLevel: 1,
          child: Text(
            childId != null
                ? AppStrings.childVisitsTitle(childName ?? '')
                : AppStrings.visits,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spacingMd),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingView();
              if (controller.errorMessage.value != null) {
                return ErrorView(
                  message: controller.errorMessage.value!,
                  onRetry: controller.loadVisits,
                );
              }
              if (controller.filteredVisits.isEmpty) {
                return EmptyView(
                  message: childId != null
                      ? AppStrings.noVisitsForChild(childName ?? '')
                      : AppStrings.noVisits,
                  icon: Icons.event_note_outlined,
                  actionLabel: AppStrings.addVisit,
                  onAction: () => Get.toNamed(
                    AppRoutes.addVisit,
                    arguments: childId,
                  )?.then((_) => controller.refreshSilently()),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: AppDimensions.paddingSm,
                  ),
                  itemCount: controller.filteredVisits.length,
                  itemBuilder: (_, index) =>
                      _VisitCard(visit: controller.filteredVisits[index]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppStrings.addVisit,
        onPressed: () async {
          await Get.toNamed(AppRoutes.addVisit, arguments: childId);
          controller.refreshSilently();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});

  final VisitEntity visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '${visit.visitType}${visit.purpose != null ? ", ${visit.purpose}" : ""}',
      excludeSemantics: true,
      onTap: () => Get.toNamed(AppRoutes.visitDetails, arguments: visit.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.visitDetails, arguments: visit.id),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.chipTeal,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: const Icon(
                    Icons.event_note_outlined,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.purpose ?? visit.visitType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          PillBadge(
                            text: visit.visitType,
                            backgroundColor: AppColors.chipTeal,
                            textColor: AppColors.primaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                          if (visit.visitDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _dateFormat.format(visit.visitDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
