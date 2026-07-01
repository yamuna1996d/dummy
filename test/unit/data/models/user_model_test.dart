import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/data/models/user_model.dart';
import 'package:kincare/domain/entities/user_entity.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parses a fully populated JSON map', () {
      final json = {
        'id': '1',
        'name': 'Jane Doe',
        'email': 'jane@kincare.com',
        'phone': '555-1234',
        'avatarUrl': 'https://example.com/a.png',
        'username': 'jane',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, '1');
      expect(model.name, 'Jane Doe');
      expect(model.email, 'jane@kincare.com');
      expect(model.phone, '555-1234');
      expect(model.avatarUrl, 'https://example.com/a.png');
      expect(model.username, 'jane');
    });

    test('falls back to empty id/name/email and null optional fields', () {
      final model = UserModel.fromJson(const {});

      expect(model.id, '');
      expect(model.name, '');
      expect(model.email, '');
      expect(model.phone, isNull);
      expect(model.avatarUrl, isNull);
      expect(model.username, isNull);
    });

    test('coerces a numeric id to a String', () {
      final model = UserModel.fromJson(const {'id': 7});
      expect(model.id, '7');
    });
  });

  group('UserModel.toJson', () {
    test('round-trips through toJson/fromJson without losing data', () {
      final original = UserModel.fromJson({
        'id': '2',
        'name': 'John Smith',
        'email': 'john@kincare.com',
        'phone': '555-9999',
      });

      final roundTripped = UserModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.name, original.name);
      expect(roundTripped.email, original.email);
      expect(roundTripped.phone, original.phone);
    });
  });

  group('UserModel.fromEntity', () {
    test('copies every field from a UserEntity', () {
      const entity = UserEntity(
        id: '3',
        name: 'Alex',
        email: 'alex@kincare.com',
        phone: '555-0000',
        avatarUrl: 'https://example.com/alex.png',
        username: 'alex',
      );

      final model = UserModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.email, entity.email);
      expect(model.phone, entity.phone);
      expect(model.avatarUrl, entity.avatarUrl);
      expect(model.username, entity.username);
    });
  });
}
