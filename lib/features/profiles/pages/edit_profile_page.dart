import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/theme/app_spacing.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionCubit>().state;
    if (session is SessionAuthenticated) {
      _fullNameController.text = session.profile.fullName;
      _bioController.text = session.profile.bio;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);

    try {
      final saved = await context.read<SessionCubit>().updateProfile(
        fullName: _fullNameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (saved && mounted && ModalRoute.of(context)?.isCurrent == true) {
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nie udało się zapisać profilu. Spróbuj ponownie.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edytuj profil')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                TextFormField(
                  controller: _fullNameController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Imię i nazwisko',
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Wpisz imię i nazwisko.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _bioController,
                  enabled: !_saving,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'O Tobie (opcjonalnie)',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Zapisywanie…' : 'Zapisz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
