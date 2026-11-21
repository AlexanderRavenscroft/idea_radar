import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/features/auth/auth_repository.dart';
import 'package:idea_radar/features/auth/auth_user.dart';
import 'package:idea_radar/features/profiles/profile_repository.dart';
import 'package:idea_radar/features/profiles/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  late final StreamSubscription<AuthUser?> _authSubscription;
  AuthUser? _user;

  SessionCubit({
    required this._authRepository,
    required this._profileRepository,
  }) : super(const SessionChecking()) {
    _authSubscription = _authRepository.watchUser().listen(
      (user) => unawaited(_loadSession(user)),
      onError: _onAuthError,
    );
  }

  Future<void> retry() => _loadSession(_authRepository.currentUser);

  Future<void> signOut() => _authRepository.signOut();

  Future<void> saveProfile(String bio) async {
    final setup = state;
    if (isClosed || setup is! SessionProfileSetupRequired) return;

    final user = setup.user;
    final profile = await _profileRepository.saveBio(user.id, bio);

    if (isClosed || !identical(state, setup)) return;

    emit(SessionAuthenticated(user: user, profile: profile));
  }

  Future<void> _loadSession(AuthUser? user) async {
    if (isClosed) return;

    _user = user;
    if (user == null) {
      emit(const SessionUnauthenticated());
      return;
    }

    emit(const SessionChecking());

    final UserProfile? profile;
    try {
      profile = await _profileRepository.getProfile(user.id);
    } catch (error) {
      if (isClosed || !identical(_user, user)) return;

      const message = 'Could not load your profile.';
      final errorCode = error is PostgrestException
          ? error.code ?? 'PostgrestException'
          : error.runtimeType.toString();
      emit(
        SessionProfileFailure(
          message: kDebugMode ? '$message ($errorCode)' : message,
        ),
      );
      return;
    }

    if (isClosed || !identical(_user, user)) return;

    emit(
      profile == null || profile.bio.isEmpty
          ? SessionProfileSetupRequired(user: user)
          : SessionAuthenticated(user: user, profile: profile),
    );
  }

  void _onAuthError(Object error, StackTrace stackTrace) {
    if (isClosed || _authRepository.currentUser != null) return;

    _user = null;
    emit(const SessionAuthFailure());
  }

  @override
  Future<void> close() async {
    _user = null;
    await _authSubscription.cancel();
    await super.close();
  }
}
