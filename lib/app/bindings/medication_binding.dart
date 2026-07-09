import 'package:get/get.dart';
import 'package:kincare/data/datasource/remote/children_remote_datasource.dart';
import 'package:kincare/data/datasource/remote/medication_remote_datasource.dart';
import 'package:kincare/data/repositories/children_repository_impl.dart';
import 'package:kincare/data/repositories/medication_repository_impl.dart';
import 'package:kincare/domain/repositories/children_repository.dart';
import 'package:kincare/domain/repositories/medication_repository.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:kincare/domain/usecases/get_medications_usecase.dart';
import 'package:kincare/domain/usecases/create_medication_usecase.dart';
import 'package:kincare/domain/usecases/update_medication_usecase.dart';
import 'package:kincare/domain/usecases/delete_medication_usecase.dart';
import 'package:kincare/presentation/controllers/medication_controller.dart';

/// Dependency injection binding for the medication module.
class MedicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MedicationRemoteDatasource(Get.find()));
    Get.lazyPut<MedicationRepository>(
      () => MedicationRepositoryImpl(
        remoteDatasource: Get.find(),
        networkInfo: Get.find(),
      ),
    );
    Get.lazyPut(() => GetMedicationsUseCase(Get.find()));
    Get.lazyPut(() => CreateMedicationUseCase(Get.find()));
    Get.lazyPut(() => UpdateMedicationUseCase(Get.find()));
    Get.lazyPut(() => DeleteMedicationUseCase(Get.find()));

    // Children are needed to populate the medication form's child picker.
    Get.lazyPut(() => ChildrenRemoteDatasource(Get.find()));
    Get.lazyPut<ChildrenRepository>(
      () => ChildrenRepositoryImpl(
        remoteDatasource: Get.find(),
        networkInfo: Get.find(),
      ),
    );
    Get.lazyPut(() => GetChildrenUseCase(Get.find()));

    Get.lazyPut(
      () => MedicationController(
        getMedicationsUseCase: Get.find(),
        createMedicationUseCase: Get.find(),
        updateMedicationUseCase: Get.find(),
        deleteMedicationUseCase: Get.find(),
        getChildrenUseCase: Get.find(),
        networkInfo: Get.find(),
      ),
    );
  }
}
