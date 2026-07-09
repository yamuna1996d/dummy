import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/constants/app_strings.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/storage/hive_storage.dart';


/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = HiveStorage();
  await storage.init();
  Get.put<LocalStorage>(storage, permanent: true);

  final isLoggedIn =
      storage.get<bool>('session_box', 'is_logged_in', defaultValue: false) ??
      false;

  runApp(
    KinCareApp(
      initialRoute: isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
    ),
  );
}

/// Root application widget.
class KinCareApp extends StatelessWidget {
  const KinCareApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.fadeIn,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(
              context,
            ).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 2.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
