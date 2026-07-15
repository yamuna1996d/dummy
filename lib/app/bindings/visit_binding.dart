import 'package:get/get.dart';
import 'package:kincare/data/datasource/remote/children_remote_datasource.dart';
import 'package:kincare/data/datasource/remote/visit_remote_datasource.dart';
import 'package:kincare/data/repositories/children_repository_impl.dart';
import 'package:kincare/data/repositories/visit_repository_impl.dart';
import 'package:kincare/domain/repositories/children_repository.dart';
import 'package:kincare/domain/repositories/visit_repository.dart';
import 'package:kincare/domain/usecases/create_visit_usecase.dart';
import 'package:kincare/domain/usecases/delete_visit_usecase.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:kincare/domain/usecases/get_visit_details_usecase.dart';
import 'package:kincare/domain/usecases/get_visits_usecase.dart';
import 'package:kincare/domain/usecases/update_visit_usecase.dart';
import 'package:kincare/presentation/controllers/visit_controller.dart';

/// Dependency injection binding for the visit module.
class VisitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VisitRemoteDatasource(Get.find()));
    Get.lazyPut<VisitRepository>(
      () => VisitRepositoryImpl(remoteDatasource: Get.find(), networkInfo: Get.find()),
    );
    Get.lazyPut(() => GetVisitsUseCase(Get.find()));
    Get.lazyPut(() => GetVisitDetailsUseCase(Get.find()));
    Get.lazyPut(() => CreateVisitUseCase(Get.find()));
    Get.lazyPut(() => UpdateVisitUseCase(Get.find()));
    Get.lazyPut(() => DeleteVisitUseCase(Get.find()));

    // Children are needed to populate the visit form's child picker.
    Get.lazyPut(() => ChildrenRemoteDatasource(Get.find()));
    Get.lazyPut<ChildrenRepository>(
      () => ChildrenRepositoryImpl(
        remoteDatasource: Get.find(),
        networkInfo: Get.find(),
      ),
    );
    Get.lazyPut(() => GetChildrenUseCase(Get.find()));

    Get.lazyPut(
      () => VisitController(
        getVisitsUseCase: Get.find(),
        getVisitDetailsUseCase: Get.find(),
        createVisitUseCase: Get.find(),
        updateVisitUseCase: Get.find(),
        deleteVisitUseCase: Get.find(),
        getChildrenUseCase: Get.find(),
        networkInfo: Get.find(),
      ),
    );
  }
}
