/// Wraps the raw map a [GraphQLJsonExecutor] operation returns, so callers
/// extract fields through typed accessors instead of repeating
/// `data['key']` string-indexing (and re-deriving the connection shape) at
/// every call site.
class GraphQLResponse {
  const GraphQLResponse(this._data);

  final Map<String, dynamic> _data;

  /// Returns the object nested under [key], or null if absent.
  Map<String, dynamic>? object(String key) => _data[key] as Map<String, dynamic>?;

  /// Returns the paginated item list nested under connection [key]
  /// (e.g. `{'children': {'data': [...], 'meta': {...}}}`), or null if the
  /// connection or its `data` field is missing.
  List<Map<String, dynamic>>? connectionItems(String key) {
    final items = object(key)?['data'] as List<dynamic>?;
    return items?.cast<Map<String, dynamic>>();
  }

  /// Returns `meta.totalCount` nested under connection [key], defaulting to 0.
  int connectionTotalCount(String key) {
    final meta = object(key)?['meta'] as Map<String, dynamic>?;
    return meta?['totalCount'] as int? ?? 0;
  }
}
