import 'package:get/get.dart';
import 'package:kincare/app/bindings/dashboard_binding.dart';
import 'package:kincare/app/bindings/children_binding.dart';
import 'package:kincare/app/bindings/medication_binding.dart';
import 'package:kincare/app/bindings/profile_binding.dart';
import 'package:kincare/presentation/modules/auth/login_screen.dart';
import 'package:kincare/presentation/modules/dashboard/dashboard_screen.dart';
import 'package:kincare/presentation/modules/children/children_list_screen.dart';
import 'package:kincare/presentation/modules/children/child_details_screen.dart';
import 'package:kincare/presentation/modules/children/add_child_screen.dart';
import 'package:kincare/presentation/modules/medication/medication_list_screen.dart';
import 'package:kincare/presentation/modules/medication/add_medication_screen.dart';
import 'package:kincare/presentation/modules/medication/edit_medication_screen.dart';
import 'package:kincare/presentation/modules/profile/profile_screen.dart';
import 'package:kincare/presentation/modules/help/help_screen.dart';
import 'package:kincare/presentation/modules/about/about_screen.dart';
import 'app_routes.dart';

/// Application page routing configuration.
///
/// Each [GetPage] pairs a named route constant (from [AppRoutes]) with its
/// screen widget and an optional [Bindings] that registers the controller(s)
/// the screen needs. Bindings are lazy — controllers are created on first use
/// and disposed when the route leaves the stack (unless marked `permanent`).
///
/// Auth is NOT listed here with a binding because AuthController is registered
/// permanently in [InitialBinding] so it survives across all routes (the
/// navigation drawer's logout button calls it from every screen).
///
/// Child Profile uses BOTH [ChildrenBinding] and [MedicationBinding] because
/// the profile body reads active medications from [MedicationController].
abstract final class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      // No binding — AuthController is already permanent via InitialBinding.
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.children,
      page: () => const ChildrenListScreen(),
      binding: ChildrenBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.childDetails,
      page: () => const ChildDetailsScreen(),
      // Two bindings: ChildrenController (loads the child record) and
      // MedicationController (supplies the active medications section).
      bindings: [ChildrenBinding(), MedicationBinding()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addChild,
      page: () => const AddChildScreen(),
      // No binding needed — AddChildScreen manages its own local form state.
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.medications,
      page: () => const MedicationListScreen(),
      binding: MedicationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addMedication,
      page: () => const AddMedicationScreen(),
      // MedicationController is already on the stack (registered by the
      // route that opened this screen), so no additional binding is needed.
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editMedication,
      page: () => const EditMedicationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.help,
      page: () => const HelpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
