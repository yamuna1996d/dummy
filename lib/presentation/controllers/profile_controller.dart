import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/usecases/get_profile_usecase.dart';
import 'package:kincare/domain/usecases/update_profile_usecase.dart';

/// Controller for user profile state and actions.
class ProfileController extends GetxController {
  ProfileController({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase;

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final profile = Rxn<UserEntity>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Loads the user profile.
  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getProfileUseCase();

    result.when(
      success: (user) {
        profile.value = user;
        nameController.text = user.name;
        emailController.text = user.email;
        phoneController.text = user.phone ?? '';
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

  /// Saves profile changes.
  Future<bool> saveProfile() async {
    if (!formKey.currentState!.validate()) return false;

    isSaving.value = true;

    final updated = UserEntity(
      id: profile.value?.id ?? '1',
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      avatarUrl: profile.value?.avatarUrl,
      username: profile.value?.username,
    );

    final result = await _updateProfileUseCase(updated);

    isSaving.value = false;
    return result.when(
      success: (user) {
        profile.value = user;
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }
}
