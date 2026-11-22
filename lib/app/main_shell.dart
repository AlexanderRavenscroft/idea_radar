import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_radar/features/radar/radar_controller.dart';
import 'package:idea_radar/features/radar/radar_widgets.dart';

class MainShell extends StatelessWidget {
  final Widget body;
  final int index;
  final ValueChanged<int> onDestination;

  const MainShell({
    super.key,
    required this.body,
    required this.index,
    required this.onDestination,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RadarController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: index == 1
          ? null
          : AppBar(
              titleSpacing: 12,
              title: Row(
                children: [
                  Container(
                    width: 37,
                    height: 37,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: RadarArtwork(color: colors.primary, compact: true),
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      'Radar Innowacji',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: SafeArea(
        top: index == 1,
        bottom: false,
        child: Column(
          children: [
            if (controller.state.loadFailed && controller.state.data != null)
              MaterialBanner(
                content: const Text('Wyświetlane dane mogą być nieaktualne.'),
                actions: [
                  TextButton(
                    onPressed: controller.refresh,
                    child: const Text('Odśwież'),
                  ),
                ],
              ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onDestination,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.radar), label: 'Radar'),
            NavigationDestination(
              icon: Icon(Icons.style_outlined),
              selectedIcon: Icon(Icons.style),
              label: 'Odkrywaj',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Zgłoś',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Zapisane',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
