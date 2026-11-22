import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show TickerCanceled;
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'idea_detail.dart';
import 'radar_controller.dart';
import 'radar_matching.dart';
import 'radar_models.dart';
import 'radar_scope.dart';
import 'radar_widgets.dart';

typedef _Filters = ({int? category, IdeaStage? stage, bool myTopics});

class RadarBrowse extends StatefulWidget {
  const RadarBrowse({super.key});

  @override
  State<RadarBrowse> createState() => _RadarBrowseState();
}

class _RadarBrowseState extends State<RadarBrowse> {
  final _seen = <String>[];
  String _query = '';
  _Filters _filters = (category: null, stage: null, myTopics: false);
  bool _cards = true;

  Future<void> _chooseFilters(RadarData data) async {
    FocusScope.of(context).unfocus();
    final filters = await showModalBottomSheet<_Filters>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(filters: _filters, data: data),
    );
    if (mounted && filters != null) setState(() => _filters = filters);
  }

  Future<bool> _swipe(RadarIdea idea, RadarData data, bool save) async {
    if (save && !data.favorites.any((item) => item.id == idea.id)) {
      final ok = await context.read<RadarController>().setFavorite(idea, true);
      if (!mounted) return false;
      if (!ok) {
        showRadarMessage(context, 'Nie udało się zapisać. Spróbuj ponownie.');
        return false;
      }
      showRadarMessage(context, 'Dodano do ulubionych.');
    }
    if (!mounted) return false;
    if (!_seen.contains(idea.id)) setState(() => _seen.add(idea.id));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return RadarLoad(
      builder: (context, data) {
        final controller = context.watch<RadarController>();
        final viewer = RadarViewer.of(context);
        final query = normalized(_query).trim();
        final terms = query.isEmpty
            ? const <String>[]
            : query.split(RegExp(r'\s+'));
        final results = data.ideas.where((idea) {
          if (_filters.myTopics && !viewer.interests.contains(idea.categoryId))
            return false;
          if (_filters.category != null && idea.categoryId != _filters.category)
            return false;
          if (_filters.stage != null && idea.stage != _filters.stage)
            return false;
          if (terms.isEmpty) return true;
          final index = normalized(
            '${idea.title} ${idea.problem} ${idea.solution} ${idea.organization} ${idea.city} '
            '${data.category(idea.categoryId)} ${idea.support.label} ${idea.supportDetails}',
          );
          return terms.every(index.contains);
        }).toList();
        final current = results
            .where((idea) => !_seen.contains(idea.id))
            .firstOrNull;
        final filterCount = [
          _filters.category != null,
          _filters.stage != null,
          _filters.myTopics,
        ].where((active) => active).length;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() => _query = value),
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Szukaj zgłoszeń',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Filtry zgłoszeń',
                        onPressed: () => _chooseFilters(data),
                        icon: Badge.count(
                          count: filterCount,
                          isLabelVisible: filterCount > 0,
                          child: const Icon(Icons.tune),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.style_outlined),
                          label: Text('Karty'),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.list),
                          label: Text('Lista'),
                        ),
                      ],
                      selected: {_cards},
                      onSelectionChanged: (values) =>
                          setState(() => _cards = values.single),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: ListView(
                          key: PageStorageKey(
                            _cards ? 'browse-cards' : 'browse-list',
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                          children: [
                            if (results.isEmpty)
                              const RadarEmpty(
                                icon: Icons.search_off,
                                title: 'Brak zgłoszeń',
                                description:
                                    'Zmień filtry lub odśwież katalog.',
                              )
                            else if (!_cards)
                              for (final idea in results)
                                RadarIdeaRow(
                                  idea: idea,
                                  category: data.category(idea.categoryId),
                                  onTap: () => openIdeaDetail(context, idea),
                                  trailing:
                                      data.favorites.any(
                                        (item) => item.id == idea.id,
                                      )
                                      ? const Icon(Icons.bookmark)
                                      : null,
                                )
                            else if (current == null)
                              RadarEmpty(
                                icon: Icons.check_circle_outline,
                                title: 'Wszystkie karty przejrzane',
                                description: 'W widoku listy możesz wrócić do dowolnego zgłoszenia.',
                                action: OutlinedButton(
                                  onPressed: () => setState(_seen.clear),
                                  child: const Text('Przejrzyj od początku'),
                                ),
                              )
                            else
                              _SwipeCard(
                                key: ValueKey(current.id),
                                width: math.max(1.0, constraints.maxWidth - 32),
                                enabled: !controller.state.working,
                                onSwipe: (save) => _swipe(current, data, save),
                                child: _BrowseCard(
                                  idea: current,
                                  category: data.category(current.categoryId),
                                  minHeight: math.max(
                                    0.0,
                                    constraints.maxHeight - 14,
                                  ),
                                  onTap: () => openIdeaDetail(context, current),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final _Filters filters;
  final RadarData data;

  const _FilterSheet({required this.filters, required this.data});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int? _category =
      widget.data.categories.any((c) => c.id == widget.filters.category)
      ? widget.filters.category
      : null;
  late IdeaStage? _stage = widget.filters.stage;
  late bool _myTopics = widget.filters.myTopics;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RadarHeading('Filtry zgłoszeń'),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Dziedzina'),
              child: DropdownButton<int>(
                value: _category,
                isExpanded: true,
                isDense: true,
                underline: const SizedBox.shrink(),
                hint: const Text('Wszystkie dziedziny'),
                onChanged: (value) => setState(() => _category = value),
                items: [
                  const DropdownMenuItem(child: Text('Wszystkie dziedziny')),
                  for (final category in widget.data.categories)
                    DropdownMenuItem(
                      value: category.id,
                      child: Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Etap'),
              child: DropdownButton<IdeaStage>(
                value: _stage,
                isExpanded: true,
                isDense: true,
                underline: const SizedBox.shrink(),
                hint: const Text('Wszystkie etapy'),
                onChanged: (value) => setState(() => _stage = value),
                items: [
                  const DropdownMenuItem(child: Text('Wszystkie etapy')),
                  for (final stage in IdeaStage.values)
                    DropdownMenuItem(value: stage, child: Text(stage.label)),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tylko moje dziedziny'),
              value: _myTopics,
              onChanged: (value) => setState(() => _myTopics = value),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, (
                category: _category,
                stage: _stage,
                myTopics: _myTopics,
              )),
              child: const Text('Zastosuj'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, (
                category: null as int?,
                stage: null as IdeaStage?,
                myTopics: false,
              )),
              child: const Text('Wyczyść filtry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeCard extends StatefulWidget {
  final double width;
  final bool enabled;
  final Future<bool> Function(bool save) onSwipe;
  final Widget child;

  const _SwipeCard({
    super.key,
    required this.width,
    required this.enabled,
    required this.onSwipe,
    required this.child,
  });

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(vsync: this);
  Offset _offset = Offset.zero;
  Offset _destination = Offset.zero;
  Offset? _dragStart;
  bool _moving = false;

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  Future<void> _animateTo(Offset target, Duration duration) async {
    setState(() {
      _destination = target;
      _moving = true;
    });
    _motion.duration = duration;
    await _motion.forward(from: 0).orCancel;
    if (mounted) setState(() => _offset = target);
  }

  Future<void> _finish({bool? save}) async {
    if (_moving) return;
    _dragStart = null;
    try {
      if (save != null) {
        final direction = save ? 1.0 : -1.0;
        final height = _offset.dy.abs() > 18
            ? _offset.dy * 1.6
            : -widget.width * .23;
        await _animateTo(
          Offset(direction * widget.width * 1.5, height),
          const Duration(milliseconds: 235),
        );
        if (!mounted || await widget.onSwipe(save)) return;
      }
      if (mounted)
        await _animateTo(Offset.zero, const Duration(milliseconds: 200));
    } on TickerCanceled {
      return;
    } finally {
      if (mounted) setState(() => _moving = false);
    }
  }

  void _endDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final acrossThreshold = _offset.dx.abs() > widget.width * .22;
    final fling =
        velocity.abs() > 725 &&
        _offset.dx.abs() > 22 &&
        velocity.sign == _offset.dx.sign;
    _finish(save: acrossThreshold || fling ? _offset.dx > 0 : null);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && !_moving;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      customSemanticsActions: enabled
          ? {
              const CustomSemanticsAction(label: 'Pomiń zgłoszenie'): () =>
                  _finish(save: false),
              const CustomSemanticsAction(label: 'Zapisz w ulubionych'): () =>
                  _finish(save: true),
            }
          : null,
      child: GestureDetector(
        onHorizontalDragStart: !enabled
            ? null
            : (details) => _dragStart = details.globalPosition,
        onHorizontalDragUpdate: !enabled
            ? null
            : (details) {
                final start = _dragStart;
                if (start == null) return;
                final delta = details.globalPosition - start;
                setState(() => _offset = Offset(delta.dx, delta.dy * .75));
              },
        onHorizontalDragEnd: enabled ? _endDrag : null,
        onHorizontalDragCancel: enabled ? () => _finish() : null,
        child: AnimatedBuilder(
          animation: _motion,
          child: widget.child,
          builder: (context, child) {
            final offset = _moving
                ? Offset.lerp(
                    _offset,
                    _destination,
                    Curves.easeOutCubic.transform(_motion.value),
                  )!
                : _offset;
            final strength = (offset.dx.abs() / (widget.width * .34))
                .clamp(0.0, 1.0)
                .toDouble();
            final saving = offset.dx > 0;
            final accent = saving ? colors.primary : colors.secondary;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (strength > 0)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: saving
                            ? colors.primaryContainer
                            : colors.secondaryContainer,
                      ),
                      child: Align(
                        alignment: saving
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Icon(
                            saving
                                ? Icons.bookmark_add_outlined
                                : Icons.skip_next,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: offset,
                  transformHitTests: false,
                  child: Transform.rotate(
                    angle:
                        (offset.dx / widget.width).clamp(-1.0, 1.0).toDouble() *
                        .32,
                    child: Stack(
                      children: [
                        IgnorePointer(ignoring: _moving, child: child),
                        if (strength > .15)
                          Positioned(
                            top: 16,
                            left: saving ? 16 : null,
                            right: saving ? null : 16,
                            child: ExcludeSemantics(
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: strength,
                                  child: _SwipeLabel(
                                    saving: saving,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SwipeLabel extends StatelessWidget {
  final bool saving;
  final Color color;

  const _SwipeLabel({required this.saving, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          saving ? 'ULUBIONE' : 'POMIŃ',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _BrowseCard extends StatelessWidget {
  final RadarIdea idea;
  final String category;
  final double minHeight;
  final VoidCallback onTap;

  const _BrowseCard({
    required this.idea,
    required this.category,
    required this.minHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = switch (idea.institution) {
      Institution.school => colors.primary,
      Institution.university => colors.secondary,
      Institution.council => const Color(0xff9BDDF7),
      Institution.publicBody => const Color(0xffF6CD9F),
    };
    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.alphaBlend(
                            accent.withValues(alpha: .16),
                            colors.surface,
                          ),
                          colors.surfaceContainerHigh,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -8,
                          top: -32,
                          bottom: -34,
                          width: 238,
                          child: RadarArtwork(color: accent),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 28,
                          ),
                          child: Row(
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: accent.withValues(alpha: .13),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    institutionIcon(idea.institution),
                                    color: accent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  idea.institution.label,
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            RadarTag(category, accent: true),
                            RadarTag(idea.stage.label),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          idea.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${idea.organization} · ${idea.city}',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          idea.problem,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadarSupportSection(idea: idea, compact: true),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        RadarTag('${idea.score} / 100 pkt', icon: Icons.speed),
                        Text(
                          'Szczegóły ›',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
