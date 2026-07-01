import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/data/models/child_model.dart';
import 'package:kincare/domain/entities/child_entity.dart';

void main() {
  group('ChildModel.fromJson', () {
    test('parses a fully populated JSON map', () {
      final json = {
        'id': '1',
        'name': 'Riya Menon',
        'age': 6,
        'description': 'Loves painting',
        'guardianId': 'g1',
        'guardianName': 'Asha Menon',
        'dateOfBirth': '2019-04-12T00:00:00.000Z',
        'gender': 'female',
        'notes': 'No notes',
        'bloodGroup': 'O+',
        'weightKg': 21.5,
        'allergyName': 'Peanuts',
        'allergyNote': 'Carries an EpiPen',
        'heightPercentile': 75,
        'nextAppointmentTitle': 'Dental checkup',
        'nextAppointmentDate': '2026-08-01T00:00:00.000Z',
        'nextAppointmentTime': '10:00 AM',
        'nextAppointmentLocation': 'City Clinic',
        'nextAppointmentClinicPhone': '555-1234',
      };

      final model = ChildModel.fromJson(json);

      expect(model.id, '1');
      expect(model.name, 'Riya Menon');
      expect(model.age, 6);
      expect(model.guardianName, 'Asha Menon');
      expect(model.dateOfBirth, DateTime.parse('2019-04-12T00:00:00.000Z'));
      expect(model.bloodGroup, 'O+');
      expect(model.weightKg, 21.5);
      expect(model.allergyName, 'Peanuts');
      expect(model.heightPercentile, 75);
      expect(model.nextAppointmentTitle, 'Dental checkup');
      expect(
        model.nextAppointmentDate,
        DateTime.parse('2026-08-01T00:00:00.000Z'),
      );
      expect(model.nextAppointmentClinicPhone, '555-1234');
    });

    test('falls back to empty strings and nulls for missing fields', () {
      final model = ChildModel.fromJson(const {});

      expect(model.id, '');
      expect(model.name, '');
      expect(model.age, isNull);
      expect(model.dateOfBirth, isNull);
      expect(model.weightKg, isNull);
      expect(model.nextAppointmentDate, isNull);
    });

    test('coerces a numeric id to a String', () {
      final model = ChildModel.fromJson(const {'id': 42, 'name': 'X'});
      expect(model.id, '42');
    });

    test('an unparsable date string is dropped instead of throwing', () {
      final model = ChildModel.fromJson(const {
        'id': '1',
        'name': 'X',
        'dateOfBirth': 'not-a-date',
      });

      expect(model.dateOfBirth, isNull);
    });

    test('weightKg accepts an int and converts it to a double', () {
      final model = ChildModel.fromJson(const {
        'id': '1',
        'name': 'X',
        'weightKg': 20,
      });

      expect(model.weightKg, 20.0);
    });
  });

  group('ChildModel.toJson', () {
    test('round-trips through toJson/fromJson without losing data', () {
      final original = ChildModel.fromJson({
        'id': '2',
        'name': 'Aarav Menon',
        'age': 3,
        'dateOfBirth': '2022-01-01T00:00:00.000Z',
        'weightKg': 14.2,
      });

      final roundTripped = ChildModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.name, original.name);
      expect(roundTripped.age, original.age);
      expect(roundTripped.dateOfBirth, original.dateOfBirth);
      expect(roundTripped.weightKg, original.weightKg);
    });

    test('serializes DateTime fields to ISO 8601 strings', () {
      final model = ChildModel.fromJson({
        'id': '1',
        'name': 'X',
        'dateOfBirth': '2020-05-15T00:00:00.000Z',
      });

      final json = model.toJson();
      expect(json['dateOfBirth'], '2020-05-15T00:00:00.000Z');
    });
  });

  group('ChildModel.fromEntity', () {
    test('copies every field from a ChildEntity', () {
      const entity = ChildEntity(
        id: '5',
        name: 'Test Child',
        age: 8,
        guardianName: 'Guardian',
        bloodGroup: 'A+',
        weightKg: 25.0,
      );

      final model = ChildModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.age, entity.age);
      expect(model.guardianName, entity.guardianName);
      expect(model.bloodGroup, entity.bloodGroup);
      expect(model.weightKg, entity.weightKg);
    });
  });

  group('ChildModel.fromGraphQL', () {
    test('parses a GraphQL-shaped response the same way as fromJson', () {
      final model = ChildModel.fromGraphQL(const {
        'id': 9,
        'name': 'GraphQL Child',
        'age': 4,
        'gender': 'male',
      });

      expect(model.id, '9');
      expect(model.name, 'GraphQL Child');
      expect(model.age, 4);
      expect(model.gender, 'male');
    });
  });
}
