import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/domain/usecases/login_usecase.dart';
import 'package:kincare/domain/usecases/logout_usecase.dart';

/// Controller for authentication state and actions.
class AuthController extends GetxController {
  AuthController({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase;

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final errorMessage = RxnString();
  final currentUser = Rxn<UserEntity>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  /// Validates email format.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.invalidEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  /// Validates password length.
  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return AppStrings.invalidPassword;
    }
    return null;
  }

  /// Toggles password visibility.
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  /// Validates the form, calls LoginUseCase, then navigates to Dashboard on
  /// success or shows an inline error banner on failure.
  ///
  /// `Get.offAllNamed` replaces the entire navigation stack so the user
  /// cannot press "back" to return to the login screen after signing in.
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = null;

    final result = await _loginUseCase(
      emailController.text.trim(),
      passwordController.text,
      rememberMe: rememberMe.value,
    );

    isLoading.value = false;

    result.when(
      success: (user) {
        currentUser.value = user;
        Get.offAllNamed(AppRoutes.dashboard);
      },
      failure: (exception) {
        // Map each exception type to a human-readable message shown in the
        // error banner above the form fields.
        errorMessage.value = switch (exception) {
          AuthException() => exception.message,
          NetworkException() => AppStrings.noInternet,
          TimeoutException() => AppStrings.timeout,
          _ => AppStrings.unexpectedError,
        };
      },
    );
  }

  /// Clears session state and navigates back to the login screen.
  ///
  /// `Get.offAllNamed` removes all routes so the user cannot press "back"
  /// to reach a protected screen after logging out.
  Future<void> logout() async {
    await _logoutUseCase();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
