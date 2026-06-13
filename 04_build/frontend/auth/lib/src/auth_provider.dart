import 'package:caliber_shared/caliber_shared.dart';

abstract interface class AuthProvider {
  Stream<ProfileIdentity?> get currentUser;

  Future<ProfileIdentity?> get currentProfile;

  Future<ProfileIdentity> signInAnonymously();

  Future<ProfileIdentity> signInWithApple();

  Future<void> signOut();
}

final class AppleSignInUnavailableException implements Exception {
  const AppleSignInUnavailableException(this.message);

  final String message;

  @override
  String toString() => 'AppleSignInUnavailableException: $message';
}

final class AppleSignInNotImplementedException implements Exception {
  const AppleSignInNotImplementedException();

  @override
  String toString() {
    return 'AppleSignInNotImplementedException: Apple Sign In is interface-only for v1.';
  }
}
