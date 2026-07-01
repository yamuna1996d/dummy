import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/user_model.dart';
import 'package:kincare/data/repositories/profile_repository_impl.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockProfileRemoteDatasource remoteDatasource;
  late MockNetworkInfo networkInfo;
  late ProfileRepositoryImpl repository;

  const user = UserEntity(id: '1', name: 'Jane', email: 'jane@kincare.com');

  setUp(() {
    remoteDatasource = MockProfileRemoteDatasource();
    networkInfo = MockNetworkInfo();
    repository = ProfileRepositoryImpl(
      remoteDatasource: remoteDatasource,
      networkInfo: networkInfo,
    );
  });

  group('getProfile', () {
    test(
      'returns NetworkException without hitting the datasource when offline',
      () async {
        when(networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.getProfile();

        expect(result.isFailure, isTrue);
        verifyNever(remoteDatasource.getProfile());
      },
    );

    test('delegates to the datasource when online', () async {
      when(networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        remoteDatasource.getProfile(),
      ).thenAnswer((_) async => Result.success(UserModel.fromEntity(user)));

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      verify(remoteDatasource.getProfile()).called(1);
    });
  });
}
