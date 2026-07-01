import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/core/widgets/confirm_dialog.dart';
import 'package:kincare/core/widgets/empty_view.dart';
import 'package:kincare/core/widgets/error_view.dart';
import 'package:kincare/core/widgets/loading_view.dart';
import 'package:kincare/core/widgets/pill_badge.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/presentation/controllers/medication_controller.dart';
import 'package:kincare/presentation/widgets/kincare_app_bar.dart';
import 'package:kincare/presentation/widgets/app_drawer.dart';

/// MEDICATION LIST SCREEN
///
/// Flow: has two modes depending on how it's opened.
///   1. Default (drawer): shows every medication for every child, with
///      its own "Add medication" action and the normal app drawer.
///   2. Filtered (a child's "View History" link): opened with
///      `{'childId': ..., 'childName': ...}` arguments — shows only that
///      child's medication history (active + inactive together), with a
///      plain back arrow instead of the drawer.
/// Each card lets you edit (pencil icon) or delete (trash icon, with a
/// confirmation dialog) that medication.
///
/// Reached from: "Medications" in the navigation drawer (unfiltered), or
/// a Child Profile's "View History" link (filtered).
/// Leads to: Add Medication, Edit Medication.
class MedicationListScreen extends GetView<MedicationController> {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);

    // Arguments are a Map only when opened from a Child Profile ("View History").
    // When opened from the drawer (default route), arguments are null and
    // childId stays null, meaning all medications are shown.
    final args = Get.arguments;
    final childId = args is Map ? args['childId'] as String? : null;
    final childName = args is Map ? args['childName'] as String? : null;
    // setChildFilter is called here (build) rather than initState because
    // MedicationListScreen is a StatelessWidget — it has no lifecycle methods.
    // setChildFilter is idempotent (skips if the value hasn't changed), so
    // calling it on every build is safe.
    controller.setChildFilter(childId);

    return Scaffold(
      appBar: childId != null
          ? AppBar(
              title: Semantics(
                headingLevel: 1,
                child: Text("$childName's Medications"),
              ),
            )
          : const KinCareAppBar(),
      drawer: childId != null ? null : const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        // The AppBar already carries the level-1 heading
                        // when filtered (see above); avoid a second one.
                        headingLevel: childId == null ? 1 : null,
                        child: Text(
                          childId != null
                              ? 'Medication history'
                              : 'All medications',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Manage daily dosage and records',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: AppStrings.addMedication,
                  hint: 'Double tap to add a new medication',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      // Await the navigation so the list refreshes the moment
                      // the user pops back from the Add Medication screen.
                      onPressed: () async {
                        await Get.toNamed(
                          AppRoutes.addMedication,
                          arguments: childId,
                        );
                        controller.refreshSilently();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingView();
              if (controller.errorMessage.value != null) {
                return ErrorView(
                  message: controller.errorMessage.value!,
                  onRetry: controller.loadMedications,
                );
              }
              if (controller.filteredMedications.isEmpty) {
                return EmptyView(
                  message: childId != null
                      ? 'No medications for $childName yet'
                      : AppStrings.noMedications,
                  icon: Icons.medication_outlined,
                  actionLabel: AppStrings.addMedication,
                  onAction: () => Get.toNamed(
                    AppRoutes.addMedication,
                    arguments: childId,
                  )?.then((_) => controller.refreshSilently()),
                );
              }
              return _MedicationCardList(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}

const _medIcons = [
  Icons.medication_outlined,
  Icons.medical_services_outlined,
  Icons.link,
];
const _medIconBgs = [
  AppColors.chipTeal,
  AppColors.chipGreen,
  AppColors.chipOrange,
];

class _MedicationCardList extends StatelessWidget {
  const _MedicationCardList({required this.controller});
  final MedicationController controller;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.horizontalPadding(context);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: Obx(
        () => ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: AppDimensions.paddingSm,
          ),
          itemCount: controller.filteredMedications.length,
          itemBuilder: (_, index) => _MedicationCard(
            medication: controller.filteredMedications[index],
            controller: controller,
            index: index,
          ),
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.medication,
    required this.controller,
    required this.index,
  });

  final MedicationEntity medication;
  final MedicationController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _medIcons[index % _medIcons.length];
    final iconBg = _medIconBgs[index % _medIconBgs.length];
    // Look up the child's display name from the controller's in-memory list
    // instead of storing it on MedicationEntity, keeping the entity clean.
    final matchedChildren = controller.children.where(
      (c) => c.id == medication.childId,
    );
    final childName = matchedChildren.isEmpty
        ? 'Unassigned'
        : matchedChildren.first.name;
    final isActive = medication.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Icon(icon, color: AppColors.primaryLight, size: 24),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          PillBadge(
                            text: childName,
                            backgroundColor: AppColors.chipTeal,
                            textColor: AppColors.primaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                          const SizedBox(width: 8),
                          if (medication.frequency != null) ...[
                            Expanded(
                              child: Text(
                                medication.frequency!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PillBadge(
                  text: isActive ? 'Active' : 'Inactive',
                  backgroundColor: isActive
                      ? AppColors.successLight
                      : theme.colorScheme.surfaceContainerHighest,
                  textColor: isActive
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: AppDimensions.spacingMd),
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(0),
                    child: Semantics(
                      button: true,
                      label: 'Edit ${medication.name}',
                      excludeSemantics: true,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                          // Await so the list refreshes on return.
                          onPressed: () async {
                            await Get.toNamed(
                              AppRoutes.editMedication,
                              arguments: medication,
                            );
                            controller.refreshSilently();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: Semantics(
                      button: true,
                      label: 'Delete ${medication.name}',
                      excludeSemantics: true,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.errorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.errorLight,
                            size: 20,
                          ),
                          onPressed: () => _confirmDelete(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: AppStrings.deleteMedication,
      message: AppStrings.deleteConfirmation,
      confirmLabel: AppStrings.delete,
      isDestructive: true,
    );
    if (confirmed) {
      await controller.deleteMedication(medication.id);
    }
  }
}
