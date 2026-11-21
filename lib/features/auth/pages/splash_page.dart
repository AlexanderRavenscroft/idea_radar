import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              if (state is! SessionAuthFailure) {
                return const CircularProgressIndicator(
                  semanticsLabel: 'Checking your session',
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not check your session.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: context.read<SessionCubit>().retry,
                      child: const Text('Try again'),
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
