import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/profiles/widgets/profile_setup_step_indicator.dart';
import 'package:idea_radar/theme/app_spacing.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionCubit>().state;
    if (session is SessionSettingName) {
      _fullNameController.text = session.fullName;
      _bioController.text = session.bio;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_signingOut || !_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    context.read<SessionCubit>().setProfileDetails(
      fullName: _fullNameController.text.trim(),
      bio: _bioController.text.trim(),
    );
  }

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
    return PopScope<Object?>(
      canPop: !_signingOut,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Utwórz profil'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const ProfileSetupStepIndicator(step: 1),
              Expanded(child: _profileForm()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fullNameController,
              enabled: !_signingOut,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Imię i nazwisko'),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Wpisz imię i nazwisko.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _bioController,
              enabled: !_signingOut,
              decoration: const InputDecoration(
                labelText: 'O Tobie (opcjonalnie)',
                hintText: 'Napisz, czym się zajmujesz',
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _signingOut ? null : _continue,
              child: const Text('Dalej'),
            ),
            TextButton(
              onPressed: _signingOut ? null : _signOut,
              child: const Text('Wyloguj się'),
            ),
          ],
        ),
      ),
    );
  }
}
