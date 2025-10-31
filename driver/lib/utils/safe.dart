/// Safe type casting utilities to handle null and unexpected types from API responses
/// These helpers prevent "type 'Null' is not a subtype of type 'X'" runtime errors

/// Generic safe cast - returns null if type doesn't match
T? asT<T>(dynamic v) => v is T ? v : null;

/// Safe String extraction with default value
String s(dynamic v, {String def = ''}) => v is String ? v : def;

/// Safe number extraction with default value
num n(dynamic v, {num def = 0}) => v is num ? v : def;

/// Safe List extraction - returns empty list if not a List
List<dynamic> l(dynamic v) => (v is List) ? v : <dynamic>[];

/// Safe Map extraction - returns empty map if not a Map
Map<String, dynamic> m(dynamic v) =>
    (v is Map<String, dynamic>) ? v : <String, dynamic>{};
