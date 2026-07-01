/// Constants for Hive box names and storage keys.
abstract final class HiveKeys {
  // Box Names
  static const String sessionBox = 'session_box';
  static const String settingsBox = 'settings_box';
  // Stores user-created / user-modified records so mutations survive restarts.
  static const String dataBox = 'data_box';

  // Session Keys
  static const String isLoggedIn = 'is_logged_in';
  static const String authToken = 'auth_token';
  static const String rememberMe = 'remember_me';
  static const String lastLoginEmail = 'last_login_email';

  // Settings Keys
  static const String locale = 'locale';

  // Data persistence keys (stored in dataBox)
  static const String cachedMedications = 'medications';
  static const String cachedChildren = 'children';
  static const String cachedProfile = 'profile';
}
