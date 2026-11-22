import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'idea_detail.dart';
import 'radar_controller.dart';
import 'radar_scope.dart';
import 'radar_widgets.dart';

class RadarCollection extends StatefulWidget {
  final bool showOwn;

  const RadarCollection({super.key, required this.showOwn});

  @override
  State<RadarCollection> createState() => _RadarCollectionState();
}

class _RadarCollectionState extends State<RadarCollection> {
  late bool _favorites = !widget.showOwn;

  @override
  Widget build(BuildContext context) {
    return RadarLoad(
      builder: (context, data) {
        final selected = _favorites ? data.favorites : data.own;
        return RadarList(
          onRefresh: context.read<RadarController>().refresh,
          children: [
            const RadarHeading(
              'Twoja kolekcja',
              subtitle: 'Wracaj do ulubionych pomysłów i zarządzaj własnymi zgłoszeniami.',
            ),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.bookmark_outline),
                  label: Text('Ulubione'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.folder_outlined),
                  label: Text('Moje'),
                ),
              ],
              selected: {_favorites},
              onSelectionChanged: (values) =>
                  setState(() => _favorites = values.single),
            ),
            const SizedBox(height: 14),
            if (selected.isEmpty)
              RadarEmpty(
                icon: _favorites
                    ? Icons.bookmark_border
                    : Icons.folder_outlined,
                title: _favorites
                    ? 'Brak ulubionych'
                    : 'Brak własnych zgłoszeń',
                description: _favorites
                    ? 'Przesuń kartę w prawo lub zapisz ją na ekranie szczegółów.'
                    : 'Zgłoś znalezisko ze swojej instytucji. Tutaj znajdziesz także prywatne szkice.',
              ),
            for (final idea in selected)
              RadarIdeaRow(
                idea: idea,
                category: data.category(idea.categoryId),
                onTap: () => openIdeaDetail(context, idea),
              ),
          ],
        );
      },
    );
  }
}
