import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:idea_radar/features/auth/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepository {
  final _auth = supabase.Supabase.instance.client.auth;
  final _google = GoogleSignIn.instance;

  late final Future<void> _googleInitialization = _google.initialize(
    clientId: dotenv.maybeGet('GOOGLE_IOS_CLIENT_ID'),
    serverClientId: dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID'),
  );

  AuthUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : AuthUser(id: user.id, email: user.email);
  }

  Stream<AuthUser?> watchUser() {
    return _auth.onAuthStateChange.map((_) => currentUser).distinct((
      previous,
      next,
    ) {
      return previous?.id == next?.id && previous?.email == next?.email;
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleInitialization;

      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw StateError('Google did not return an ID token.');
      }

      await _auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return;
      }
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();
}
