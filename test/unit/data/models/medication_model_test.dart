import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/data/models/medication_model.dart';
import 'package:kincare/domain/entities/medication_entity.dart';

void main() {
  group('MedicationModel', () {
    test('should create from GraphQL response', () {
      final model = MedicationModel.fromGraphQL(const {
        'id': '1',
        'name': 'Vitamin D',
        'dosage': '400 IU',
        'frequency': 'Once daily',
        'isActive': true,
        'childId': '3',
        'notes': 'Give with breakfast',
      });

      expect(model.id, '1');
      expect(model.name, 'Vitamin D');
      expect(model.dosage, '400 IU');
      expect(model.frequency, 'Once daily');
      expect(model.isActive, isTrue);
      expect(model.childId, '3');
      expect(model.notes, 'Give with breakfast');
    });

    test('should create from JSON', () {
      final model = MedicationModel.fromJson(const {
        'id': '2',
        'name': 'Iron',
        'dosage': '65mg',
        'frequency': 'Daily',
        'isActive': true,
      });

      expect(model.id, '2');
      expect(model.name, 'Iron');
      expect(model.dosage, '65mg');
      expect(model.frequency, 'Daily');
      expect(model.isActive, isTrue);
    });

    test('should serialize to JSON and back', () {
      const model = MedicationModel(
        id: '3',
        name: 'Calcium',
        dosage: '500mg',
        frequency: 'Twice daily',
        isActive: false,
      );

      final json = model.toJson();
      final restored = MedicationModel.fromJson(json);

      expect(restored.id, '3');
      expect(restored.name, 'Calcium');
      expect(restored.dosage, '500mg');
      expect(restored.frequency, 'Twice daily');
      expect(restored.isActive, isFalse);
    });

    test('should create from entity', () {
      const entity = MedicationEntity(id: '4', name: 'Aspirin');
      final model = MedicationModel.fromEntity(entity);

      expect(model.id, '4');
      expect(model.name, 'Aspirin');
    });

    test('should handle dates in JSON', () {
      final now = DateTime(2026, 6, 29);
      final model = MedicationModel.fromJson({
        'id': '5',
        'name': 'Antibiotic',
        'startDate': now.toIso8601String(),
      });

      expect(model.startDate, now);
    });
  });
}
