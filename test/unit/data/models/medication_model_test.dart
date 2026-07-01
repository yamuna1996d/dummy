import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/data/models/medication_model.dart';
import 'package:kincare/domain/entities/medication_entity.dart';

void main() {
  group('MedicationModel.fromJson', () {
    test('parses a fully populated JSON map', () {
      final json = {
        'id': '1',
        'name': 'Amoxicillin',
        'dosage': '250mg',
        'frequency': 'Twice daily',
        'isActive': true,
        'childId': 'c1',
        'notes': 'Take with food',
        'startDate': '2026-01-01T00:00:00.000Z',
        'endDate': '2026-01-10T00:00:00.000Z',
      };

      final model = MedicationModel.fromJson(json);

      expect(model.id, '1');
      expect(model.name, 'Amoxicillin');
      expect(model.dosage, '250mg');
      expect(model.frequency, 'Twice daily');
      expect(model.isActive, isTrue);
      expect(model.childId, 'c1');
      expect(model.startDate, DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(model.endDate, DateTime.parse('2026-01-10T00:00:00.000Z'));
    });

    test('defaults isActive to true when absent', () {
      final model = MedicationModel.fromJson(const {'id': '1', 'name': 'X'});
      expect(model.isActive, isTrue);
    });

    test('respects an explicit isActive: false', () {
      final model = MedicationModel.fromJson(const {
        'id': '1',
        'name': 'X',
        'isActive': false,
      });
      expect(model.isActive, isFalse);
    });

    test('falls back to empty id/name and null optional fields', () {
      final model = MedicationModel.fromJson(const {});
      expect(model.id, '');
      expect(model.name, '');
      expect(model.dosage, isNull);
      expect(model.startDate, isNull);
      expect(model.endDate, isNull);
    });

    test('an unparsable date is dropped instead of throwing', () {
      final model = MedicationModel.fromJson(const {
        'id': '1',
        'name': 'X',
        'startDate': 'not-a-date',
      });
      expect(model.startDate, isNull);
    });
  });

  group('MedicationModel.toJson', () {
    test('round-trips through toJson/fromJson without losing data', () {
      final original = MedicationModel.fromJson({
        'id': '2',
        'name': 'Ibuprofen',
        'dosage': '100mg',
        'isActive': false,
        'startDate': '2026-02-01T00:00:00.000Z',
      });

      final roundTripped = MedicationModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.name, original.name);
      expect(roundTripped.dosage, original.dosage);
      expect(roundTripped.isActive, original.isActive);
      expect(roundTripped.startDate, original.startDate);
    });
  });

  group('MedicationModel.fromEntity', () {
    test('copies every field from a MedicationEntity', () {
      const entity = MedicationEntity(
        id: '3',
        name: 'Paracetamol',
        dosage: '500mg',
        frequency: 'As needed',
        isActive: true,
        childId: 'c2',
        notes: 'For fever',
      );

      final model = MedicationModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.dosage, entity.dosage);
      expect(model.frequency, entity.frequency);
      expect(model.isActive, entity.isActive);
      expect(model.childId, entity.childId);
      expect(model.notes, entity.notes);
    });
  });
}
