import 'package:get/get.dart';
import 'package:kincare/data/datasource/remote/profile_remote_datasource.dart';
import 'package:kincare/data/repositories/profile_repository_impl.dart';
import 'package:kincare/domain/repositories/profile_repository.dart';
import 'package:kincare/domain/usecases/get_profile_usecase.dart';
import 'package:kincare/presentation/controllers/profile_controller.dart';

/// Dependency injection binding for the profile module.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileRemoteDatasource(Get.find()));
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDatasource: Get.find(),
        networkInfo: Get.find(),
      ),
    );
    Get.lazyPut(() => GetProfileUseCase(Get.find()));
    Get.lazyPut(() => ProfileController(getProfileUseCase: Get.find()));
  }
}
