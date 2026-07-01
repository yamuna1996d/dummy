/// Domain entity representing a medication record.
class MedicationEntity {
  const MedicationEntity({
    required this.id,
    required this.name,
    this.dosage,
    this.frequency,
    this.isActive = true,
    this.childId,
    this.notes,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String name;
  final String? dosage;
  final String? frequency;
  final bool isActive;
  final String? childId;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
}
