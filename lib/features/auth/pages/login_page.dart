import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/features/auth/auth_repository.dart';
import 'package:idea_radar/features/auth/cubits/login/login_cubit.dart';
import 'package:idea_radar/features/radar/radar_widgets.dart';
import 'package:idea_radar/theme/app_radius.dart';
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
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Scaffold(
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xxxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: SizedBox.square(
                              dimension: 185,
                              child: RadarArtwork(
                                color: colors.primary,
                                compact: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  'Radar Innowacji',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Odkrywaj pomysły z instytucji publicznych i skontaktuj się z ich autorami.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        _GoogleSignInButton(
                          signingIn: signingIn,
                          onPressed: signingIn
                              ? null
                              : context.read<LoginCubit>().signInWithGoogle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool signingIn;
  final VoidCallback? onPressed;

  const _GoogleSignInButton({required this.signingIn, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.surfaceContainer,
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outline),
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: AppSizes.icon,
            child: signingIn
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    child: CircularProgressIndicator(
                      strokeWidth: AppSizes.loginProgressStrokeWidth,
                      semanticsLabel: 'Logowanie',
                    ),
                  )
                : Image.asset('assets/icons/google.png'),
          ),
          const SizedBox(width: AppSpacing.md),
          const Flexible(
            child: Text('Kontynuuj z Google', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
