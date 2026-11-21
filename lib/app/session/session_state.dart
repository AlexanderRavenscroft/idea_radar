part of 'session_cubit.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionChecking extends SessionState {
  const SessionChecking();
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionProfileSetupRequired extends SessionState {
  final AuthUser user;

  const SessionProfileSetupRequired({required this.user});
}

final class SessionAuthenticated extends SessionState {
  final AuthUser user;
  final UserProfile profile;

  const SessionAuthenticated({required this.user, required this.profile});
}

final class SessionAuthFailure extends SessionState {
  const SessionAuthFailure();
}

final class SessionProfileFailure extends SessionState {
  final String message;

  const SessionProfileFailure({required this.message});
}
