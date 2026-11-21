import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/profiles/widgets/profile_setup_step_indicator.dart';

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
          const SnackBar(content: Text('Could not sign out. Try again.')),
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
          title: const Text('Create Profile'),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fullNameController,
              enabled: !_signingOut,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter your full name.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              enabled: !_signingOut,
              decoration: const InputDecoration(
                labelText: 'Bio (optional)',
                hintText: 'Tell us a little about yourself',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _signingOut ? null : _continue,
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: _signingOut ? null : _signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
