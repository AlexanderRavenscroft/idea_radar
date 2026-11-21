import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/features/auth/auth_repository.dart';
import 'package:idea_radar/features/auth/cubits/login/login_cubit.dart';
import 'package:idea_radar/theme/app_sizes.dart';
import 'package:idea_radar/theme/app_spacing.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginCubit(authRepository: context.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final signingIn = state is LoginSubmitting;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.loginButtonMaxWidth,
                  ),
                  child: OutlinedButton(
                    onPressed: signingIn
                        ? null
                        : context.read<LoginCubit>().signInWithGoogle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: AppSizes.icon,
                          child: signingIn
                              ? const Padding(
                                  padding: EdgeInsets.all(AppSpacing.xs),
                                  child: CircularProgressIndicator(
                                    strokeWidth:
                                        AppSizes.loginProgressStrokeWidth,
                                    semanticsLabel: 'Signing in',
                                  ),
                                )
                              : Image.asset('assets/icons/google.png'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Flexible(
                          child: Text(
                            'Continue with Google',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
