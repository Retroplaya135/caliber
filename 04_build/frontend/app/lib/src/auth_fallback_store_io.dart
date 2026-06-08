import 'dart:convert';
import 'dart:io';

import 'package:caliber_auth/auth.dart';
import 'package:flutter/services.dart';

AuthSecureStore buildAuthFallbackStore() {
  return _FileAuthSecureStore(_defaultAuthFallbackFile());
}

bool isMissingMacOsKeychainEntitlement(PlatformException error) {
  return Platform.isMacOS &&
      (error.details == -34018 ||
          error.details == -60006 ||
          error.details == -60008 ||
          error.message?.contains('-34018') == true ||
          error.message?.contains('-60006') == true ||
          error.message?.contains('-60008') == true ||
          error.message?.contains("entitlement isn't present") == true);
}

final class _FileAuthSecureStore implements AuthSecureStore {
  const _FileAuthSecureStore(this.file);

  final File file;

  @override
  Future<String?> read({required String key}) async {
    final values = await _readValues();
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final values = await _readValues();
    values[key] = value;
    await _writeValues(values);
  }

  @override
  Future<void> delete({required String key}) async {
    final values = await _readValues();
    values.remove(key);
    await _writeValues(values);
  }

  Future<Map<String, String>> _readValues() async {
    if (!await file.exists()) {
      return <String, String>{};
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, Object?>) {
      return <String, String>{};
    }
    return decoded.map(
      (key, value) => MapEntry(key, value is String ? value : '$value'),
    );
  }

  Future<void> _writeValues(Map<String, String> values) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(values));
  }
}

File _defaultAuthFallbackFile() {
  final home = Platform.environment['HOME'];
  final basePath = home == null || home.isEmpty
      ? Directory.systemTemp.path
      : '$home/Library/Application Support';
  return File('$basePath/Caliber/auth_store.json');
}
