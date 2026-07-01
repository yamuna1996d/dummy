import 'package:get/get.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/usecases/get_profile_usecase.dart';

/// Controller for user profile state and actions.
class ProfileController extends GetxController {
  ProfileController({required GetProfileUseCase getProfileUseCase})
    : _getProfileUseCase = getProfileUseCase;

  final GetProfileUseCase _getProfileUseCase;

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final profile = Rxn<UserEntity>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Loads the user profile.
  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getProfileUseCase();

    result.when(
      success: (user) {
        profile.value = user;
        isLoading.value = false;
      },
      failure: (exception) {
        errorMessage.value = switch (exception) {
          NetworkException() => exception.message,
          _ => 'Failed to load profile',
        };
        isLoading.value = false;
      },
    );
  }
}
