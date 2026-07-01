import 'package:get/get.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';
import 'package:kincare/domain/usecases/get_dashboard_usecase.dart';

/// Controller for dashboard state and actions.
class DashboardController extends GetxController {
  DashboardController({required GetDashboardUseCase getDashboardUseCase})
    : _getDashboardUseCase = getDashboardUseCase;

  final GetDashboardUseCase _getDashboardUseCase;

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final dashboard = Rxn<DashboardEntity>();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  /// Loads dashboard data from the repository.
  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getDashboardUseCase();

    result.when(
      success: (data) {
        dashboard.value = data;
        isLoading.value = false;
      },
      failure: (exception) {
        errorMessage.value = switch (exception) {
          NetworkException() => exception.message,
          _ => 'Failed to load dashboard',
        };
        isLoading.value = false;
      },
    );
  }

  /// Refreshes dashboard data (for pull-to-refresh).
  @override
  Future<void> refresh() async {
    await loadDashboard();
  }
}
