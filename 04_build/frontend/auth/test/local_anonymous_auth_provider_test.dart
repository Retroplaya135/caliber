import 'dart:async';

import 'package:caliber_auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anonymous auth creates valid ProfileIdentity and stores it', () async {
    final store = _MemoryAuthSecureStore();
    final provider = LocalAnonymousAuthProvider(
      store: store,
      uuidFactory: () => '123e4567-e89b-42d3-a456-426614174000',
      nowFactory: () => DateTime.utc(2026, 5, 31, 20),
    );

    final profile = await provider.signInAnonymously();

    expect(profile.profileId, '123e4567-e89b-42d3-a456-426614174000');
    expect(profile.ownerUserId, 'anonymous:${profile.profileId}');
    expect(profile.schemaVersion, 'profile_identity.v1');
    expect(profile.metadata['auth_provider'], 'anonymous');
    expect(
      store.values[LocalAnonymousAuthProvider.profileStorageKey],
      contains(profile.profileId),
    );
  });

  test('anonymous auth reuses an existing stored ProfileIdentity', () async {
    final store = _MemoryAuthSecureStore();
    final provider = LocalAnonymousAuthProvider(
      store: store,
      uuidFactory: () => '123e4567-e89b-42d3-a456-426614174000',
      nowFactory: () => DateTime.utc(2026, 5, 31, 20),
    );

    final first = await provider.signInAnonymously();
    final second = await provider.signInAnonymously();

    expect(second, first);
  });

  test('currentUser does not miss a fast anonymous sign-in', () async {
    final store = _DelayedReadAuthSecureStore();
    final provider = LocalAnonymousAuthProvider(
      store: store,
      uuidFactory: () => '123e4567-e89b-42d3-a456-426614174000',
      nowFactory: () => DateTime.utc(2026, 5, 31, 20),
    );
    final events = <Object?>[];
    final subscription = provider.currentUser.listen(events.add);
    addTearDown(subscription.cancel);

    final signIn = provider.signInAnonymously();
    store.completeRead(null);
    final profile = await signIn;
    await Future<void>.delayed(Duration.zero);

    expect(events, contains(profile));
  });

  test(
    'Apple Sign In is platform checked and not implemented for v1',
    () async {
      final provider = LocalAnonymousAuthProvider(
        store: _MemoryAuthSecureStore(),
        platform: TargetPlatform.iOS,
      );

      expect(
        provider.signInWithApple,
        throwsA(isA<AppleSignInNotImplementedException>()),
      );
    },
  );
}

final class _MemoryAuthSecureStore implements AuthSecureStore {
  final values = <String, String>{};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

final class _DelayedReadAuthSecureStore extends _MemoryAuthSecureStore {
  final Completer<String?> _read = Completer<String?>();

  void completeRead(String? value) {
    if (!_read.isCompleted) {
      _read.complete(value);
    }
  }

  @override
  Future<String?> read({required String key}) {
    return _read.future;
  }
}
