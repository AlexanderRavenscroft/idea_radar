import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'idea_detail.dart';
import 'radar_controller.dart';
import 'radar_intake.dart';
import 'radar_scope.dart';
import 'radar_widgets.dart';

class RadarDashboard extends StatelessWidget {
  final VoidCallback onBrowse;

  const RadarDashboard({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return RadarLoad(
      builder: (context, data) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final viewer = RadarViewer.of(context);
        return RadarList(
          onRefresh: context.read<RadarController>().refresh,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xff152B28),
                      Color(0xff1E4438),
                      Color(0xff203540),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -37,
                      top: -15,
                      bottom: -20,
                      width: 260,
                      child: RadarArtwork(color: colors.primary),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 21),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Odkryj lokalne\ninnowacje',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.4,
                              height: 1.03,
                            ),
                          ),
                          const SizedBox(height: 13),
                          const SizedBox(
                            width: 205,
                            child: Text(
                              'Zobacz pomysły z instytucji publicznych i sprawdź, jak możesz pomóc w ich rozwoju.',
                              style: TextStyle(
                                height: 1.4,
                                color: Color(0xffD4E5DE),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: onBrowse,
                            icon: const Icon(Icons.radar),
                            label: const Text('Uruchom radar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 13),
            RadarPanel(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
              child: Row(
                children: [
                  _stat(context, data.ideas.length, 'w katalogu'),
                  _stat(context, data.favorites.length, 'ulubione'),
                  _stat(context, data.own.length, 'moje zgłoszenia'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RadarPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.travel_explore, color: colors.secondary),
                  const SizedBox(height: 7),
                  Text(
                    'Rozejrzyj się w swojej instytucji',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Skorzystaj z pytań dla szkoły, uczelni, samorządu lub innej instytucji publicznej.',
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        openRadarScreen<void>(context, const RadarIntake()),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Rozpocznij rozpoznanie'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const RadarHeading('Z Twoich dziedzin'),
            if (!data.ideas.any(
              (idea) => viewer.interests.contains(idea.categoryId),
            ))
              const Text(
                'Trafienia pojawią się, gdy w katalogu znajdą się zgłoszenia z dziedzin wybranych w profilu.',
              ),
            for (final idea
                in data.ideas
                    .where((idea) => viewer.interests.contains(idea.categoryId))
                    .take(3))
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

  Widget _stat(BuildContext context, int value, String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
