import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kincare/app/routes/app_routes.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/user_entity.dart';
import 'package:kincare/presentation/controllers/auth_controller.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockLoginUseCase loginUseCase;
  late MockLogoutUseCase logoutUseCase;
  late AuthController controller;

  const user = UserEntity(id: '1', name: 'Admin', email: 'admin@kincare.com');

  setUp(() {
    loginUseCase = MockLoginUseCase();
    logoutUseCase = MockLogoutUseCase();
    controller = AuthController(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
    );
  });

  group('validateEmail', () {
    test('rejects an empty value', () {
      expect(controller.validateEmail(''), isNotNull);
    });

    test('rejects a value with no @', () {
      expect(controller.validateEmail('not-an-email'), isNotNull);
    });

    test('accepts a well-formed email', () {
      expect(controller.validateEmail('user@example.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('rejects a password shorter than 6 characters', () {
      expect(controller.validatePassword('12345'), isNotNull);
    });

    test('accepts a password of 6 or more characters', () {
      expect(controller.validatePassword('123456'), isNull);
    });

    test('rejects a null value', () {
      expect(controller.validatePassword(null), isNotNull);
    });
  });

  test('togglePasswordVisibility flips obscurePassword', () {
    expect(controller.obscurePassword.value, isTrue);
    controller.togglePasswordVisibility();
    expect(controller.obscurePassword.value, isFalse);
  });

  group('login', () {
    Future<void> pumpForm(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Form(key: controller.formKey, child: const SizedBox()),
        ),
      );
    }

    testWidgets(
      'sets an inline error message on AuthException without navigating',
      (tester) async {
        await pumpForm(tester);
        controller.emailController.text = 'admin@kincare.com';
        controller.passwordController.text = 'wrong';
        when(
          loginUseCase(any, any, rememberMe: anyNamed('rememberMe')),
        ).thenAnswer(
          (_) async =>
              const Result.failure(AuthException('Invalid credentials')),
        );

        await controller.login();

        expect(controller.errorMessage.value, 'Invalid credentials');
        expect(controller.isLoading.value, isFalse);
        expect(controller.currentUser.value, isNull);
      },
    );

    testWidgets('maps NetworkException/TimeoutException/other to app strings', (
      tester,
    ) async {
      await pumpForm(tester);
      controller.emailController.text = 'admin@kincare.com';
      controller.passwordController.text = 'password';

      when(
        loginUseCase(any, any, rememberMe: anyNamed('rememberMe')),
      ).thenAnswer((_) async => const Result.failure(NetworkException()));
      await controller.login();
      expect(controller.errorMessage.value, isNotEmpty);

      when(
        loginUseCase(any, any, rememberMe: anyNamed('rememberMe')),
      ).thenAnswer((_) async => const Result.failure(TimeoutException()));
      await controller.login();
      expect(controller.errorMessage.value, isNotEmpty);
    });

    testWidgets('on success, sets currentUser and navigates to the dashboard', (
      tester,
    ) async {
      when(
        loginUseCase(any, any, rememberMe: anyNamed('rememberMe')),
      ).thenAnswer((_) async => const Result.success(user));

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: AppRoutes.login,
          getPages: [
            GetPage(
              name: AppRoutes.login,
              page: () =>
                  Form(key: controller.formKey, child: const SizedBox()),
            ),
            GetPage(
              name: AppRoutes.dashboard,
              page: () => const Text('Dashboard'),
            ),
          ],
        ),
      );

      controller.emailController.text = 'admin@kincare.com';
      controller.passwordController.text = 'password';

      await controller.login();
      await tester.pumpAndSettle();

      expect(controller.currentUser.value, user);
      expect(Get.currentRoute, AppRoutes.dashboard);
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  group('logout', () {
    testWidgets('clears currentUser and navigates back to login', (
      tester,
    ) async {
      when(logoutUseCase()).thenAnswer((_) async => const Result.success(null));

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: AppRoutes.dashboard,
          getPages: [
            GetPage(name: AppRoutes.login, page: () => const Text('Login')),
            GetPage(
              name: AppRoutes.dashboard,
              page: () => const Text('Dashboard'),
            ),
          ],
        ),
      );

      controller.currentUser.value = user;

      await controller.logout();
      await tester.pumpAndSettle();

      expect(controller.currentUser.value, isNull);
      expect(Get.currentRoute, AppRoutes.login);
      verify(logoutUseCase()).called(1);
    });
  });
}
