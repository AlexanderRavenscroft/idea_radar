import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (label: 'Home', icon: Icons.home_outlined, accent: false),
    (label: 'Search', icon: Icons.search, accent: false),
    (label: 'Add Idea', icon: Icons.add, accent: true),
    (label: 'More', icon: Icons.more_horiz, accent: false),
    (label: 'Profile', icon: Icons.person_outline, accent: false),
  ];

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.inversePrimary,
        title: const Text('Idea Radar'),
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        foregroundDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: BottomAppBar(
          height: 72,
          padding: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, destination) in _destinations.indexed)
                _buildDestination(
                  context,
                  index: index,
                  label: destination.label,
                  icon: destination.icon,
                  accent: destination.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestination(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required bool accent,
  }) {
    final selected = navigationShell.currentIndex == index;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const radius = BorderRadius.all(Radius.circular(12));
    final iconColor = selected ? colors.primary : colors.onSurfaceVariant;
    final textColor = selected ? colors.onSurface : colors.onSurfaceVariant;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Semantics(
          label: accent ? label : null,
          button: true,
          selected: selected,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: () =>
                  navigationShell.goBranch(index, initialLocation: selected),
              borderRadius: radius,
              child: Center(
                child: Ink(
                  width: 56,
                  height: 48,
                  decoration: accent
                      ? BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: radius,
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 24, color: iconColor),
                      if (!accent) ...[
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: textColor,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
