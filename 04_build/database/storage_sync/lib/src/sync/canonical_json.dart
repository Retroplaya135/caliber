import 'dart:collection';
import 'dart:convert';

final class CanonicalJson {
  const CanonicalJson._();

  static String encode(Object? value) {
    return jsonEncode(_normalize(value));
  }

  static Object? _normalize(Object? value) {
    if (value is Map) {
      final sorted = SplayTreeMap<String, Object?>();
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String) {
          throw ArgumentError.value(
            key,
            'key',
            'canonical JSON keys must be strings',
          );
        }
        sorted[key] = _normalize(entry.value);
      }
      return sorted;
    }

    if (value is Iterable) {
      return value.map(_normalize).toList(growable: false);
    }

    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }

    return value;
  }
}
