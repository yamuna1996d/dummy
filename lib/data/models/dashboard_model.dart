import 'package:kincare/domain/entities/dashboard_entity.dart';

/// Data model for dashboard data with JSON serialization.
class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.totalChildren,
    required super.totalMedications,
    required super.upcomingAppointments,
    required super.recentActivities,
    super.nextAppointmentChildId,
    super.nextAppointmentChildName,
    super.nextAppointmentTitle,
    super.nextAppointmentDate,
    super.nextAppointmentTime,
    super.nextAppointmentLocation,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final activities =
        (json['recentActivities'] as List<dynamic>?)
            ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return DashboardModel(
      totalChildren: json['totalChildren'] as int? ?? 0,
      totalMedications: json['totalMedications'] as int? ?? 0,
      upcomingAppointments: json['upcomingAppointments'] as int? ?? 0,
      recentActivities: activities,
      nextAppointmentChildId: json['nextAppointmentChildId'] as String?,
      nextAppointmentChildName: json['nextAppointmentChildName'] as String?,
      nextAppointmentTitle: json['nextAppointmentTitle'] as String?,
      nextAppointmentDate: json['nextAppointmentDate'] != null
          ? DateTime.tryParse(json['nextAppointmentDate'] as String)
          : null,
      nextAppointmentTime: json['nextAppointmentTime'] as String?,
      nextAppointmentLocation: json['nextAppointmentLocation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalChildren': totalChildren,
      'totalMedications': totalMedications,
      'upcomingAppointments': upcomingAppointments,
      'recentActivities': recentActivities
          .map((e) => ActivityModel.fromEntity(e).toJson())
          .toList(),
      'nextAppointmentChildId': nextAppointmentChildId,
      'nextAppointmentChildName': nextAppointmentChildName,
      'nextAppointmentTitle': nextAppointmentTitle,
      'nextAppointmentDate': nextAppointmentDate?.toIso8601String(),
      'nextAppointmentTime': nextAppointmentTime,
      'nextAppointmentLocation': nextAppointmentLocation,
    };
  }
}

/// Data model for activity items with JSON serialization.
class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.title,
    required super.description,
    required super.timestamp,
    super.icon,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'icon': icon,
    };
  }

  factory ActivityModel.fromEntity(ActivityEntity entity) {
    return ActivityModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
      icon: entity.icon,
    );
  }
}
