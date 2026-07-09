import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/presentation/controllers/medication_controller.dart';
import 'package:kincare/presentation/widgets/kincare_app_bar.dart';
import 'package:kincare/presentation/widgets/app_drawer.dart';

import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/pill_badge.dart';

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

    final headingText = childId != null
        ? AppStrings.medicationHistory
        : AppStrings.allMedications;

    return Scaffold(
      appBar: childId != null
          ? AppBar(
        title: Semantics(
          headingLevel: 1,
          child: Text(AppStrings.childMedicationsTitle(childName ?? '')),
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
                  child: Semantics(
                    // The AppBar already carries the level-1 heading when
                    // filtered (see above); avoid a second one there.
                    // The heading and the subtitle beneath it are merged
                    // into one announcement — "Medication history. Manage
                    // daily dosage and records." — instead of reading as
                    // two disconnected stops.
                    headingLevel: childId == null ? 1 : null,
                    label: '$headingText. ${AppStrings.medicationListSubtitle}',
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headingText,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          AppStrings.medicationListSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: AppStrings.addMedication,
                  excludeSemantics: true,
                  onTap: () async {
                    await Get.toNamed(
                      AppRoutes.addMedication,
                      arguments: childId,
                    );
                    controller.refreshSilently();
                  },
                  child: _FocusHighlightButton(
                    width: 48,
                    height: 48,
                    borderRadius: AppDimensions.radiusLg,
                    baseColor: theme.colorScheme.primary,
                    isFilled: true,
                    icon: Icons.add,
                    iconColor: Colors.white,
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
                      ? AppStrings.noMedicationsForChild(childName ?? '')
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
        ? AppStrings.unassigned
        : matchedChildren.first.name;
    final isActive = medication.isActive;

    // Merges the whole informational block — name, child, dosage, and
    // active/inactive status — into a single announcement, rather than
    // reading the name, the child pill, the frequency text, and the
    // status badge as four disconnected stops.
    final cardLabel = AppStrings.medicationCardLabel(
      name: medication.name,
      isActive: isActive,
      childName: childName,
      frequency: medication.frequency,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          children: [
            Semantics(
              label: cardLabel,
              excludeSemantics: true,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
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
                    text: isActive ? AppStrings.active : AppStrings.inactive,
                    backgroundColor: isActive
                        ? AppColors.successLight
                        : theme.colorScheme.surfaceContainerHighest,
                    textColor: isActive
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
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
                      label: AppStrings.editItemLabel(medication.name),
                      excludeSemantics: true,
                      onTap: () async {
                        await Get.toNamed(
                          AppRoutes.editMedication,
                          arguments: medication,
                        );
                        controller.refreshSilently();
                      },
                      child: _FocusHighlightButton(
                        width: 44,
                        height: 44,
                        borderRadius: AppDimensions.radiusMd,
                        baseColor: AppColors.primaryLight,
                        icon: Icons.edit_outlined,
                        iconColor: AppColors.primaryLight,
                        iconSize: 20,
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
                  const SizedBox(width: AppDimensions.spacingMd),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: Semantics(
                      button: true,
                      label: AppStrings.deleteItemLabel(medication.name),
                      excludeSemantics: true,
                      onTap: () => _confirmDelete(context),
                      child: _FocusHighlightButton(
                        width: 44,
                        height: 44,
                        borderRadius: AppDimensions.radiusMd,
                        baseColor: AppColors.errorLight,
                        icon: Icons.delete_outline,
                        iconColor: AppColors.errorLight,
                        iconSize: 20,
                        onPressed: () => _confirmDelete(context),
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

/// A bordered icon button that grows a visible highlight ring around its
/// border when it receives keyboard/switch-control focus.
///
/// This is what accessibility auditors and screen-reader/switch-control
/// testers look for: a clearly visible focus indicator on every
/// interactive element, distinct from its resting state. Without this,
/// buttons that only rely on the "pressed" ripple are effectively
/// invisible to anyone tabbing or scanning through the screen.
class _FocusHighlightButton extends StatefulWidget {
  const _FocusHighlightButton({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.baseColor,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.iconSize = 24,
    this.isFilled = false,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color baseColor;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final bool isFilled;
  final Future<void> Function() onPressed;

  @override
  State<_FocusHighlightButton> createState() => _FocusHighlightButtonState();
}

class _FocusHighlightButtonState extends State<_FocusHighlightButton> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.secondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.isFilled ? widget.baseColor : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          // Border thickens and switches to the theme's highlight color
          // while focused, so the ring is visible against any background.
          color: _isFocused ? highlightColor : widget.baseColor,
          width: _isFocused ? 3 : (widget.isFilled ? 0 : 1.5),
        ),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: highlightColor.withValues(alpha: 0.35),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: IconButton(
        focusNode: _focusNode,
        icon: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
        onPressed: () => widget.onPressed(),
      ),
    );
  }
}