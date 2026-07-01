/// Domain entity representing a child record.
class ChildEntity {
  const ChildEntity({
    required this.id,
    required this.name,
    this.age,
    this.description,
    this.guardianId,
    this.guardianName,
    this.dateOfBirth,
    this.gender,
    this.notes,
    this.bloodGroup,
    this.weightKg,
    this.allergyName,
    this.allergyNote,
    this.heightPercentile,
    this.nextAppointmentTitle,
    this.nextAppointmentDate,
    this.nextAppointmentTime,
    this.nextAppointmentLocation,
    this.nextAppointmentClinicPhone,
  });

  final String id;
  final String name;
  final int? age;
  final String? description;
  final String? guardianId;
  final String? guardianName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? notes;

  // Health metrics
  final String? bloodGroup;
  final double? weightKg;

  // Allergies
  final String? allergyName;
  final String? allergyNote;

  // Growth tracking
  final int? heightPercentile;

  // Upcoming appointment
  final String? nextAppointmentTitle;
  final DateTime? nextAppointmentDate;
  final String? nextAppointmentTime;
  final String? nextAppointmentLocation;
  final String? nextAppointmentClinicPhone;
}
