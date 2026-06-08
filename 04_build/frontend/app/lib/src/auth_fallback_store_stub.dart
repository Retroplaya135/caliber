import 'package:caliber_auth/auth.dart';
import 'package:flutter/services.dart';

AuthSecureStore buildAuthFallbackStore() {
  return _MemoryAuthSecureStore();
}

bool isMissingMacOsKeychainEntitlement(PlatformException error) => false;

final class _MemoryAuthSecureStore implements AuthSecureStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }
}
