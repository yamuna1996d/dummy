import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';
import 'package:kincare/presentation/controllers/dashboard_controller.dart';
import 'package:kincare/presentation/widgets/app_drawer.dart';
import 'package:kincare/presentation/widgets/kincare_app_bar.dart';

import '../../widgets/error_view.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/section_label.dart';

/// DASHBOARD SCREEN
///
/// Flow: home screen after login. Shows at-a-glance counts (children,
/// medication doses due, upcoming visits), two pinned child preview cards,
/// and a card for the single soonest upcoming appointment across all
/// children (computed for real from each child's appointment data, not
/// hardcoded). Tapping a child preview card opens that child's profile;
/// "View all" opens the full Children list; "Add child" opens the add
/// form; the appointment card's "Details" button opens that child's
/// profile and "Get Directions" shows a snackbar (no maps integration).
///
/// Reached from: successful login, or "Dashboard" in the navigation
/// drawer (available from Children/Medications/Profile/Help/About).
/// Leads to: Child Profile, Children list, Add Child — or elsewhere via
/// the drawer.
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KinCareAppBar(),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();
        if (controller.errorMessage.value != null) {
          return ErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.loadDashboard,
          );
        }
        return _DashboardBody(controller: controller);
      }),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.controller});
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);
    final dashboard = controller.dashboard.value;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: theme.colorScheme.primary,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        children: [
          const SizedBox(height: AppDimensions.spacingMd),
          Semantics(
            headingLevel: 1,
            child: Text(
              AppStrings.helloGreeting('John'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Section: TODAY AT A GLANCE
          // Fall back to demo values when the dashboard entity hasn't
          // loaded yet, so the screen never shows blank/zero counts
          // during the initial fetch.
          Builder(
            builder: (context) {
              final childCount = dashboard?.totalChildren.toString() ?? '2';
              final medCount = dashboard?.totalMedications.toString() ?? '3';
              final visitCount =
                  dashboard?.upcomingAppointments.toString() ?? '1';

              // The section heading and all three glance cards are read
              // as one combined stop — "Today at a glance: 2 children
              // under care, 3 medication doses due, 1 upcoming visit" —
              // instead of the heading and each card announcing
              // separately as four disconnected fragments.
              return Semantics(
                headingLevel: 2,
                label: AppStrings.glanceSummary(
                  childCount,
                  medCount,
                  visitCount,
                ),
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel(AppStrings.todayAtAGlance),
                    const SizedBox(height: AppDimensions.spacingMd),
                    _GlanceCards(
                      childCount: childCount,
                      medCount: medCount,
                      visitCount: visitCount,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // Section: YOUR CHILDREN
          SectionLabel(
            AppStrings.yourChildrenSection,
            trailing: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Row(
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: Semantics(
                      button: true,
                      label: AppStrings.viewAllChildren,
                      excludeSemantics: true,
                      onTap: () => Get.toNamed(AppRoutes.children),
                      child: TextButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.children),
                        label: const Text(AppStrings.viewAll),
                        icon: const Icon(Icons.arrow_forward_ios, size: 14),
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          // These two preview cards are pinned to the first two children in
          // the seed data (ids '1' and '2'). In a real backend integration,
          // this section would come from the dashboard API response and
          // iterate over the guardian's actual children.
          _ChildPreviewCard(
            name: 'Riya Menon',
            age: '6 ${AppStrings.yrs}',
            status: AppStrings.allClearToday,
            onTap: () => Get.toNamed(AppRoutes.childDetails, arguments: '1'),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _ChildPreviewCard(
            name: 'Aarav Menon',
            age: '3 ${AppStrings.yrs}',
            status: AppStrings.doseRemaining,
            onTap: () => Get.toNamed(AppRoutes.childDetails, arguments: '2'),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // Section: UPCOMING VISIT
          const SectionLabel(AppStrings.upcomingVisitSection),
          const SizedBox(height: AppDimensions.spacingMd),
          _UpcomingVisitCard(dashboard: dashboard),
          const SizedBox(height: AppDimensions.spacingXxl),
        ],
      ),
    );
  }
}

class _GlanceCards extends StatelessWidget {
  const _GlanceCards({
    required this.childCount,
    required this.medCount,
    required this.visitCount,
  });

  final String childCount;
  final String medCount;
  final String visitCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GlanceCard(
                icon: Icons.sentiment_satisfied_alt,
                value: childCount,
                label: AppStrings.childrenUnderCare,
                backgroundColor: Colors.white,
                iconColor: AppColors.primaryLight,
                textColor: AppColors.onSurfaceLight,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: _GlanceCard(
                icon: Icons.medication_outlined,
                value: medCount,
                label: AppStrings.medicationDosesDue,
                backgroundColor: AppColors.primaryLight,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 48) / 2,
            child: _GlanceCard(
              icon: Icons.calendar_today_outlined,
              value: visitCount,
              label: AppStrings.upcomingVisit,
              // White-on-amber fails WCAG contrast (~2.1:1); the dark
              // surface color reads clearly against this background.
              backgroundColor: AppColors.secondaryLight,
              iconColor: AppColors.onSurfaceLight,
              textColor: AppColors.onSurfaceLight,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlanceCard extends StatelessWidget {
  const _GlanceCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isWhiteBg = backgroundColor == Colors.white;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: isWhiteBg
              ? Border.all(color: AppColors.outlineVariantLight, width: 0.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: textColor.withAlpha(200)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildPreviewCard extends StatelessWidget {
  const _ChildPreviewCard({
    required this.name,
    required this.age,
    required this.status,
    required this.onTap,
  });

  final String name;
  final String age;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: AppStrings.selectedChildLabel(name, age, status),
      hint: AppStrings.opensProfileHint(name),
      excludeSemantics: true,
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
              vertical: AppDimensions.paddingXs,
            ),
            leading: InitialsAvatar(name: name, radius: 22, fontSize: 16),
            title: Text(
              name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '$age • $status',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingVisitCard extends StatelessWidget {
  const _UpcomingVisitCard({required this.dashboard});
  final DashboardEntity? dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = dashboard?.nextAppointmentTitle;
    final childName = dashboard?.nextAppointmentChildName;
    final date = dashboard?.nextAppointmentDate;
    final time = dashboard?.nextAppointmentTime;
    final location = dashboard?.nextAppointmentLocation;
    final childId = dashboard?.nextAppointmentChildId;

    // DashboardEntity.nextAppointment* fields are computed by the repository
    // from children.json — it finds the earliest nextAppointmentDate across
    // all seed children and surfaces it here. If no child has an appointment,
    // these fields are null and we show a "No upcoming visits" placeholder.
    if (title == null || childName == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Semantics(
            label: AppStrings.noUpcomingVisitsLabel,
            excludeSemantics: true,
            child: const Text(AppStrings.noUpcomingVisits),
          ),
        ),
      );
    }

    final dateLabel = [
      if (date != null) '${date.day}/${date.month}/${date.year}',
      ?time,
    ].join(' at ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: AppStrings.upcomingVisitLabel(
                childName: childName,
                title: title,
                dateLabel: dateLabel.isNotEmpty ? dateLabel : null,
                location: location,
              ),
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chipGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    "$childName's $title",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (location != null) ...[
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: FocusTraversalOrder(
                        order: const NumericFocusOrder(0),
                        child: Semantics(
                          button: true,
                          label: AppStrings.viewDetails,
                          hint: AppStrings.opensChildProfileHint,
                          enabled: childId != null,
                          excludeSemantics: true,
                          onTap: childId == null
                              ? null
                              : () => Get.toNamed(
                            AppRoutes.childDetails,
                            arguments: childId,
                          ),
                          child: OutlinedButton(
                            onPressed: childId == null
                                ? null
                                : () => Get.toNamed(
                              AppRoutes.childDetails,
                              arguments: childId,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: const Text(AppStrings.details),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: FocusTraversalOrder(
                        order: const NumericFocusOrder(1),
                        child: Semantics(
                          button: true,
                          label: AppStrings.directionsToLabel(location),
                          excludeSemantics: true,
                          onTap: () => Get.snackbar(
                            AppStrings.getDirections,
                            location ?? AppStrings.locationNotAvailable,
                          ),
                          child: ElevatedButton(
                            onPressed: () => Get.snackbar(
                              AppStrings.getDirections,
                              location ?? AppStrings.locationNotAvailable,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              elevation: 0,
                              side: BorderSide.none,
                            ),
                            child: const Text(AppStrings.getDirections),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}