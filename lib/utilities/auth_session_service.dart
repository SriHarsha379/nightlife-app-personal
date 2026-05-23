import 'package:firebase_auth/firebase_auth.dart';

class SessionExpiredAuthException implements Exception {
  final String code;
  SessionExpiredAuthException(this.code);
}

abstract class AuthSessionService {
  bool get isSignedIn;
  Stream<bool> authStateChanges();
  Future<String?> getFreshIdToken({bool forceRefresh = true});
  Future<void> signOut();
}

class FirebaseAuthSessionService implements AuthSessionService {
  final FirebaseAuth _auth;

  FirebaseAuthSessionService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Stream<bool> authStateChanges() {
    return _auth.authStateChanges().map((user) => user != null);
  }

  @override
  Future<String?> getFreshIdToken({bool forceRefresh = true}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken(forceRefresh);
    } on FirebaseAuthException catch (e) {
      if (_isExpiryOrRevocationCode(e.code)) {
        throw SessionExpiredAuthException(e.code);
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  bool _isExpiryOrRevocationCode(String code) {
    const revokedCodes = <String>{
      'user-token-expired',
      'invalid-user-token',
      'user-disabled',
      'user-not-found',
      'requires-recent-login',
      'session-cookie-revoked',
      'credential-too-old-login-again',
      'id-token-revoked',
    };
    return revokedCodes.contains(code);
  }
}
