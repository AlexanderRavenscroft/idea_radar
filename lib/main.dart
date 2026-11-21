import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idea_radar/app/idea_radar_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const IdeaRadarApp());
}
