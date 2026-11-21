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

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated({required this.user, required this.profile});

  final AuthUser user;
  final UserProfile profile;
}

final class SessionAuthFailure extends SessionState {
  const SessionAuthFailure();
}

final class SessionProfileFailure extends SessionState {
  const SessionProfileFailure({required this.user, required this.message});

  final AuthUser user;
  final String message;
}
