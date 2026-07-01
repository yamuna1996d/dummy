import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/repositories/auth_repository.dart';
import 'package:kincare/domain/usecases/login_usecase.dart';

@GenerateNiceMocks([MockSpec<AuthRepository>()])
import 'login_usecase_test.mocks.dart';

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  const testUser = UserEntity(
    id: '1',
    name: 'Test User',
    email: 'test@kincare.com',
  );

  setUpAll(() {
    provideDummy<Result<UserEntity>>(const Result.success(testUser));
    provideDummy<Result<void>>(const Result.success(null));
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  test('should return user on successful login', () async {
    when(mockRepository.login('test@kincare.com', 'password'))
        .thenAnswer((_) async => const Result.success(testUser));

    final result = await useCase('test@kincare.com', 'password');

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.email, 'test@kincare.com');
    verify(mockRepository.login('test@kincare.com', 'password')).called(1);
  });

  test('should return failure on invalid credentials', () async {
    when(mockRepository.login('wrong@email.com', 'wrong'))
        .thenAnswer((_) async => const Result.failure(AuthException()));

    final result = await useCase('wrong@email.com', 'wrong');

    expect(result.isFailure, isTrue);
  });

  test('should return network failure when offline', () async {
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase('test@kincare.com', 'password');

    expect(result.isFailure, isTrue);
    result.when(
      success: (_) => fail('Should be failure'),
      failure: (e) => expect(e, isA<NetworkException>()),
    );
  });
}
