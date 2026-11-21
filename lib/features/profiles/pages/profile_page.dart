import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;

    setState(() {
      _signingOut = true;
    });

    try {
      await context.read<SessionCubit>().signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not sign out. Try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _signingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final (user, fullName, error) = switch (state) {
          SessionAuthenticated(:final user, :final profile) => (
            user,
            profile.fullName,
            null,
          ),
          SessionProfileFailure(:final user, :final message) => (
            user,
            '',
            message,
          ),
          _ => (null, '', null),
        };

        if (user == null) return const SizedBox.shrink();

        final email = user.email;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                fullName.isEmpty ? 'Profile' : fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (email != null && email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(email),
              ],
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(error),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _signingOut
                        ? null
                        : context.read<SessionCubit>().retry,
                    child: const Text('Try again'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(
                  onPressed: _signingOut ? null : _signOut,
                  child: Text(_signingOut ? 'Signing out…' : 'Sign out'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
