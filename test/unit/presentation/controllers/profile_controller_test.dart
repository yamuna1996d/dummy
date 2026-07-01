import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/presentation/controllers/profile_controller.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockGetProfileUseCase getProfileUseCase;
  late ProfileController controller;

  const user = UserEntity(
    id: '1',
    name: 'Jane Doe',
    email: 'jane@kincare.com',
    phone: '555-1234',
  );

  setUp(() {
    getProfileUseCase = MockGetProfileUseCase();
    controller = ProfileController(getProfileUseCase: getProfileUseCase);
  });

  group('loadProfile', () {
    test('populates profile on success', () async {
      when(
        getProfileUseCase(),
      ).thenAnswer((_) async => const Result.success(user));

      await controller.loadProfile();

      expect(controller.profile.value, user);
      expect(controller.isLoading.value, isFalse);
    });

    test('maps NetworkException to its own message', () async {
      when(getProfileUseCase()).thenAnswer(
        (_) async => const Result.failure(NetworkException('offline')),
      );

      await controller.loadProfile();

      expect(controller.errorMessage.value, 'offline');
    });
  });
}
