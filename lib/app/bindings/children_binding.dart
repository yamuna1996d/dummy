import 'package:get/get.dart';
import 'package:kincare/data/datasource/remote/children_remote_datasource.dart';
import 'package:kincare/data/repositories/children_repository_impl.dart';
import 'package:kincare/domain/repositories/children_repository.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:kincare/domain/usecases/get_child_details_usecase.dart';
import 'package:kincare/presentation/controllers/children_controller.dart';

/// Dependency injection binding for the children module.
class ChildrenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChildrenRemoteDatasource(Get.find()));
    Get.lazyPut<ChildrenRepository>(
      () => ChildrenRepositoryImpl(
        remoteDatasource: Get.find(),
        networkInfo: Get.find(),
      ),
    );
    Get.lazyPut(() => GetChildrenUseCase(Get.find()));
    Get.lazyPut(() => GetChildDetailsUseCase(Get.find()));
    Get.lazyPut(
      () => ChildrenController(
        getChildrenUseCase: Get.find(),
        getChildDetailsUseCase: Get.find(),
        networkInfo: Get.find(),
      ),
    );
  }
}
