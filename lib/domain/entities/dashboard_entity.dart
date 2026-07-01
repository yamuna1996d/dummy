/// Domain entity representing dashboard summary data.
class DashboardEntity {
  const DashboardEntity({
    required this.totalChildren,
    required this.totalMedications,
    required this.upcomingAppointments,
    required this.recentActivities,
    this.nextAppointmentChildId,
    this.nextAppointmentChildName,
    this.nextAppointmentTitle,
    this.nextAppointmentDate,
    this.nextAppointmentTime,
    this.nextAppointmentLocation,
  });

  final int totalChildren;
  final int totalMedications;
  final int upcomingAppointments;
  final List<ActivityEntity> recentActivities;

  // Soonest upcoming appointment across all children, if any.
  final String? nextAppointmentChildId;
  final String? nextAppointmentChildName;
  final String? nextAppointmentTitle;
  final DateTime? nextAppointmentDate;
  final String? nextAppointmentTime;
  final String? nextAppointmentLocation;
}

/// Domain entity representing a recent activity item.
class ActivityEntity {
  const ActivityEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.icon,
  });

  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? icon;
}
