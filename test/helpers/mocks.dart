import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/core/storage/hive_storage.dart';
import 'package:kincare/data/datasource/local/auth_local_datasource.dart';
import 'package:kincare/data/datasource/remote/auth_remote_datasource.dart';
import 'package:kincare/data/datasource/remote/children_remote_datasource.dart';
import 'package:kincare/data/datasource/remote/dashboard_remote_datasource.dart';
import 'package:kincare/data/datasource/remote/medication_remote_datasource.dart';
import 'package:kincare/data/datasource/remote/profile_remote_datasource.dart';
import 'package:kincare/domain/repositories/auth_repository.dart';
import 'package:kincare/domain/repositories/children_repository.dart';
import 'package:kincare/domain/repositories/dashboard_repository.dart';
import 'package:kincare/domain/repositories/medication_repository.dart';
import 'package:kincare/domain/repositories/profile_repository.dart';
import 'package:kincare/domain/usecases/create_medication_usecase.dart';
import 'package:kincare/domain/usecases/delete_medication_usecase.dart';
import 'package:kincare/domain/usecases/get_child_details_usecase.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:kincare/domain/usecases/get_dashboard_usecase.dart';
import 'package:kincare/domain/usecases/get_medications_usecase.dart';
import 'package:kincare/domain/usecases/get_profile_usecase.dart';
import 'package:kincare/domain/usecases/login_usecase.dart';
import 'package:kincare/domain/usecases/logout_usecase.dart';
import 'package:kincare/domain/usecases/update_medication_usecase.dart';
import 'package:mockito/annotations.dart';

/// Central mock registry. Run `dart run build_runner build` after editing
/// this file to regenerate `mocks.mocks.dart`.
@GenerateMocks([
  // Repository contracts
  ChildrenRepository,
  MedicationRepository,
  DashboardRepository,
  ProfileRepository,
  AuthRepository,
  // Datasources
  ChildrenRemoteDatasource,
  DashboardRemoteDatasource,
  MedicationRemoteDatasource,
  ProfileRemoteDatasource,
  AuthRemoteDatasource,
  AuthLocalDatasource,
  // Infra
  NetworkInfo,
  LocalStorage,
  GraphQLService,
  // Use cases (for controller tests)
  GetChildrenUseCase,
  GetChildDetailsUseCase,
  GetMedicationsUseCase,
  CreateMedicationUseCase,
  UpdateMedicationUseCase,
  DeleteMedicationUseCase,
  GetDashboardUseCase,
  GetProfileUseCase,
  LoginUseCase,
  LogoutUseCase,
])
void main() {}
