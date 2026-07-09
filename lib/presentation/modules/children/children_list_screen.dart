import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/presentation/controllers/children_controller.dart';
import 'package:kincare/presentation/widgets/kincare_app_bar.dart';
import 'package:kincare/presentation/widgets/app_drawer.dart';

import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/icon_value_chip.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/pill_badge.dart';

/// CHILDREN LIST SCREEN
///
/// Flow: paginated list of every child (5 per page). Tapping the chevron
/// on a card opens that child's full profile. The header "+" action opens
/// the add-child form.
///
/// Reached from: Dashboard ("View all" or "Add child"), or "Children" in
/// the navigation drawer.
/// Leads to: Child Profile (chevron tap), Add Child screen ("+").
class ChildrenListScreen extends GetView<ChildrenController> {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      appBar: const KinCareAppBar(),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Semantics(
              headingLevel: 1,
              child: Text(
                AppStrings.yourChildren,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingView();
              if (controller.errorMessage.value != null) {
                return ErrorView(
                  message: controller.errorMessage.value!,
                  onRetry: controller.loadChildren,
                );
              }
              if (controller.filteredChildren.isEmpty) {
                return EmptyView(
                  message: AppStrings.noChildren,
                  icon: Icons.child_care_outlined,
                  actionLabel: AppStrings.addChild,
                  onAction: () => Get.toNamed(AppRoutes.addChild),
                );
              }
              return _ChildrenCardList(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}

class _ChildrenCardList extends StatelessWidget {
  const _ChildrenCardList({required this.controller});
  final ChildrenController controller;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.horizontalPadding(context);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: Obx(() {
        final paged = controller.pagedChildren;
        final page = controller.currentPage.value;
        final pageSize = ChildrenController.pageSize;
        final startIndex = (page - 1) * pageSize;

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: AppDimensions.paddingSm,
          ),
          itemCount: paged.length + 1,
          itemBuilder: (context, index) {
            if (index == paged.length) {
              return _PaginationFooter(controller: controller);
            }
            return _ChildCard(child: paged[index], index: startIndex + index);
          },
        );
      }),
    );
  }
}

// These arrays supply the *visual* chip data on each child card.
// They are cycled by list index (index % length) rather than being
// real clinical data — the actual per-child health details (blood group,
// allergies, appointments) live in children.json and are shown on the
// Child Profile screen, not on this list card.
const _bloodTypes = ['B+', 'O+', 'A+', 'B-', 'AB+'];
const _bloodTypeColors = [
  AppColors.chipGreen,
  AppColors.chipAmber,
  AppColors.chipGreen,
  AppColors.chipOrange,
  AppColors.chipAmber,
];

const _statusData = [
  {
    'type': 'vaccine',
    'label': AppStrings.vaccines,
    'value': 'Up to date',
    'checkup': 'Oct 12',
  },
  {
    'type': 'medication',
    'label': AppStrings.medication,
    'value': 'Due at 4 PM',
    'activity': 'Napped 1hr',
  },
  {
    'type': 'vaccine',
    'label': AppStrings.vaccines,
    'value': 'Up to date',
    'checkup': 'Nov 5',
  },
  {
    'type': 'medication',
    'label': AppStrings.medication,
    'value': 'Due at 6 PM',
    'activity': 'Played outside',
  },
  {
    'type': 'vaccine',
    'label': AppStrings.vaccines,
    'value': 'Up to date',
    'checkup': 'Dec 1',
  },
];

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.index});
  final ChildEntity child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // index is the child's *global* list position (page-aware), so cycling
    // through these arrays spreads different chips across the visible cards.
    // age is derived from index purely for visual variety on the card;
    // the child's real age comes from child_entity.age on the profile screen.
    final bloodTypeValue = _bloodTypes[index % _bloodTypes.length];
    final bloodColor = _bloodTypeColors[index % _bloodTypeColors.length];
    final status = _statusData[index % _statusData.length];
    final age = (index + 3).clamp(3, 8);
    final isVaccine = status['type'] == 'vaccine';

    // The card's Semantics label previously stopped at name/age/blood
    // type and excluded everything else beneath it — including the two
    // status chips, which is the actually useful health info on the
    // card. Build one complete sentence covering all of it, so a
    // screen-reader user gets the same information a sighted user sees
    // at a glance, in a single swipe stop.
    final secondaryLabel = isVaccine
        ? '${status['label']}: ${status['value']}. '
        '${AppStrings.nextCheckup} ${status['checkup']}'
        : '${status['label']}: ${status['value']}. '
        '${AppStrings.activity}: ${status['activity']}';
    final cardLabel = AppStrings.childCardLabel(
      name: child.name,
      age: age,
      bloodType: bloodTypeValue,
      secondaryLabel: secondaryLabel,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Semantics(
        label: cardLabel,
        hint: AppStrings.childCardHint(child.name),
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.toNamed(AppRoutes.childDetails, arguments: child.id),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    InitialsAvatar(name: child.name, radius: 28, fontSize: 20),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          PillBadge(
                            text: '$age ${AppStrings.years}',
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                            textColor: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(height: 4),
                          PillBadge(
                            text: '$bloodTypeValue ${AppStrings.bloodType}',
                            backgroundColor: bloodColor,
                            textColor: AppColors.primaryLight,
                            fontSize: 11,
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
                const SizedBox(height: AppDimensions.spacingMd),
                // Status chips
                Row(
                  children: [
                    if (isVaccine) ...[
                      Expanded(
                        child: IconValueChip(
                          icon: Icons.check_circle,
                          iconColor: AppColors.successLight,
                          label: status['label']!,
                          value: status['value']!,
                          backgroundColor: AppColors.chipGreen,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: IconValueChip(
                          icon: Icons.calendar_today,
                          iconColor: AppColors.primaryLight,
                          label: AppStrings.nextCheckup,
                          value: status['checkup']!,
                          backgroundColor: AppColors.chipTeal,
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: IconValueChip(
                          icon: Icons.warning_amber_rounded,
                          iconColor: AppColors.warningLight,
                          label: status['label']!,
                          value: status['value']!,
                          backgroundColor: AppColors.chipAmber,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: IconValueChip(
                          icon: Icons.schedule,
                          iconColor: AppColors.primaryLight,
                          label: AppStrings.activity,
                          value: status['activity']!,
                          backgroundColor: AppColors.chipTeal,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.controller});
  final ChildrenController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final page = controller.currentPage.value;
      final totalPages = controller.totalPages;
      final totalItems = controller.filteredChildren.length;
      final pageSize = ChildrenController.pageSize;
      final start = (page - 1) * pageSize + 1;
      final end = (page * pageSize).clamp(0, totalItems);
      final hasPrev = page > 1;
      final hasNext = page < totalPages;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLg),
        child: Column(
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                AppStrings.paginationStatus(start, end, totalItems),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(0),
                    child: Semantics(
                      enabled: hasPrev,
                      label: AppStrings.previousPage,
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: hasPrev
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant.withAlpha(
                            100,
                          ),
                        ),
                        onPressed: hasPrev ? controller.previousPage : null,
                      ),
                    ),
                  ),
                  for (int i = 1; i <= totalPages; i++)
                    FocusTraversalOrder(
                      order: NumericFocusOrder(i.toDouble()),
                      child: Semantics(
                        button: true,
                        selected: i == page,
                        label: AppStrings.pageLabel(i, isCurrent: i == page),
                        excludeSemantics: true,
                        onTap: i == page ? null : () => controller.goToPage(i),
                        child: GestureDetector(
                          onTap: i == page
                              ? null
                              : () => controller.goToPage(i),
                          child: SizedBox(
                            // Keeps the visual circle compact while still
                            // meeting the 48x48 minimum touch target.
                            width: AppDimensions.minTouchTarget,
                            height: AppDimensions.minTouchTarget,
                            child: Center(
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: i == page
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$i',
                                    style: TextStyle(
                                      color: i == page
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  FocusTraversalOrder(
                    order: NumericFocusOrder((totalPages + 1).toDouble()),
                    child: Semantics(
                      enabled: hasNext,
                      label: AppStrings.nextPage,
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: hasNext
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant.withAlpha(
                            100,
                          ),
                        ),
                        onPressed: hasNext ? controller.nextPage : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}