import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_dimensions.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/app/theme/app_colors.dart';
import 'package:kincare/core/accessibility/responsive_helper.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/presentation/controllers/children_controller.dart';
import 'package:kincare/presentation/controllers/medication_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/error_view.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/pill_badge.dart';
import '../../widgets/section_label.dart';

const _monthAbbreviations = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

/// CHILD PROFILE SCREEN
///
/// Flow: full profile for one child — health metrics, an allergy banner,
/// that child's active medications, an upcoming appointment card, and
/// growth tracking. Each section only renders if the underlying data
/// exists, so a child with no allergy/appointment simply shows fewer
/// cards rather than empty placeholders. "View History" opens the
/// medication list filtered to this child (active + inactive together).
/// The floating "+" button opens Add Medication pre-scoped to this child.
///
/// Always navigated to with the child's id (a `String`) as `Get.arguments`
/// — the screen fetches the full record itself via [ChildrenController]
/// rather than receiving the whole object, so a loading spinner shows
/// briefly while that fetch is in flight.
///
/// Reached from: Children list (chevron tap) or Dashboard child preview
/// cards.
/// Leads to: Medication list (filtered to this child), Add Medication
/// (pre-selected child).
class ChildDetailsScreen extends StatelessWidget {
  const ChildDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final childId = Get.arguments as String?;
    final childrenController = Get.find<ChildrenController>();
    final medicationController = Get.find<MedicationController>();

    if (childId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.childDetails)),
        body: const Center(child: Text(AppStrings.childNotFound)),
      );
    }

    // Only fetch if the cached selectedChild isn't already this child — avoids
    // a redundant network call when the user navigates back to the same profile
    // (e.g. Dashboard → Child A → back → Child A again).
    if (childrenController.selectedChild.value?.id != childId) {
      childrenController.loadChildDetails(childId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          headingLevel: 1,
          child: const Text(AppStrings.childProfile),
        ),
      ),

      body: Obx(() {
        final child = childrenController.selectedChild.value;
        // Show error or spinner until selectedChild is populated for this id.
        // Using childId for the guard means navigating to a different child
        // while one is still in flight won't accidentally show stale data.
        if (child == null || child.id != childId) {
          if (childrenController.errorMessage.value != null) {
            return ErrorView(
              message: childrenController.errorMessage.value!,
              onRetry: () => childrenController.loadChildDetails(childId),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
        return _ChildProfileBody(
          child: child,
          medicationController: medicationController,
        );
      }),
    );
  }
}

class _ChildProfileBody extends StatelessWidget {
  const _ChildProfileBody({
    required this.child,
    required this.medicationController,
  });

  final ChildEntity child;
  final MedicationController medicationController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveHelper.horizontalPadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: AppDimensions.paddingLg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(child: child),
              const SizedBox(height: AppDimensions.spacingLg),
              if (child.bloodGroup != null || child.weightKg != null) ...[
                SectionLabel(AppStrings.healthMetrics),
                const SizedBox(height: AppDimensions.spacingSm),
                _HealthMetricsRow(child: child),
                const SizedBox(height: AppDimensions.spacingLg),
              ],
              if (child.allergyName != null) ...[
                _AllergyBanner(child: child),
                const SizedBox(height: AppDimensions.spacingLg),
              ],
              SectionLabel(
                AppStrings.activeMedications,
                trailing: Semantics(
                  button: true,
                  label: AppStrings.viewHistory,
                  excludeSemantics: true,
                  onTap: () => Get.toNamed(
                    AppRoutes.medications,
                    arguments: {'childId': child.id, 'childName': child.name},
                  ),
                  child: TextButton.icon(
                    onPressed: () => Get.toNamed(
                      AppRoutes.medications,
                      arguments: {'childId': child.id, 'childName': child.name},
                    ),
                    label: Text(
                      AppStrings.viewHistory,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Obx(() {
                if (medicationController.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingLg,
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                // Filter the full medications list in-memory for this child's
                // active entries. MedicationController.medications holds all
                // records already fetched for the medication list screen, so
                // no extra network call is needed here.
                final activeMedications = medicationController.medications
                    .where((m) => m.childId == child.id && m.isActive)
                    .toList();
                if (activeMedications.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMd,
                    ),
                    child: Text(
                      AppStrings.noActiveMedications,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return Column(
                  children: activeMedications
                      .map((m) => _MedicationCard(medication: m))
                      .toList(),
                );
              }),
              const SizedBox(height: AppDimensions.spacingLg),
              if (child.nextAppointmentTitle != null) ...[
                SectionLabel(AppStrings.upcomingAppointment),
                const SizedBox(height: AppDimensions.spacingSm),
                _AppointmentCard(child: child),
                const SizedBox(height: AppDimensions.spacingLg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.child});
  final ChildEntity child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: AppStrings.childHeaderLabel(child.name, child.age, child.gender),
      excludeSemantics: true,
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                InitialsAvatar(
                  name: child.name,
                  radius: AppDimensions.avatarXl / 2,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  fontSize: theme.textTheme.headlineLarge?.fontSize,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            child.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (child.age != null || child.gender != null) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            PillBadge(
              text: [
                if (child.age != null) '${child.age} ${AppStrings.years}',
                if (child.gender != null) child.gender!,
              ].join(' • '),
              backgroundColor: AppColors.chipTeal,
              textColor: AppColors.primaryLight,
              fontSize: 13,
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthMetricsRow extends StatelessWidget {
  const _HealthMetricsRow({required this.child});
  final ChildEntity child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (child.bloodGroup != null)
          Expanded(
            child: _MetricCard(
              name: child.name,
              icon: Icons.water_drop_outlined,
              label: AppStrings.bloodGroup,
              value: child.bloodGroup!,
            ),
          ),
        if (child.bloodGroup != null && child.weightKg != null)
          const SizedBox(width: AppDimensions.spacingMd),
        if (child.weightKg != null)
          Expanded(
            child: _MetricCard(
              name: child.name,
              icon: Icons.monitor_weight_outlined,
              label: AppStrings.weight,
              value:
              '${child.weightKg!.toStringAsFixed(child.weightKg! % 1 == 0 ? 0 : 1)} ${AppStrings.kg}',
            ),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.name,
  });

  final IconData icon;
  final String label;
  final String value;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: AppStrings.metricLabel(name, label, value),
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: AppDimensions.iconSm,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllergyBanner extends StatelessWidget {
  const _AllergyBanner({required this.child});
  final ChildEntity child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.allergyLabel(
        child.name,
        child.allergyName!,
        child.allergyNote,
      ),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.errorContainerLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.errorLight,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.allergies,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorLight,
                    ),
                  ),
                  Text(
                    child.allergyName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.errorLight,
                    ),
                  ),
                  if (child.allergyNote != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      child.allergyNote!,
                      style: TextStyle(
                        color: AppColors.errorLight.withAlpha(220),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.medication});
  final MedicationEntity medication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: AppStrings.activeMedicationLabel(
        medication.name,
        medication.dosage,
        medication.frequency,
      ),
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.chipTeal,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Icon(
                  Icons.medication_outlined,
                  color: AppColors.primaryLight,
                ),
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
                    if (medication.dosage != null ||
                        medication.frequency != null)
                      Text(
                        [
                          medication.dosage,
                          medication.frequency,
                        ].where((s) => s != null).join(' • '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.child});
  final ChildEntity child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = child.nextAppointmentDate;
    final title = child.nextAppointmentTitle;
    final time = child.nextAppointmentTime;
    final location = child.nextAppointmentLocation;
    final phone = child.nextAppointmentClinicPhone;

    Future<void> launchPhone(String phoneNumber) async {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      try {
        await launchUrl(uri);
      } catch (_) {
        Get.snackbar(AppStrings.error, AppStrings.couldNotOpenPhone);
      }
    }

    Future<void> launchDirections(String address) async {
      final uri = Uri.parse(
        '${AppStrings.getDirectionUrl}${Uri.encodeComponent(address)}',
      );
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        Get.snackbar(AppStrings.error, AppStrings.couldNotOpenMaps);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: AppStrings.appointmentLabel(
                title: title!,
                date: date,
                time: time,
                location: location,
              ),
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (date != null)
                    Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _monthAbbreviations[date.month - 1],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${date.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (time != null)
                          _IconText(icon: Icons.access_time, text: time),
                        if (location != null)
                          _IconText(
                            icon: Icons.location_on_outlined,
                            text: location,
                          ),
                      ],
                    ),
                  ),
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
                          label: AppStrings.getDirectionsLabel,
                          hint: AppStrings.directionsHint(location),
                          excludeSemantics: true,
                          onTap: () => location != null
                              ? launchDirections(location)
                              : Get.snackbar(AppStrings.getDirections, AppStrings.locationNotAvailable),
                          child: FilledButton(
                            onPressed: () => location != null
                                ? launchDirections(location)
                                : Get.snackbar(AppStrings.getDirections, AppStrings.locationNotAvailable),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text(AppStrings.getDirections),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: FocusTraversalOrder(
                        order: const NumericFocusOrder(1),
                        child: Semantics(
                          button: true,
                          label: AppStrings.callClinicLabel,
                          hint: AppStrings.callClinicHint(phone),
                          excludeSemantics: true,
                          onTap: () => phone != null
                              ? launchPhone(phone)
                              : Get.snackbar(AppStrings.callClinic, AppStrings.phoneNotAvailable),
                          child: OutlinedButton.icon(
                            onPressed: () => phone != null
                                ? launchPhone(phone)
                                : Get.snackbar(AppStrings.callClinic, AppStrings.phoneNotAvailable),
                            icon: const Icon(Icons.call_outlined, size: 18),
                            label: const Text(AppStrings.callClinic),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
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

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}