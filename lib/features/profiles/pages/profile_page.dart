import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/theme/app_spacing.dart';

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
        if (state is! SessionAuthenticated) return const SizedBox.shrink();

        final email = state.user.email;
        final fullName = state.profile.fullName;
        final bio = state.profile.bio;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                fullName.isEmpty ? 'Profile' : fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (email != null && email.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(email),
              ],
              if (bio.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(bio),
              ],
              const SizedBox(height: AppSpacing.lg),
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
