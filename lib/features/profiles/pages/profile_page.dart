import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/app_routing.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/radar/radar_widgets.dart';

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
          const SnackBar(
            content: Text('Nie udało się wylogować. Spróbuj ponownie.'),
          ),
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

        final profile = state.profile;
        final email = state.user.email;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        return RadarList(
          children: [
            const RadarHeading('Twój profil'),
            RadarPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    child: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (email != null && email.isNotEmpty) Text(email),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    Text(profile.bio),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            RadarPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: const Text('Edytuj profil'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _signingOut
                        ? null
                        : () => context.pushNamed<void>(
                            AppRoute.editProfile.name,
                          ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: const Text('Edytuj zainteresowania'),
                    subtitle: Text(
                      'Wybrane dziedziny: ${profile.selectedCategoryIds.length}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _signingOut
                        ? null
                        : () => context.pushNamed<void>(
                            AppRoute.editCategories.name,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _signingOut ? null : _signOut,
              icon: const Icon(Icons.logout),
              label: Text(_signingOut ? 'Wylogowywanie…' : 'Wyloguj się'),
            ),
          ],
        );
      },
    );
  }
}
