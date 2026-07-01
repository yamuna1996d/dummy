import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/repositories/dashboard_repository_impl.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockDashboardRemoteDatasource remoteDatasource;
  late MockNetworkInfo networkInfo;
  late DashboardRepositoryImpl repository;

  setUp(() {
    remoteDatasource = MockDashboardRemoteDatasource();
    networkInfo = MockNetworkInfo();
    repository = DashboardRepositoryImpl(
      remoteDatasource: remoteDatasource,
      networkInfo: networkInfo,
    );
  });

  test(
    'returns NetworkException without hitting the datasource when offline',
    () async {
      when(networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getDashboard();

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('expected a failure'),
        failure: (e) => expect(e, isA<NetworkException>()),
      );
      verifyNever(remoteDatasource.getDashboard());
    },
  );

  test('delegates to the datasource when online', () async {
    when(networkInfo.isConnected).thenAnswer((_) async => true);
    when(
      remoteDatasource.getDashboard(),
    ).thenAnswer((_) async => const Result.failure(TimeoutException()));

    final result = await repository.getDashboard();

    expect(result.isFailure, isTrue);
    result.when(
      success: (_) => fail('expected a failure'),
      failure: (e) => expect(e, isA<TimeoutException>()),
    );
    verify(remoteDatasource.getDashboard()).called(1);
  });
}
