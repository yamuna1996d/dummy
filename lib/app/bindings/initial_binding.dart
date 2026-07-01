import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:kincare/app/services/logger_service.dart';
import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/core/storage/hive_storage.dart';
import 'package:kincare/data/datasource/local/auth_local_datasource.dart';
import 'package:kincare/data/datasource/remote/auth_remote_datasource.dart';
import 'package:kincare/data/repositories/auth_repository_impl.dart';
import 'package:kincare/domain/repositories/auth_repository.dart';
import 'package:kincare/domain/usecases/login_usecase.dart';
import 'package:kincare/domain/usecases/logout_usecase.dart';
import 'package:kincare/presentation/controllers/auth_controller.dart';

/// Root-level dependency injection binding.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core
    Get.put<LocalStorage>(HiveStorage(), permanent: true);
    Get.put<NetworkInfo>(NetworkInfoImpl(Connectivity()), permanent: true);

    // Services
    Get.put<GraphQLService>(GraphQLService(), permanent: true);

    // Auth - kept permanent because the drawer's logout action needs
    // AuthController from every screen, not just the login route.
    Get.put(AuthLocalDatasource(Get.find()), permanent: true);
    Get.put(AuthRemoteDatasource(Get.find()), permanent: true);
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        remoteDatasource: Get.find(),
        localDatasource: Get.find(),
        networkInfo: Get.find(),
      ),
      permanent: true,
    );
    Get.put(LoginUseCase(Get.find()), permanent: true);
    Get.put(LogoutUseCase(Get.find()), permanent: true);
    Get.put(
      AuthController(loginUseCase: Get.find(), logoutUseCase: Get.find()),
      permanent: true,
    );

    LoggerService.instance.info('Initial dependencies registered');
  }
}
