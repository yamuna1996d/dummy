/// Centralized string constants for the KinCare application.
abstract final class AppStrings {
  static const String appName = 'KinCare';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Enterprise Child & Medication Management';
  static const String developerName = 'KinCare Team';

  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String emailHint = 'Enter your email address';
  static const String passwordHint = 'Enter your password';
  static const String rememberMe = 'Remember me';
  static const String loginButton = 'Sign In';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Invalid email or password';
  static const String welcomeBack = 'Welcome Back';
  static const String signInToContinue = 'Sign in to continue to KinCare';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalChildren = 'Total Children';
  static const String totalMedications = 'Total Medications';
  static const String upcomingAppointments = 'Upcoming Appointments';
  static const String quickActions = 'Quick Actions';
  static const String recentActivities = 'Recent Activities';

  // Children
  static const String children = 'Children';
  static const String addChild = 'Add Child';
  static const String editChild = 'Edit Child';
  static const String deleteChild = 'Delete Child';
  static const String childDetails = 'Child Details';
  static const String childProfile = 'Child Profile';
  static const String childName = 'Child Name';
  static const String childAge = 'Age';
  static const String noChildren = 'No children added yet';
  static const String searchChildren = 'Search children...';
  static const String viewHistory = 'View History';
  static const String healthMetrics = 'Health Metrics';
  static const String activeMedications = 'Active Medications';
  static const String upcomingAppointment = 'Upcoming Appointment';
  static const String growthTracking = 'Growth Tracking';

  // Medications
  static const String medications = 'Medications';
  static const String addMedication = 'Add Medication';
  static const String editMedication = 'Edit Medication';
  static const String deleteMedication = 'Delete Medication';
  static const String medicationName = 'Medication Name';
  static const String dosage = 'Dosage';
  static const String frequency = 'Frequency';
  static const String noMedications = 'No medications added yet';
  static const String searchMedications = 'Search medications...';
  static const String deleteConfirmation =
      'Are you sure you want to delete this item?';
  static const String discardChanges = 'Discard changes?';
  static const String unsavedChangesMessage =
      'You have unsaved changes. If you leave now, they will be lost.';
  static const String discard = 'Discard';
  static const String keepEditing = 'Keep editing';

  // Profile
  static const String profile = 'Profile';
  static const String name = 'Name';
  static const String phone = 'Phone';
  static const String saveChanges = 'Save Changes';

  // Help
  static const String help = 'Help & Support';
  static const String faq = 'Frequently Asked Questions';
  static const String contactSupport = 'Contact Support';
  static const String supportEmail = 'support@kincare.com';
  static const String supportPhone = '+1 (800) 555-0199';

  // About
  static const String about = 'About';
  static const String version = 'Version';
  static const String flutterVersion = 'Flutter Version';
  static const String developer = 'Developer';
  static const String license = 'License';
  static const String openSourceLicenses = 'Open Source Licenses';

  // Common
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String noInternet = 'No internet connection';
  static const String timeout = 'Request timed out';
  static const String unexpectedError = 'An unexpected error occurred';
  static const String pullToRefresh = 'Pull to refresh';
  static const String sortBy = 'Sort by';
  static const String filterBy = 'Filter by';
}
