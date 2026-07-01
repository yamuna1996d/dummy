import 'dart:async';

import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/child_model.dart';
import 'package:kincare/data/models/dashboard_model.dart';
import 'package:kincare/data/models/medication_model.dart';
import 'package:kincare/data/models/user_model.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:mockito/mockito.dart';

/// Registers dummy values for the sealed [Result] type so Mockito can stub
/// methods that return `Future<Result<T>>` without needing a real value for
/// every call site — Mockito can't synthesize one on its own since [Result]
/// has no zero-arg constructor.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  provideDummy<Result<void>>(const Result.success(null));
  provideDummy<Result<List<ChildEntity>>>(
    const Result.success(<ChildEntity>[]),
  );
  provideDummy<Result<ChildEntity>>(
    const Result.success(ChildEntity(id: '', name: '')),
  );
  provideDummy<Result<List<MedicationEntity>>>(
    const Result.success(<MedicationEntity>[]),
  );
  provideDummy<Result<MedicationEntity>>(
    const Result.success(MedicationEntity(id: '', name: '')),
  );
  provideDummy<Result<DashboardEntity>>(
    const Result.success(
      DashboardEntity(
        totalChildren: 0,
        totalMedications: 0,
        upcomingAppointments: 0,
        recentActivities: [],
      ),
    ),
  );
  provideDummy<Result<UserEntity>>(
    const Result.success(UserEntity(id: '', name: '', email: '')),
  );
  provideDummy<Result<Map<String, dynamic>>>(
    const Result.success(<String, dynamic>{}),
  );
  provideDummy<Result<bool>>(const Result.success(false));

  // Datasources return Result<Model>, not Result<Entity> — both need dummies
  // since the Model subtypes aren't assignable from the Entity dummies above.
  provideDummy<Result<List<ChildModel>>>(const Result.success(<ChildModel>[]));
  provideDummy<Result<ChildModel>>(
    const Result.success(ChildModel(id: '', name: '')),
  );
  provideDummy<Result<List<MedicationModel>>>(
    const Result.success(<MedicationModel>[]),
  );
  provideDummy<Result<MedicationModel>>(
    const Result.success(MedicationModel(id: '', name: '')),
  );
  provideDummy<Result<DashboardModel>>(
    const Result.success(
      DashboardModel(
        totalChildren: 0,
        totalMedications: 0,
        upcomingAppointments: 0,
        recentActivities: [],
      ),
    ),
  );
  provideDummy<Result<UserModel>>(
    const Result.success(UserModel(id: '', name: '', email: '')),
  );

  await testMain();
}
