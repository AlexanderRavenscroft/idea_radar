import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/profiles/profile_category.dart';
import 'package:idea_radar/features/profiles/profile_repository.dart';
import 'package:idea_radar/features/profiles/widgets/category_chip.dart';
import 'package:idea_radar/features/profiles/widgets/profile_setup_step_indicator.dart';
import 'package:idea_radar/theme/app_spacing.dart';

class ChooseCategoriesPage extends StatefulWidget {
  const ChooseCategoriesPage({super.key});

  @override
  State<ChooseCategoriesPage> createState() => _ChooseCategoriesPageState();
}

class _ChooseCategoriesPageState extends State<ChooseCategoriesPage> {
  final _selectedCategoryIds = <int>{};
  Future<List<ProfileCategory>>? _categories;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionCubit>().state;
    if (session is SessionSettingCategories) {
      _selectedCategoryIds.addAll(session.selectedCategoryIds);
    }
  }

  void _back() {
    if (_saving) return;
    context.read<SessionCubit>().editProfileDetails(_selectedCategoryIds);
  }

  void _selectCategory(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategoryIds.add(id);
      } else {
        _selectedCategoryIds.remove(id);
      }
    });
  }

  Future<void> _save(List<int> categoryIds) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await context.read<SessionCubit>().saveProfile(categoryIds);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
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
    final categories = _categories ??= context
        .read<ProfileRepository>()
        .getCategories();

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Wróć',
            onPressed: _saving ? null : _back,
            icon: const BackButtonIcon(),
          ),
          title: const Text('Wybierz dziedziny'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const ProfileSetupStepIndicator(step: 2),
              Expanded(
                child: FutureBuilder<List<ProfileCategory>>(
                  future: categories,
                  builder: _buildCategories,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(
    BuildContext context,
    AsyncSnapshot<List<ProfileCategory>> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories = snapshot.data;
    if (categories == null || categories.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            snapshot.hasError
                ? 'Nie udało się wczytać dziedzin.'
                : 'Brak dostępnych dziedzin.',
          ),
          TextButton(
            onPressed: () => setState(() => _categories = null),
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      );
    }

    final categoryIds = [
      for (final category in categories)
        if (_selectedCategoryIds.contains(category.id)) category.id,
    ]..sort();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const Text(
          'Wybierz co najmniej jedną dziedzinę, która Cię interesuje.',
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in categories)
              CategoryChip(
                label: category.name,
                selected: _selectedCategoryIds.contains(category.id),
                onSelected: _saving
                    ? null
                    : (selected) => _selectCategory(category.id, selected),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _saving || categoryIds.isEmpty
              ? null
              : () => _save(categoryIds),
          child: Text(_saving ? 'Zapisywanie…' : 'Zapisz i przejdź do radaru'),
        ),
      ],
    );
  }
}
