import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/session/session_cubit.dart';
import 'package:idea_radar/features/profiles/profile_category.dart';
import 'package:idea_radar/features/profiles/profile_repository.dart';
import 'package:idea_radar/features/profiles/widgets/category_chip.dart';
import 'package:idea_radar/theme/app_spacing.dart';

class EditCategoriesPage extends StatefulWidget {
  const EditCategoriesPage({super.key});

  @override
  State<EditCategoriesPage> createState() => _EditCategoriesPageState();
}

class _EditCategoriesPageState extends State<EditCategoriesPage> {
  final _selectedCategoryIds = <int>{};
  late Future<List<ProfileCategory>> _categories;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionCubit>().state;
    if (session is SessionAuthenticated) {
      _selectedCategoryIds.addAll(session.profile.selectedCategoryIds);
    }
    _categories = context.read<ProfileRepository>().getCategories();
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
      final saved = await context.read<SessionCubit>().updateProfile(
        categoryIds: categoryIds,
      );
      if (saved && mounted && ModalRoute.of(context)?.isCurrent == true) {
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nie udało się zapisać zainteresowań. Spróbuj ponownie.',
            ),
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
        appBar: AppBar(title: const Text('Edytuj zainteresowania')),
        body: SafeArea(
          child: FutureBuilder<List<ProfileCategory>>(
            future: _categories,
            builder: _buildCategories,
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
            onPressed: () {
              setState(() {
                _categories = context.read<ProfileRepository>().getCategories();
              });
            },
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
        const Text('Wybierz co najmniej jedną dziedzinę.'),
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
          child: Text(_saving ? 'Zapisywanie…' : 'Zapisz'),
        ),
      ],
    );
  }
}
