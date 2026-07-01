import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:kincare/app/constants/hive_keys.dart';
import 'package:kincare/core/api/graphql_queries.dart';
import 'package:kincare/core/storage/hive_storage.dart';

/// Executes the app's GraphQL documents against JSON data.
///
/// **Persistence strategy:**
/// - On first launch (or after clearing data), each dataset is seeded from
///   the read-only asset bundle and immediately saved to Hive.
/// - On subsequent launches, data is loaded from Hive so that every add,
///   edit, or delete the user performed in previous sessions is still there.
/// - After every mutation (create / update / delete), the affected list is
///   written back to Hive before the response is returned to the caller.
///
/// Document strings from [GraphQLQueries] act as routing keys — no real
/// GraphQL parsing happens; they just identify which operation to run.
class GraphQLJsonExecutor {
  GraphQLJsonExecutor._();

  static final GraphQLJsonExecutor instance = GraphQLJsonExecutor._();

  List<Map<String, dynamic>>? _children;
  List<Map<String, dynamic>>? _medications;
  Map<String, dynamic>? _profile;

  // Convenience accessor — storage is registered permanently in main() before
  // any route (and therefore before any executor call) is ever made.
  LocalStorage get _storage => Get.find<LocalStorage>();

  // ── Load helpers ────────────────────────────────────────────────────────────

  Future<void> _ensureLoaded() async {
    if (_children != null && _medications != null && _profile != null) return;
    _medications =
        await _loadOrSeed(
              HiveKeys.cachedMedications,
              'assets/data/medications.json',
              isList: true,
            )
            as List<Map<String, dynamic>>;
    _children =
        await _loadOrSeed(
              HiveKeys.cachedChildren,
              'assets/data/children.json',
              isList: true,
            )
            as List<Map<String, dynamic>>;
    _profile =
        await _loadOrSeed(
              HiveKeys.cachedProfile,
              'assets/data/profile.json',
              isList: false,
            )
            as Map<String, dynamic>;
  }

  /// Loads [key] from Hive if present; otherwise reads [assetPath] from the
  /// bundle, saves it to Hive, and returns it. This "seed on first use"
  /// pattern means the writable Hive copy is always the source of truth.
  Future<Object> _loadOrSeed(
    String key,
    String assetPath, {
    required bool isList,
  }) async {
    final stored = _storage.get<String>(HiveKeys.dataBox, key);
    if (stored != null) {
      return isList ? _decodeList(stored) : _decodeMap(stored);
    }
    final raw = await rootBundle.loadString(assetPath);
    await _storage.put(HiveKeys.dataBox, key, raw);
    return isList ? _decodeList(raw) : _decodeMap(raw);
  }

  List<Map<String, dynamic>> _decodeList(String json) {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
        .toList();
  }

  Map<String, dynamic> _decodeMap(String json) {
    return Map<String, dynamic>.from(jsonDecode(json) as Map<dynamic, dynamic>);
  }

  // ── Save helpers ─────────────────────────────────────────────────────────────

  Future<void> _saveMedications() async => _storage.put(
    HiveKeys.dataBox,
    HiveKeys.cachedMedications,
    jsonEncode(_medications),
  );

  Future<void> _saveChildren() async => _storage.put(
    HiveKeys.dataBox,
    HiveKeys.cachedChildren,
    jsonEncode(_children),
  );

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Executes [document] with [variables] and returns a GraphQL-shaped
  /// response map (e.g. `{'medications': {...}}`).
  Future<Map<String, dynamic>> execute(
    String document,
    Map<String, dynamic> variables,
  ) async {
    await _ensureLoaded();

    // ── Profile ──────────────────────────────────────────────────────────────
    if (document == GraphQLQueries.getUser) {
      return {'user': _matchesId(_profile!, variables['id']) ? _profile : null};
    }

    // ── Children ─────────────────────────────────────────────────────────────
    if (document == GraphQLQueries.getChildren) {
      return {'children': _paginate(_children!, variables)};
    }
    if (document == GraphQLQueries.getChild) {
      return {'child': _findById(_children!, variables['id'])};
    }
    if (document == GraphQLQueries.createChild) {
      final created = _create(_children!, variables);
      await _saveChildren();
      return {'createChild': created};
    }
    if (document == GraphQLQueries.updateChild) {
      final updated = _update(_children!, variables);
      await _saveChildren();
      return {'updateChild': updated};
    }
    if (document == GraphQLQueries.deleteChild) {
      final result = _delete(_children!, variables['id']);
      await _saveChildren();
      return {'deleteChild': result};
    }

    // ── Medications ───────────────────────────────────────────────────────────
    if (document == GraphQLQueries.getMedications) {
      return {'medications': _paginate(_medications!, variables)};
    }
    if (document == GraphQLQueries.createMedication) {
      final created = _create(_medications!, variables);
      await _saveMedications();
      return {'createMedication': created};
    }
    if (document == GraphQLQueries.updateMedication) {
      final updated = _update(_medications!, variables);
      await _saveMedications();
      return {'updateMedication': updated};
    }
    if (document == GraphQLQueries.deleteMedication) {
      final result = _delete(_medications!, variables['id']);
      await _saveMedications();
      return {'deleteMedication': result};
    }

    throw UnsupportedError('Unknown GraphQL document: $document');
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  bool _matchesId(Map<String, dynamic> record, dynamic id) {
    return id == null || record['id'].toString() == id.toString();
  }

  Map<String, dynamic>? _findById(
    List<Map<String, dynamic>> store,
    dynamic id,
  ) {
    for (final record in store) {
      if (record['id'].toString() == id.toString()) return record;
    }
    return null;
  }

  Map<String, dynamic> _paginate(
    List<Map<String, dynamic>> store,
    Map<String, dynamic> variables,
  ) {
    final options = variables['options'] as Map<String, dynamic>?;
    final paginate = options?['paginate'] as Map<String, dynamic>?;
    final page = (paginate?['page'] as int?) ?? 1;
    final limit = (paginate?['limit'] as int?) ?? store.length;

    final start = ((page - 1) * limit).clamp(0, store.length);
    final end = (start + limit).clamp(0, store.length);

    return {
      'data': store.sublist(start, end),
      'meta': {'totalCount': store.length},
    };
  }

  Map<String, dynamic> _inputOf(Map<String, dynamic> variables) {
    return Map<String, dynamic>.from(
      variables['input'] as Map<String, dynamic>? ?? const {},
    )..removeWhere((key, value) => value == null);
  }

  Map<String, dynamic> _create(
    List<Map<String, dynamic>> store,
    Map<String, dynamic> variables,
  ) {
    final nextId =
        (store.fold<int>(
                  0,
                  (max, e) => int.tryParse(e['id'].toString()) ?? max,
                ) +
                1)
            .toString();

    final record = {'id': nextId, ..._inputOf(variables)};
    store.add(record);
    return record;
  }

  Map<String, dynamic>? _update(
    List<Map<String, dynamic>> store,
    Map<String, dynamic> variables,
  ) {
    final record = _findById(store, variables['id']);
    if (record == null) return null;
    record.addAll(_inputOf(variables));
    return record;
  }

  bool _delete(List<Map<String, dynamic>> store, dynamic id) {
    final record = _findById(store, id);
    if (record == null) return false;
    store.remove(record);
    return true;
  }
}
