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

  // Login screen
  static const String emailAddress = 'Email Address';
  static const String emailFieldHint = 'admin@kincare.com';
  static const String passwordFieldHint = 'password';
  static const String logIn = 'Log in';
  static const String loginSubtitle =
      "Continue managing your child's health\nwith Clinical Compassion.";
  static const String demoCredentials = 'Demo: admin@kincare.com / password';
  static const String showPassword = 'Show password';
  static const String hidePassword = 'Hide password';
  static const String emailSemanticLabel =
      'Email address, tap and enter your email';
  static const String passwordSemanticLabel = 'Password';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalChildren = 'Total Children';
  static const String totalMedications = 'Total Medications';
  static const String upcomingAppointments = 'Upcoming Appointments';
  static const String quickActions = 'Quick Actions';
  static const String recentActivities = 'Recent Activities';
  static const String todayAtAGlance = 'TODAY AT A GLANCE';
  static const String yourChildrenSection = 'YOUR CHILDREN';
  static const String upcomingVisitSection = 'UPCOMING VISIT';
  static const String childrenUnderCare = 'Children Under Care';
  static const String medicationDosesDue = 'Medication Doses Due';
  static const String upcomingVisit = 'Upcoming Visit';
  static const String viewAll = 'View All';
  static const String viewAllChildren = 'View all children';
  static const String details = 'Details';
  static const String viewDetails = 'View details';
  static const String noUpcomingVisits = 'No upcoming visits';
  static const String noUpcomingVisitsLabel =
      'Upcoming visit: no upcoming visits scheduled';
  static const String yrs = 'yrs';
  static const String allClearToday = 'All clear today';
  static const String doseRemaining = '1 dose remaining';

  static String helloGreeting(String name) => 'Hello, $name';

  static String glanceSummary(
      String childCount,
      String medCount,
      String visitCount,
      ) =>
      'Today at a glance: $childCount children under care, '
          '$medCount medication doses due, '
          '$visitCount upcoming visit${visitCount == '1' ? '' : 's'}';

  static String selectedChildLabel(String name, String age, String status) =>
      'Selected child: $name, age $age, medication: $status';

  static String opensProfileHint(String name) => "Opens $name's profile";

  static String opensChildProfileHint = "Opens this child's profile";

  static String upcomingVisitLabel({
    required String childName,
    required String title,
    String? dateLabel,
    String? location,
  }) {
    final buffer = StringBuffer('Upcoming visit for $childName: $title');
    if (dateLabel != null && dateLabel.isNotEmpty) {
      buffer.write(', $dateLabel');
    }
    if (location != null) buffer.write(', at $location');
    return buffer.toString();
  }

  static String directionsToLabel(String? location) =>
      'Get directions to ${location ?? "the clinic"}';

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
  static const String childNotFound = 'Child not found';
  static const String noActiveMedications = 'No active medications';
  static const String childNameSemanticLabel = 'Child name';
  static const String nameRequired = 'Name is required';
  static const String description = 'Description';
  static const String descriptionSemanticLabel = 'Description or notes';
  static const String saveNewChild = 'Save new child';
  static const String childAddedSuccess = 'Child added successfully';

  // Children list
  static const String yourChildren = 'Your children';
  static const String bloodType = 'Blood Type';
  static const String vaccines = 'VACCINES';
  static const String medication = 'MEDICATION';
  static const String nextCheckup = 'NEXT CHECKUP';
  static const String activity = 'ACTIVITY';
  static const String previousPage = 'Previous page';
  static const String nextPage = 'Next page';

  static String childCardHint(String name) =>
      "Double tap to open $name's full profile";

  static String childCardLabel({
    required String name,
    required int age,
    required String bloodType,
    required String secondaryLabel,
  }) =>
      '$name, age $age $years, $bloodType blood type. $secondaryLabel';

  static String paginationStatus(int start, int end, int total) =>
      'Showing $start-$end of $total children';

  static String pageLabel(int page, {bool isCurrent = false}) =>
      'Page $page${isCurrent ? ", current page" : ""}';

  // Health metrics
  static const String bloodGroup = 'Blood Group';
  static const String weight = 'Weight';
  static const String allergies = 'Allergies';

  // Dropdown field
  static const String notSelected = 'Not selected';
  static const String currentlySelected = 'Currently selected';
  static const String dropdownPickerHint =
      'Opens a picker to choose a different value';

  static String selectLabel(String field) => 'Select $field';

  static String dropdownFieldLabel(String field, String displayText) =>
      '$field. $currentlySelected: $displayText';


  // Appointment card
  static const String getDirections = 'Get Directions';
  static const String callClinic = 'Call Clinic';
  static const String locationNotAvailable = 'Location not available';
  static const String phoneNotAvailable = 'Phone number not available';
  static const String couldNotOpenPhone = 'Could not open the phone app';
  static const String couldNotOpenMaps = 'Could not open the maps app';
  static const String getDirectionsLabel = 'Get directions';
  static const String callClinicLabel = 'Call clinic';

  // Semantic label helpers — child details
  static String childHeaderLabel(String name, int? age, String? gender) {
    final buffer = StringBuffer(name);
    if (age != null) buffer.write(', $age years');
    if (gender != null) buffer.write(', gender $gender');
    return buffer.toString();
  }

  static String metricLabel(String name, String label, String value) =>
      "$name's $label: $value";

  static String allergyLabel(
      String name,
      String allergyName,
      String? allergyNote,
      ) =>
      "$name's Allergy: $allergyName${allergyNote != null ? ", $allergyNote" : ""}";

  static String activeMedicationLabel(
      String name,
      String? dosage,
      String? frequency,
      ) =>
      'active medication $name, dosage: ${dosage ?? ""}, ${frequency ?? ""}';

  static String appointmentLabel({
    required String title,
    DateTime? date,
    String? time,
    String? location,
  }) {
    final buffer = StringBuffer('Upcoming appointment: $title');
    if (date != null) {
      buffer.write(' on ${_monthNames[date.month - 1]} ${date.day}');
    }
    if (time != null) buffer.write(', at $time');
    if (location != null) buffer.write(', location $location');
    return buffer.toString();
  }

  static String directionsHint(String? location) => location != null
      ? 'Shows directions to $location'
      : 'Shows directions to the clinic';

  static String callClinicHint(String? phone) =>
      phone != null ? 'Calls $phone' : 'Calls the clinic';

  // Semantic label helpers — profile
  static String profileAvatarLabel(String name) =>
      'Profile avatar for $name';

  static String profileIdentityLabel(String name, String? username) =>
      username != null
          ? 'Name: $name, username: @$username'
          : 'Name: $name';

  static String emailInfoLabel(String email) => 'Email: $email';

  static String phoneInfoLabel(String? phone) =>
      'Phone: ${phone ?? notSet}';

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
  static const String saveMedication = 'Save medication';
  static const String medicationAddedSuccess = 'Medication added successfully';
  static const String medicationUpdatedSuccess =
      'Medication updated successfully';

  // Medication form fields
  static const String medicationNameHint = 'e.g. Amoxicillin 250 mg';
  static const String medicationNameSemanticLabel = 'Medication name';
  static const String child = 'Child';
  static const String selectChild = 'Select a child';
  static const String dosageHint = 'e.g. 5 ml';
  static const String dosageHelper = 'Amount given each time.';
  static const String dosageSemanticLabel = 'Dosage amount';
  static const String selectFrequency = 'Select frequency';
  static const String notesOptional = 'Notes (optional)';
  static const String notesHint = 'e.g. give with food';
  static const String notesSemanticLabel = 'Notes';

  // Medication list screen
  static const String medicationHistory = 'Medication history';
  static const String allMedications = 'All medications';
  static const String medicationListSubtitle =
      'Manage daily dosage and records';
  static const String unassigned = 'Unassigned';
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String notSpecified = 'not specified';

  static String childMedicationsTitle(String childName) =>
      "$childName's Medications";

  static String noMedicationsForChild(String childName) =>
      'No medications for $childName yet';

  static String editItemLabel(String name) => 'Edit $name';

  static String deleteItemLabel(String name) => 'Delete $name';

  static String medicationCardLabel({
    required String name,
    required bool isActive,
    required String childName,
    String? frequency,
  }) =>
      'Selected medication: $name, '
          'medication status is ${isActive ? "active" : "inactive"}, '
          'child name is $childName, '
          'dosage ${frequency ?? notSpecified}, ';

  // Profile
  static const String profile = 'Profile';
  static const String name = 'Name';
  static const String phone = 'Phone';
  static const String saveChanges = 'Save Changes';
  static const String notSet = 'Not set';

  // Help
  static const String help = 'Help & Support';
  static const String faq = 'Frequently Asked Questions';
  static const String contactSupport = 'Contact Support';
  static const String supportEmail = 'support@kincare.com';
  static const String supportPhone = '+1 (800) 555-0199';

  // Help screen
  static const String gettingStartedSection = 'GETTING STARTED';
  static const String gettingStartedStep1 =
      'Add a child profile from the Children screen.';
  static const String gettingStartedStep2 =
      'Add their medications and set dose times.';
  static const String gettingStartedStep3 =
      'Mark each dose as given from the Dashboard.';
  static const List<String> gettingStartedSteps = [
    gettingStartedStep1,
    gettingStartedStep2,
    gettingStartedStep3,
  ];
  static const String accessibilitySection = 'ACCESSIBILITY';
  static const String accessibilityBody =
      '$appName is built for screen readers and keyboards. '
      'Every control has a label, a focus outline, and a '
      'target at least 48 px wide.';
  static const String accessibilityHint =
      'Adjust text size and contrast in Profile → Accessibility.';
  static const String contactSection = 'CONTACT';
  static const String emailSupport = 'Email support';
  static const String helpEmail = 'help@kincare.app';

  static String emailSupportLabel(String email) =>
      'Email support at $email';

  static String stepLabel(String stepNumber, String text) =>
      'Step $stepNumber: $text';

  static String gettingStartedLabel() =>
      'Getting started: '
          'Step 1: $gettingStartedStep1 '
          'Step 2: $gettingStartedStep2 '
          'Step 3: $gettingStartedStep3';

  static String accessibilityLabel() =>
      'Accessibility: $accessibilityBody $accessibilityHint';

  // About
  static const String about = 'About';
  static const String version = 'Version';
  static const String flutterVersion = 'Flutter Version';
  static const String flutterVersionValue = '3.41.7';
  static const String developer = 'Developer';
  static const String license = 'License';
  static const String openSourceLicenses = 'Open Source Licenses';

  static String get appIconLabel => '$appName application icon';

  static String copyrightNotice(String developer) =>
      '© 2026 $developer. All rights reserved.';

  // Kincare app bar
  static const String openNavigationMenuHint = 'Open navigation menu';
  static const String menuTooltip = 'Menu';
  static const String helpButtonHint =
      'For help using app double tap this button';
  static const String helpTooltip = 'Help';
  static const String userAvatarLabel = 'User avatar';

  // Dashboard summary card
  static const String opensMoreDetailsHint = 'Opens more details';

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
  static const String years = 'years';
  static const String kg = 'kg';
  static const String dismissDialogHint = 'Dismisses the dialog';
  static const String logoLabel = '$appName logo';
  static const String navigationMenu = 'Navigation Menu';
  static const String back = 'Back';
  static const String backToDashboardHint = 'Returns to the dashboard';
  static const String confirmActionHint = 'Confirms the action';
  static const String confirmDestructiveHint = 'Confirms the destructive action';
  // Private — used only by the semantic helpers above.
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const String getDirectionUrl = 'https://www.google.com/maps/dir/?api=1&destination=';
}