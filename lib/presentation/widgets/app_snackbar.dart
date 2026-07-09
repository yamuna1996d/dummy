import 'package:get/get.dart';
import 'package:kincare/app/constants/app_strings.dart';

/// Centralized snackbar helper so success/error messages look and behave
/// the same everywhere they're shown.
abstract final class AppSnackbar {
  static void success(String message) {
    Get.snackbar(AppStrings.success, message);
  }
}
