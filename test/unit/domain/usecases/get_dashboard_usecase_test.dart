import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';
import 'package:kincare/domain/usecases/get_dashboard_usecase.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockDashboardRepository repository;
  late GetDashboardUseCase useCase;

  setUp(() {
    repository = MockDashboardRepository();
    useCase = GetDashboardUseCase(repository);
  });

  test('delegates to repository.getDashboard and forwards a success', () async {
    const dashboard = DashboardEntity(
      totalChildren: 2,
      totalMedications: 3,
      upcomingAppointments: 1,
      recentActivities: [],
    );
    when(
      repository.getDashboard(),
    ).thenAnswer((_) async => const Result.success(dashboard));

    final result = await useCase();

    expect(result.dataOrNull, dashboard);
    verify(repository.getDashboard()).called(1);
  });

  test('forwards a failure from the repository unchanged', () async {
    when(
      repository.getDashboard(),
    ).thenAnswer((_) async => const Result.failure(NetworkException()));

    final result = await useCase();

    expect(result.isFailure, isTrue);
  });
}
