import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';
import 'package:kincare/presentation/controllers/dashboard_controller.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockGetDashboardUseCase getDashboardUseCase;
  late DashboardController controller;

  const dashboard = DashboardEntity(
    totalChildren: 2,
    totalMedications: 3,
    upcomingAppointments: 1,
    recentActivities: [],
  );

  setUp(() {
    getDashboardUseCase = MockGetDashboardUseCase();
    controller = DashboardController(getDashboardUseCase: getDashboardUseCase);
  });

  group('loadDashboard', () {
    test(
      'populates dashboard and clears loading/error state on success',
      () async {
        when(
          getDashboardUseCase(),
        ).thenAnswer((_) async => const Result.success(dashboard));

        await controller.loadDashboard();

        expect(controller.dashboard.value, dashboard);
        expect(controller.isLoading.value, isFalse);
        expect(controller.errorMessage.value, isNull);
      },
    );

    test('maps NetworkException to its own message', () async {
      when(getDashboardUseCase()).thenAnswer(
        (_) async => const Result.failure(NetworkException('offline')),
      );

      await controller.loadDashboard();

      expect(controller.errorMessage.value, 'offline');
      expect(controller.isLoading.value, isFalse);
    });

    test('maps any other exception to a generic message', () async {
      when(
        getDashboardUseCase(),
      ).thenAnswer((_) async => const Result.failure(UnexpectedException()));

      await controller.loadDashboard();

      expect(controller.errorMessage.value, 'Failed to load dashboard');
    });
  });

  test('refresh reloads the dashboard', () async {
    when(
      getDashboardUseCase(),
    ).thenAnswer((_) async => const Result.success(dashboard));

    await controller.refresh();

    verify(getDashboardUseCase()).called(1);
    expect(controller.dashboard.value, dashboard);
  });
}
