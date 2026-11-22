import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'radar_controller.dart';
import 'radar_models.dart';
import 'radar_widgets.dart';

class RadarViewer extends InheritedWidget {
  final String id;
  final String name;
  final List<int> interests;

  const RadarViewer({
    super.key,
    required this.id,
    required this.name,
    required this.interests,
    required super.child,
  });

  static RadarViewer of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RadarViewer>()!;
  }

  @override
  bool updateShouldNotify(RadarViewer oldWidget) {
    return id != oldWidget.id ||
        name != oldWidget.name ||
        interests != oldWidget.interests;
  }
}

Future<T?> openRadarScreen<T>(BuildContext context, Widget screen) {
  final controller = context.read<RadarController>();
  final viewer = RadarViewer.of(context);
  return Navigator.of(context, rootNavigator: true).push<T>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: controller,
        child: RadarViewer(
          id: viewer.id,
          name: viewer.name,
          interests: viewer.interests,
          child: screen,
        ),
      ),
    ),
  );
}

class RadarLoad extends StatelessWidget {
  final Widget Function(BuildContext, RadarData) builder;

  const RadarLoad({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadarController, RadarState>(
      builder: (context, state) {
        final data = state.data;
        if (data != null) return builder(context, data);
        if (!state.loadFailed) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Ładowanie radaru',
            ),
          );
        }
        return RadarList(
          children: [
            RadarEmpty(
              icon: Icons.cloud_off_outlined,
              title: 'Nie udało się wczytać radaru',
              description: 'Sprawdź połączenie. Przy pierwszym uruchomieniu zastosuj migrację Supabase.',
              action: OutlinedButton(
                onPressed: context.read<RadarController>().refresh,
                child: const Text('Spróbuj ponownie'),
              ),
            ),
          ],
        );
      },
    );
  }
}
