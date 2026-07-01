import 'package:get/get.dart';
import 'package:kincare/data/datasource/remote/dashboard_remote_datasource.dart';
import 'package:kincare/data/repositories/dashboard_repository_impl.dart';
import 'package:kincare/domain/repositories/dashboard_repository.dart';
import 'package:kincare/domain/usecases/get_dashboard_usecase.dart';
import 'package:kincare/presentation/controllers/dashboard_controller.dart';

/// Dependency injection binding for the dashboard module.
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardRemoteDatasource(Get.find()));
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDatasource: Get.find(),
        networkInfo: Get.find(),
      ),
    );
    Get.lazyPut(() => GetDashboardUseCase(Get.find()));
    Get.lazyPut(() => DashboardController(getDashboardUseCase: Get.find()));
  }
}
