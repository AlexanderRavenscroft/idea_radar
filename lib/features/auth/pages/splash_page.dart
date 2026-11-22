import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/theme/app_spacing.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);

    try {
      await context.read<SessionCubit>().signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nie udało się wylogować. Spróbuj ponownie.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              final message = switch (state) {
                SessionAuthFailure() => 'Nie udało się sprawdzić sesji.',
                SessionProfileFailure(:final message) => message,
                _ => null,
              };
              if (message == null) {
                return const CircularProgressIndicator(
                  semanticsLabel: 'Sprawdzanie sesji',
                );
              }

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: _signingOut
                          ? null
                          : context.read<SessionCubit>().retry,
                      child: const Text('Spróbuj ponownie'),
                    ),
                    if (state is SessionProfileFailure)
                      TextButton(
                        onPressed: _signingOut ? null : _signOut,
                        child: Text(
                          _signingOut ? 'Wylogowywanie…' : 'Wyloguj się',
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
