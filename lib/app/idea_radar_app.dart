import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idea_radar/app/app_routing.dart';

class IdeaRadarApp extends StatefulWidget {
  const IdeaRadarApp({super.key});

  @override
  State<IdeaRadarApp> createState() => _IdeaRadarAppState();
}

class _IdeaRadarAppState extends State<IdeaRadarApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Idea Radar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}
