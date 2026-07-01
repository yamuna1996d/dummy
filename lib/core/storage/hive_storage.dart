import 'package:hive_flutter/hive_flutter.dart';
import 'package:kincare/app/constants/hive_keys.dart';
import 'package:kincare/app/services/logger_service.dart';

/// Abstraction for local key-value storage operations.
abstract class LocalStorage {
  Future<void> init();
  Future<void> put(String boxName, String key, dynamic value);
  T? get<T>(String boxName, String key, {T? defaultValue});
  Future<void> clearBox(String boxName);
}

/// Hive-based implementation of [LocalStorage].
class HiveStorage implements LocalStorage {
  final _log = LoggerService.instance;

  @override
  Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      _openBox(HiveKeys.sessionBox),
      _openBox(HiveKeys.settingsBox),
      _openBox(HiveKeys.dataBox),
    ]);

    _log.info('Hive storage initialized');
  }

  Future<void> _openBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<dynamic>(name);
    }
  }

  Box<dynamic> _box(String boxName) => Hive.box<dynamic>(boxName);

  @override
  Future<void> put(String boxName, String key, dynamic value) async {
    await _box(boxName).put(key, value);
  }

  @override
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    return _box(boxName).get(key, defaultValue: defaultValue) as T?;
  }

  @override
  Future<void> clearBox(String boxName) async {
    await _box(boxName).clear();
    _log.debug('Cleared box: $boxName');
  }
}
