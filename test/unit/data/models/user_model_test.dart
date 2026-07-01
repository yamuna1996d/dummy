import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/data/models/user_model.dart';
import 'package:kincare/domain/entities/user_entity.dart';

void main() {
  group('UserModel', () {
    const testJson = {
      'id': '1',
      'name': 'Leanne Graham',
      'email': 'leanne@example.com',
      'phone': '1-770-736-8031',
      'username': 'Bret',
    };

    test('should create from JSON correctly', () {
      final model = UserModel.fromJson(testJson);

      expect(model.id, '1');
      expect(model.name, 'Leanne Graham');
      expect(model.email, 'leanne@example.com');
      expect(model.phone, '1-770-736-8031');
      expect(model.username, 'Bret');
    });

    test('should serialize to JSON correctly', () {
      const model = UserModel(
        id: '1',
        name: 'Test',
        email: 'test@test.com',
        phone: '123',
      );

      final json = model.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test');
      expect(json['email'], 'test@test.com');
      expect(json['phone'], '123');
    });

    test('should create from entity', () {
      const entity = UserEntity(
        id: '2',
        name: 'Entity User',
        email: 'entity@test.com',
      );

      final model = UserModel.fromEntity(entity);

      expect(model.id, '2');
      expect(model.name, 'Entity User');
      expect(model.email, 'entity@test.com');
    });

    test('should handle missing optional fields', () {
      final model = UserModel.fromJson(const {
        'id': '1',
        'name': 'Minimal',
        'email': 'min@test.com',
      });

      expect(model.phone, isNull);
      expect(model.avatarUrl, isNull);
      expect(model.username, isNull);
    });
  });
}
