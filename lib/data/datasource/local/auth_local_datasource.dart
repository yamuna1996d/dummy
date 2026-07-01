import 'package:kincare/app/constants/hive_keys.dart';
import 'package:kincare/core/storage/hive_storage.dart';
import 'package:kincare/data/models/user_model.dart';

/// Local datasource for authentication session management.
class AuthLocalDatasource {
  const AuthLocalDatasource(this._storage);

  final LocalStorage _storage;

  Future<void> saveSession(UserModel user, {bool rememberMe = false}) async {
    await _storage.put(HiveKeys.sessionBox, HiveKeys.isLoggedIn, true);
    await _storage.put(HiveKeys.sessionBox, HiveKeys.rememberMe, rememberMe);
    if (rememberMe) {
      await _storage.put(
        HiveKeys.sessionBox,
        HiveKeys.lastLoginEmail,
        user.email,
      );
    }
  }

  Future<void> clearSession() async {
    await _storage.clearBox(HiveKeys.sessionBox);
  }

  bool isLoggedIn() {
    return _storage.get<bool>(
          HiveKeys.sessionBox,
          HiveKeys.isLoggedIn,
          defaultValue: false,
        ) ??
        false;
  }

  String? getLastLoginEmail() {
    return _storage.get<String>(HiveKeys.sessionBox, HiveKeys.lastLoginEmail);
  }
}
