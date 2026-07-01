import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/app/constants/hive_keys.dart';
import 'package:kincare/data/datasource/local/auth_local_datasource.dart';
import 'package:kincare/data/models/user_model.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockLocalStorage storage;
  late AuthLocalDatasource datasource;

  setUp(() {
    storage = MockLocalStorage();
    datasource = AuthLocalDatasource(storage);
  });

  group('saveSession', () {
    test('always marks the session logged in and stores rememberMe', () async {
      const user = UserModel(id: '1', name: 'Jane', email: 'jane@kincare.com');

      await datasource.saveSession(user, rememberMe: false);

      verify(
        storage.put(HiveKeys.sessionBox, HiveKeys.isLoggedIn, true),
      ).called(1);
      verify(
        storage.put(HiveKeys.sessionBox, HiveKeys.rememberMe, false),
      ).called(1);
    });

    test('persists the login email only when rememberMe is true', () async {
      const user = UserModel(id: '1', name: 'Jane', email: 'jane@kincare.com');

      await datasource.saveSession(user, rememberMe: true);

      verify(
        storage.put(HiveKeys.sessionBox, HiveKeys.lastLoginEmail, user.email),
      ).called(1);
    });

    test('does not persist the login email when rememberMe is false', () async {
      const user = UserModel(id: '1', name: 'Jane', email: 'jane@kincare.com');

      await datasource.saveSession(user, rememberMe: false);

      verifyNever(
        storage.put(HiveKeys.sessionBox, HiveKeys.lastLoginEmail, any),
      );
    });
  });

  test('clearSession clears the session box', () async {
    await datasource.clearSession();
    verify(storage.clearBox(HiveKeys.sessionBox)).called(1);
  });

  group('isLoggedIn', () {
    test('returns true when the storage flag is set', () {
      when(
        storage.get<bool>(
          HiveKeys.sessionBox,
          HiveKeys.isLoggedIn,
          defaultValue: false,
        ),
      ).thenReturn(true);

      expect(datasource.isLoggedIn(), isTrue);
    });

    test('defaults to false when the storage value is missing', () {
      when(
        storage.get<bool>(
          HiveKeys.sessionBox,
          HiveKeys.isLoggedIn,
          defaultValue: false,
        ),
      ).thenReturn(null);

      expect(datasource.isLoggedIn(), isFalse);
    });
  });

  group('getLastLoginEmail', () {
    test('returns the stored email', () {
      when(
        storage.get<String>(HiveKeys.sessionBox, HiveKeys.lastLoginEmail),
      ).thenReturn('jane@kincare.com');

      expect(datasource.getLastLoginEmail(), 'jane@kincare.com');
    });

    test('returns null when no email was stored', () {
      when(
        storage.get<String>(HiveKeys.sessionBox, HiveKeys.lastLoginEmail),
      ).thenReturn(null);

      expect(datasource.getLastLoginEmail(), isNull);
    });
  });
}
