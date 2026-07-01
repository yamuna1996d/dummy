import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/data/models/child_model.dart';
import 'package:kincare/domain/entities/child_entity.dart';

void main() {
  group('ChildModel', () {
    test('should create from GraphQL response', () {
      final model = ChildModel.fromGraphQL(const {
        'id': '1',
        'name': 'Child Name',
        'age': 6,
        'gender': 'Female',
        'guardianName': 'Guardian Name',
        'description': 'Some notes',
      });

      expect(model.id, '1');
      expect(model.name, 'Child Name');
      expect(model.age, 6);
      expect(model.gender, 'Female');
      expect(model.guardianName, 'Guardian Name');
      expect(model.description, 'Some notes');
    });

    test('should create from GraphQL response with only required fields', () {
      final model = ChildModel.fromGraphQL(const {
        'id': '2',
        'name': 'Child Name',
      });

      expect(model.id, '2');
      expect(model.name, 'Child Name');
      expect(model.age, isNull);
      expect(model.description, isNull);
    });

    test('should create from JSON', () {
      final model = ChildModel.fromJson(const {
        'id': '2',
        'name': 'Sarah',
        'age': 5,
        'gender': 'Female',
      });

      expect(model.id, '2');
      expect(model.name, 'Sarah');
      expect(model.age, 5);
      expect(model.gender, 'Female');
    });

    test('should serialize to JSON and back', () {
      const model = ChildModel(
        id: '3',
        name: 'Alex',
        age: 8,
        description: 'Notes here',
      );

      final json = model.toJson();
      final restored = ChildModel.fromJson(json);

      expect(restored.id, '3');
      expect(restored.name, 'Alex');
      expect(restored.age, 8);
      expect(restored.description, 'Notes here');
    });

    test('should create from entity', () {
      const entity = ChildEntity(id: '4', name: 'Entity Child');
      final model = ChildModel.fromEntity(entity);

      expect(model.id, '4');
      expect(model.name, 'Entity Child');
    });
  });
}
