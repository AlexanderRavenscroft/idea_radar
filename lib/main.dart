import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:idea_radar/app/idea_radar_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: ''),
    publishableKey: dotenv.get('SUPABASE_PUBLISHABLE_KEY', fallback: ''),
  );

  runApp(const IdeaRadarApp());
}
