import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    final session = context.read<SessionCubit>();
    await _run(
      () => session.saveProfile(_bioController.text.trim()),
      'Could not save your profile. Try again.',
    );
  }

  Future<void> _run(Future<void> Function() action, String errorMessage) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _bioController,
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us a little about yourself',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Enter a short bio.' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: const Text('Save and continue'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _run(
                        context.read<SessionCubit>().signOut,
                        'Could not sign out. Try again.',
                      ),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
