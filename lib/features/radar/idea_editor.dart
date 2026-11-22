import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'radar_controller.dart';
import 'radar_matching.dart';
import 'radar_models.dart';
import 'radar_scope.dart';
import 'radar_widgets.dart';

class IdeaEditor extends StatefulWidget {
  final RadarIdea? original;
  final Institution institution;
  final ValueChanged<String>? onSaved;

  const IdeaEditor({
    super.key,
    this.original,
    this.institution = Institution.school,
    this.onSaved,
  });

  @override
  State<IdeaEditor> createState() => _IdeaEditorState();
}

class _IdeaEditorState extends State<IdeaEditor> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  late String _id = widget.original?.id ?? newRadarId();
  late final _title = TextEditingController(text: widget.original?.title);
  late final _organization = TextEditingController(
    text: widget.original?.organization,
  );
  late final _city = TextEditingController(text: widget.original?.city);
  late final _problem = TextEditingController(text: widget.original?.problem);
  late final _solution = TextEditingController(text: widget.original?.solution);
  late final _evidence = TextEditingController(text: widget.original?.evidence);
  late final _supportDetails = TextEditingController(
    text: widget.original?.supportDetails,
  );
  late final _contactEmail = TextEditingController(
    text: widget.original?.contactEmail,
  );
  late final _metric = TextEditingController(text: widget.original?.metric);
  late final _ratings = List<int>.of(widget.original?.ratings ?? [0, 0, 0, 0]);
  late Institution _institution =
      widget.original?.institution ?? widget.institution;
  late InnovationType _type = widget.original?.type ?? InnovationType.process;
  late IdeaStage _stage = widget.original?.stage ?? IdeaStage.concept;
  late Support? _support = widget.original?.support;
  late int? _category = widget.original?.categoryId;
  bool _review = false;
  bool _saving = false;

  List<TextEditingController> get _fields => [
    _title,
    _organization,
    _city,
    _problem,
    _solution,
    _evidence,
    _metric,
    _supportDetails,
    _contactEmail,
  ];

  @override
  void dispose() {
    _scroll.dispose();
    for (final controller in _fields) {
      controller.dispose();
    }
    super.dispose();
  }

  RadarIdea _idea(bool publish, RadarViewer viewer) {
    return RadarIdea(
      id: _id,
      ownerId: viewer.id,
      author: viewer.name,
      title: _title.text.trim(),
      categoryId: _category!,
      institution: _institution,
      organization: _organization.text.trim(),
      city: _city.text.trim(),
      type: _type,
      stage: _stage,
      support: _support!,
      problem: _problem.text.trim(),
      solution: _solution.text.trim(),
      evidence: _evidence.text.trim(),
      metric: _metric.text.trim(),
      ratings: List.unmodifiable(_ratings),
      supportDetails: _supportDetails.text.trim(),
      contactEmail: _contactEmail.text.trim(),
      published: publish,
    );
  }

  void _goTo(bool review) {
    FocusScope.of(context).unfocus();
    setState(() => _review = review);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _save(bool publish, RadarViewer viewer) async {
    if (_saving) return;
    if (publish && _metric.text.trim().isEmpty) {
      showRadarMessage(context, 'Podaj miernik sukcesu przed publikacją.');
      return;
    }
    if (publish &&
        _ratings[Criterion.evidence.index] > 0 &&
        _evidence.text.trim().isEmpty) {
      showRadarMessage(
        context,
        'Opisz źródło dowodów albo wybierz poziom „Brak danych”.',
      );
      return;
    }
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    final saved = await context.read<RadarController>().saveIdea(
      _idea(publish, viewer),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      showRadarMessage(
        context,
        'Nie udało się zapisać zgłoszenia. Spróbuj ponownie.',
      );
      return;
    }
    showRadarMessage(
      context,
      publish ? 'Zgłoszenie jest na radarze.' : 'Zapisano prywatny szkic.',
    );
    final onSaved = widget.onSaved;
    if (onSaved == null) {
      navigator.pop();
      return;
    }

    final savedId = _id;
    setState(() {
      for (final controller in _fields) {
        controller.clear();
      }
      _id = newRadarId();
      _institution = widget.institution;
      _type = InnovationType.process;
      _stage = IdeaStage.concept;
      _support = null;
      _category = null;
      _ratings.fillRange(0, _ratings.length, 0);
      _review = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    onSaved(savedId);
  }

  @override
  Widget build(BuildContext context) {
    final viewer = RadarViewer.of(context);
    final form = RadarLoad(
      builder: (context, data) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _review
                      ? _assessment(data, viewer)
                      : _description(data),
                ),
              ),
            ),
          ),
        );
      },
    );

    return PopScope(
      canPop: !_saving,
      child: widget.onSaved != null
          ? form
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.original == null
                      ? 'Nowe zgłoszenie'
                      : 'Edytuj zgłoszenie',
                ),
              ),
              body: form,
            ),
    );
  }

  List<Widget> _description(RadarData data) {
    return [
      const RadarHeading(
        'Opisz pomysł',
        subtitle: 'Krok 1 z 2 · Karta innowacji',
      ),
      _field(_title, 'Tytuł', 4, 100, hint: 'Np. Cicha przerwa'),
      _choice(
        value: data.categories.any((item) => item.id == _category)
            ? _category
            : null,
        label: 'Dziedzina',
        items: {
          for (final category in data.categories) category.id: category.name,
        },
        onChanged: (value) => setState(() => _category = value),
      ),
      _choice(
        value: _institution,
        label: 'Typ instytucji',
        items: {for (final item in Institution.values) item: item.label},
        onChanged: (value) => setState(() => _institution = value!),
      ),
      _field(_organization, 'Instytucja lub zespół', 2, 100),
      _field(_city, 'Miejscowość', 2, 80),
      _choice(
        value: _type,
        label: 'Typ innowacji',
        items: {for (final item in InnovationType.values) item: item.label},
        onChanged: (value) => setState(() => _type = value!),
      ),
      _choice(
        value: _stage,
        label: 'Etap',
        items: {for (final item in IdeaStage.values) item: item.label},
        onChanged: (value) => setState(() => _stage = value!),
      ),
      _field(
        _problem,
        'Problem i odbiorcy',
        10,
        700,
        lines: 3,
        hint: 'Kto ma ten problem i kiedy go odczuwa?',
      ),
      _field(
        _solution,
        'Proponowane rozwiązanie',
        10,
        900,
        lines: 3,
        hint: 'Co konkretnie zmieniasz?',
      ),
      _field(
        _evidence,
        'Źródło dowodów',
        0,
        500,
        lines: 2,
        hint: 'Np. obserwacja, ankieta lub porównanie przed i po',
      ),
      _field(
        _metric,
        'Miernik sukcesu',
        0,
        250,
        lines: 2,
        hint: 'Np. odsetek wniosków przyjętych bez korekty',
      ),
      const SizedBox(height: 8),
      const RadarHeading('Potrzebne wsparcie'),
      _choice(
        value: _support,
        label: 'Rodzaj wsparcia',
        items: {for (final item in Support.values) item: item.label},
        onChanged: (value) => setState(() => _support = value),
      ),
      _field(
        _supportDetails,
        'Jakiej pomocy szukasz? (opcjonalnie)',
        0,
        400,
        lines: 2,
        hint: 'Np. pomoc w podłączeniu czujników lub środki na pilotaż',
      ),
      const SizedBox(height: 8),
      const RadarHeading('Kontakt do autorów'),
      TextFormField(
        controller: _contactEmail,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        enableSuggestions: false,
        maxLength: 254,
        decoration: const InputDecoration(
          labelText: 'E-mail kontaktowy',
          helperText: 'Widoczny dla zalogowanych po publikacji.',
          helperMaxLines: 2,
        ),
        validator: (value) {
          final address = (value ?? '').trim();
          if (address.isEmpty)
            return 'Podaj adres kontaktowy autora lub zespołu.';
          if (!RegExp(r'^[^\s@]+@[^\s@]+[.][^\s@]+$').hasMatch(address)) {
            return 'Wpisz poprawny adres e-mail.';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) _goTo(true);
        },
        child: const Text('Przejdź do oceny'),
      ),
    ];
  }

  List<Widget> _assessment(RadarData data, RadarViewer viewer) {
    final idea = _idea(false, viewer);
    final matches = similarIdeas(idea, data.corpus);
    final busy = context.watch<RadarController>().state.working || _saving;
    return [
      const RadarHeading(
        'Oceń potencjał',
        subtitle: 'Krok 2 z 2 · Samoocena autora',
      ),
      for (final criterion in Criterion.values)
        _choice<int>(
          value: _ratings[criterion.index],
          label: '${criterion.label} · waga ${criterion.weight}%',
          items: {
            for (final (index, label) in criterion.levels.indexed)
              index: '$index · $label',
          },
          onChanged: busy
              ? null
              : (value) => setState(() => _ratings[criterion.index] = value!),
        ),
      RadarPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadarTag(
              '${idea.score} / 100 pkt',
              icon: Icons.speed,
              accent: true,
            ),
            const SizedBox(height: 12),
            Text(
              idea.pathway.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Text(idea.pathway.reason),
          ],
        ),
      ),
      const SizedBox(height: 14),
      RadarPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Podobne zgłoszenia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            if (matches.isEmpty)
              const Text('W aktualnie wczytanym katalogu brak trafień.'),
            for (final match in matches.take(3))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(match.idea.title),
                subtitle: Text('Wspólne słowa: ${match.shared.join(', ')}'),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: busy ? null : () => _save(true, viewer),
        child: Text(
          widget.original?.published == true
              ? 'Zapisz i zostaw w katalogu'
              : 'Opublikuj zgłoszenie',
        ),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: busy ? null : () => _save(false, viewer),
        child: Text(
          widget.original?.published == true
              ? 'Wycofaj do szkiców'
              : 'Zapisz jako szkic',
        ),
      ),
      TextButton(
        onPressed: busy ? null : () => _goTo(false),
        child: const Text('Wróć do opisu'),
      ),
    ];
  }
}

Widget _choice<T>({
  required T? value,
  required String label,
  required Map<T, String> items,
  required ValueChanged<T?>? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final entry in items.entries)
          DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
      validator: (value) => value == null ? 'Wybierz opcję.' : null,
    ),
  );
}

Widget _field(
  TextEditingController controller,
  String label,
  int min,
  int max, {
  String? hint,
  int lines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      minLines: lines,
      maxLines: lines + (lines > 1 ? 2 : 0),
      maxLength: max,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (value) {
        final length = (value ?? '').trim().runes.length;
        if (length < min) return 'Wpisz co najmniej $min znaków.';
        if (length > max) return 'Maksymalnie $max znaków.';
        return null;
      },
    ),
  );
}
