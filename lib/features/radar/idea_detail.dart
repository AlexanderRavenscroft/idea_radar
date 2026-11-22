import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'idea_editor.dart';
import 'radar_controller.dart';
import 'radar_matching.dart';
import 'radar_models.dart';
import 'radar_scope.dart';
import 'radar_widgets.dart';

void openIdeaDetail(BuildContext context, RadarIdea idea) {
  openRadarScreen<void>(context, IdeaDetail(ideaId: idea.id));
}

class IdeaDetail extends StatelessWidget {
  final String ideaId;

  const IdeaDetail({super.key, required this.ideaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karta innowacji')),
      body: RadarLoad(
        builder: (context, data) {
          final idea = [
            ...data.own,
            ...data.ideas,
            ...data.favorites,
          ].where((item) => item.id == ideaId).firstOrNull;
          if (idea == null) {
            return const RadarList(
              children: [
                RadarEmpty(
                  icon: Icons.visibility_off_outlined,
                  title: 'Zgłoszenie jest niedostępne',
                  description: 'Być może autor wycofał je z katalogu.',
                ),
              ],
            );
          }
          return _IdeaDetailBody(idea: idea, data: data);
        },
      ),
    );
  }
}

class _IdeaDetailBody extends StatelessWidget {
  final RadarIdea idea;
  final RadarData data;

  const _IdeaDetailBody({required this.idea, required this.data});

  Future<void> _favorite(BuildContext context, bool saved) async {
    final ok = await context.read<RadarController>().setFavorite(idea, !saved);
    if (context.mounted) {
      showRadarMessage(
        context,
        ok
            ? saved
                  ? 'Usunięto z ulubionych.'
                  : 'Dodano do ulubionych.'
            : 'Nie udało się zmienić ulubionych.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewer = RadarViewer.of(context);
    final mine = idea.ownerId == viewer.id;
    final saved = data.favorites.any((item) => item.id == idea.id);
    final similar = similarIdeas(idea, data.corpus);
    final theme = Theme.of(context);
    final busy = context.watch<RadarController>().state.working;
    return RadarList(
      onRefresh: context.read<RadarController>().refresh,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            RadarTag(data.category(idea.categoryId), accent: true),
            RadarTag(idea.type.label),
            RadarTag(idea.published ? idea.stage.label : 'Prywatny szkic'),
          ],
        ),
        const SizedBox(height: 10),
        RadarHeading(
          idea.title,
          subtitle:
              '${idea.organization} · ${idea.city}\n${idea.institution.label} · ${idea.author}',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (mine)
              FilledButton.tonalIcon(
                onPressed: busy
                    ? null
                    : () => openRadarScreen<void>(
                        context,
                        IdeaEditor(original: idea),
                      ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edytuj'),
              )
            else
              OutlinedButton.icon(
                onPressed: busy ? null : () => _favorite(context, saved),
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                label: Text(saved ? 'Zapisano' : 'Zapisz'),
              ),
          ],
        ),
        const SizedBox(height: 18),
        RadarSupportSection(idea: idea),
        const SizedBox(height: 14),
        RadarPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _text('Problem i odbiorcy', idea.problem),
              _text('Rozwiązanie', idea.solution),
              _text(
                'Źródło dowodów',
                idea.evidence.isEmpty
                    ? 'Autor nie podał źródła.'
                    : idea.evidence,
              ),
              _text(
                'Miernik autora',
                idea.metric.isEmpty ? 'Do ustalenia' : idea.metric,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        RadarPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadarTag(
                '${idea.score} / 100 pkt',
                icon: Icons.speed,
                accent: true,
              ),
              const SizedBox(height: 10),
              Text('Samoocena potencjału', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final criterion in Criterion.values) ...[
                Text(
                  '${criterion.label} · ${idea.ratings[criterion.index]} / 3 · waga ${criterion.weight}%',
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: idea.ratings[criterion.index] / 3,
                  borderRadius: BorderRadius.circular(8),
                  semanticsLabel: criterion.label,
                ),
                const SizedBox(height: 4),
                Text(
                  criterion.levels[idea.ratings[criterion.index]],
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
              ],
              const Text(
                'Wynik to ważona suma ocen przeliczona na 100 punktów. Oceny pochodzą od autora.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        RadarPanel(
          tint: theme.colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RadarTag('Ścieżka rozwoju', icon: Icons.route_outlined),
              const SizedBox(height: 11),
              Text(
                idea.pathway.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(idea.pathway.reason),
              const SizedBox(height: 10),
              _text('Proponowany miernik', idea.pathway.measure, last: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const RadarHeading(
          'Podobne zgłoszenia',
          subtitle: 'Wspólne słowa i dziedzina we wczytanym katalogu.',
        ),
        if (similar.isEmpty)
          const Text('Brak trafień w aktualnie wczytanym katalogu.'),
        for (final match in similar.take(4))
          RadarIdeaRow(
            idea: match.idea,
            category: 'Wspólne słowa: ${match.shared.join(', ')}',
            onTap: () => openIdeaDetail(context, match.idea),
          ),
        const SizedBox(height: 16),
        RadarPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kontakt do autorów', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(idea.author),
              if (idea.contactEmail.isEmpty)
                Text(
                  mine
                      ? 'Uzupełnij e-mail kontaktowy w edycji zgłoszenia.'
                      : 'Autor nie udostępnił adresu kontaktowego.',
                )
              else ...[
                const SizedBox(height: 6),
                SelectableText(idea.contactEmail),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: idea.contactEmail),
                    );
                    if (context.mounted)
                      showRadarMessage(context, 'Skopiowano adres e-mail.');
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Kopiuj e-mail'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _text(String label, String body, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
