import 'package:kincare/domain/entities/medication_entity.dart';

/// Data model for medication records with JSON serialization.
class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required super.id,
    required super.name,
    super.dosage,
    super.frequency,
    super.isActive,
    super.childId,
    super.notes,
    super.startDate,
    super.endDate,
  });

  /// Maps a GraphQL medication response to a medication model.
  factory MedicationModel.fromGraphQL(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      childId: json['childId'] as String?,
      notes: json['notes'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      childId: json['childId'] as String?,
      notes: json['notes'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'isActive': isActive,
      'childId': childId,
      'notes': notes,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory MedicationModel.fromEntity(MedicationEntity entity) {
    return MedicationModel(
      id: entity.id,
      name: entity.name,
      dosage: entity.dosage,
      frequency: entity.frequency,
      isActive: entity.isActive,
      childId: entity.childId,
      notes: entity.notes,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }
}
