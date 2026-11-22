import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/features/auth/auth_repository.dart';
import 'package:idea_radar/utils/app_logger.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required this._authRepository}) : super(const LoginInitial());

  Future<void> signInWithGoogle() async {
    if (state is LoginSubmitting) return;

    emit(const LoginSubmitting());

    try {
      await _authRepository.signInWithGoogle();
      if (!isClosed) emit(const LoginInitial());
    } catch (error, stack) {
      logFailure('auth.google', error, stack);
      if (!isClosed) {
        emit(
          const LoginFailure(
            'Nie udało się zalogować przez Google. Spróbuj ponownie.',
          ),
        );
      }
    }
  }
}
