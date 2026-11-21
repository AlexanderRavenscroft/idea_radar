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

final class SessionSettingName extends SessionState {
  final AuthUser user;
  final String fullName;
  final String bio;
  final Set<int> selectedCategoryIds;

  const SessionSettingName({
    required this.user,
    this.fullName = '',
    required this.bio,
    this.selectedCategoryIds = const {},
  });
}

final class SessionSettingCategories extends SessionState {
  final AuthUser user;
  final String fullName;
  final String bio;
  final Set<int> selectedCategoryIds;

  const SessionSettingCategories({
    required this.user,
    required this.fullName,
    required this.bio,
    required this.selectedCategoryIds,
  });
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
