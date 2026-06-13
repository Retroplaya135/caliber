import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:caliber_shared/caliber_shared.dart';
import 'package:flutter/foundation.dart';

import 'auth_provider.dart';
import 'auth_storage.dart';

typedef CaliberUuidFactory = String Function();
typedef CaliberNowFactory = DateTime Function();

final class LocalAnonymousAuthProvider implements AuthProvider {
  LocalAnonymousAuthProvider({
    AuthSecureStore store = const FlutterAuthSecureStore(),
    CaliberUuidFactory uuidFactory = _uuidV4,
    CaliberNowFactory nowFactory = DateTime.now,
    TargetPlatform? platform,
  }) : this._(store, uuidFactory, nowFactory, platform);

  LocalAnonymousAuthProvider._(
    this._store,
    this._uuidFactory,
    this._nowFactory,
    this._platform,
  );

  static const profileStorageKey = 'caliber.auth.profile_identity.v1';

  final AuthSecureStore _store;
  final CaliberUuidFactory _uuidFactory;
  final CaliberNowFactory _nowFactory;
  final TargetPlatform? _platform;

  final StreamController<ProfileIdentity?> _changes =
      StreamController<ProfileIdentity?>.broadcast();

  ProfileIdentity? _cachedProfile;
  Future<ProfileIdentity?>? _restoreOperation;

  @override
  Stream<ProfileIdentity?> get currentUser {
    return Stream<ProfileIdentity?>.multi((controller) {
      var active = true;
      final subscription = _changes.stream.listen(
        controller.add,
        onError: controller.addError,
      );

      currentProfile.then(
        (profile) {
          if (!active) return;
          controller.add(_cachedProfile ?? profile);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!active) return;
          controller.addError(error, stackTrace);
        },
      );

      controller.onCancel = () async {
        active = false;
        await subscription.cancel();
      };
    });
  }

  @override
  Future<ProfileIdentity?> get currentProfile {
    final cachedProfile = _cachedProfile;
    if (cachedProfile != null) {
      return Future.value(cachedProfile);
    }
    return _restoreOperation ??= _restoreProfile();
  }

  @override
  Future<ProfileIdentity> signInAnonymously() async {
    final existingProfile = await currentProfile;
    if (existingProfile != null) {
      return existingProfile;
    }

    final now = _nowFactory().toUtc();
    final id = _uuidFactory();
    final profile = ProfileIdentity(
      profileId: id,
      ownerUserId: 'anonymous:$id',
      displayName: 'Anonymous Candidate',
      primaryDomain: 'local',
      targetLevelBand: 'unspecified',
      locale: 'en-US',
      createdAt: now,
      updatedAt: now,
      metadata: const <String, Object?>{
        'auth_provider': 'anonymous',
        'storage': 'local_secure_storage',
      },
    );

    await _store.write(
      key: profileStorageKey,
      value: jsonEncode(profile.toJson()),
    );
    _cachedProfile = profile;
    _restoreOperation = Future.value(profile);
    _changes.add(profile);
    return profile;
  }

  @override
  Future<ProfileIdentity> signInWithApple() async {
    final platform = _platform ?? defaultTargetPlatform;
    if (kIsWeb ||
        (platform != TargetPlatform.iOS && platform != TargetPlatform.macOS)) {
      throw const AppleSignInUnavailableException(
        'Apple Sign In is only available on iOS and macOS.',
      );
    }
    throw const AppleSignInNotImplementedException();
  }

  @override
  Future<void> signOut() async {
    await _store.delete(key: profileStorageKey);
    _cachedProfile = null;
    _restoreOperation = Future<ProfileIdentity?>.value();
    _changes.add(null);
  }

  Future<ProfileIdentity?> _restoreProfile() async {
    final rawProfile = await _store.read(key: profileStorageKey);
    if (rawProfile == null || rawProfile.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(rawProfile);
    if (decoded is! Map) {
      await _store.delete(key: profileStorageKey);
      return null;
    }
    final profile = ProfileIdentity.fromJson(
      Map<String, Object?>.from(decoded),
    );
    _cachedProfile = profile;
    return profile;
  }

  void dispose() {
    unawaited(_changes.close());
  }
}

String _uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String two(int value) => value.toRadixString(16).padLeft(2, '0');

  return [for (final byte in bytes) two(byte)].join().replaceFirstMapped(
    RegExp(r'^(.{8})(.{4})(.{4})(.{4})(.{12})$'),
    (match) {
      return '${match[1]}-${match[2]}-${match[3]}-${match[4]}-${match[5]}';
    },
  );
}
