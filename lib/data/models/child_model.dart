import 'package:kincare/domain/entities/child_entity.dart';

/// Data model for child records with JSON serialization.
class ChildModel extends ChildEntity {
  const ChildModel({
    required super.id,
    required super.name,
    super.age,
    super.description,
    super.guardianId,
    super.guardianName,
    super.dateOfBirth,
    super.gender,
    super.notes,
    super.bloodGroup,
    super.weightKg,
    super.allergyName,
    super.allergyNote,
    super.heightPercentile,
    super.nextAppointmentTitle,
    super.nextAppointmentDate,
    super.nextAppointmentTime,
    super.nextAppointmentLocation,
    super.nextAppointmentClinicPhone,
  });

  /// Maps a GraphQL child response to a child model.
  factory ChildModel.fromGraphQL(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      guardianName: json['guardianName'] as String?,
      description: json['description'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      allergyName: json['allergyName'] as String?,
      allergyNote: json['allergyNote'] as String?,
      heightPercentile: json['heightPercentile'] as int?,
      nextAppointmentTitle: json['nextAppointmentTitle'] as String?,
      nextAppointmentDate: json['nextAppointmentDate'] != null
          ? DateTime.tryParse(json['nextAppointmentDate'] as String)
          : null,
      nextAppointmentTime: json['nextAppointmentTime'] as String?,
      nextAppointmentLocation: json['nextAppointmentLocation'] as String?,
      nextAppointmentClinicPhone: json['nextAppointmentClinicPhone'] as String?,
    );
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int?,
      description: json['description'] as String?,
      guardianId: json['guardianId'] as String?,
      guardianName: json['guardianName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      notes: json['notes'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      allergyName: json['allergyName'] as String?,
      allergyNote: json['allergyNote'] as String?,
      heightPercentile: json['heightPercentile'] as int?,
      nextAppointmentTitle: json['nextAppointmentTitle'] as String?,
      nextAppointmentDate: json['nextAppointmentDate'] != null
          ? DateTime.tryParse(json['nextAppointmentDate'] as String)
          : null,
      nextAppointmentTime: json['nextAppointmentTime'] as String?,
      nextAppointmentLocation: json['nextAppointmentLocation'] as String?,
      nextAppointmentClinicPhone: json['nextAppointmentClinicPhone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'description': description,
      'guardianId': guardianId,
      'guardianName': guardianName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'notes': notes,
      'bloodGroup': bloodGroup,
      'weightKg': weightKg,
      'allergyName': allergyName,
      'allergyNote': allergyNote,
      'heightPercentile': heightPercentile,
      'nextAppointmentTitle': nextAppointmentTitle,
      'nextAppointmentDate': nextAppointmentDate?.toIso8601String(),
      'nextAppointmentTime': nextAppointmentTime,
      'nextAppointmentLocation': nextAppointmentLocation,
      'nextAppointmentClinicPhone': nextAppointmentClinicPhone,
    };
  }

  factory ChildModel.fromEntity(ChildEntity entity) {
    return ChildModel(
      id: entity.id,
      name: entity.name,
      age: entity.age,
      description: entity.description,
      guardianId: entity.guardianId,
      guardianName: entity.guardianName,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      notes: entity.notes,
      bloodGroup: entity.bloodGroup,
      weightKg: entity.weightKg,
      allergyName: entity.allergyName,
      allergyNote: entity.allergyNote,
      heightPercentile: entity.heightPercentile,
      nextAppointmentTitle: entity.nextAppointmentTitle,
      nextAppointmentDate: entity.nextAppointmentDate,
      nextAppointmentTime: entity.nextAppointmentTime,
      nextAppointmentLocation: entity.nextAppointmentLocation,
      nextAppointmentClinicPhone: entity.nextAppointmentClinicPhone,
    );
  }
}
