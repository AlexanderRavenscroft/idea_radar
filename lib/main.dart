import 'dart:async';
import 'dart:ui' show FrameTiming, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:idea_radar/app/idea_radar_app.dart';
import 'package:idea_radar/theme/app_theme.dart';
import 'package:idea_radar/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final startupClock = kReleaseMode ? null : (Stopwatch()..start());
  if (startupClock != null) _installErrorLogging();

  unawaited(_setOrientation());
  final problem = await _initializeSupabase();
  if (startupClock != null) _measureStartupFrames(startupClock);

  if (problem == null) {
    runApp(const IdeaRadarApp());
    return;
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radar Innowacji',
      theme: AppTheme.dark,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(problem, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<String?> _initializeSupabase() async {
  log.i('[RADAR] startup.app mode=supabase');
  try {
    await logTimed('startup.env', () => dotenv.load());
    final url = dotenv.maybeGet('SUPABASE_URL')?.trim() ?? '';
    final key = dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY')?.trim() ?? '';
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      log.w('[RADAR] startup.app unavailable reason=invalid_supabase_url');
      return 'Sprawdź adres SUPABASE_URL w pliku .env.';
    }
    if (key.isEmpty) {
      log.w('[RADAR] startup.app unavailable reason=missing_supabase_key');
      return 'Uzupełnij SUPABASE_PUBLISHABLE_KEY w pliku .env.';
    }

    await logTimed(
      'startup.supabase',
      () => Supabase.initialize(url: url, publishableKey: key, debug: false),
    );
    return null;
  } on FileNotFoundError {
    log.w('[RADAR] startup.app unavailable reason=missing_env_file');
    return 'Brakuje pliku .env z konfiguracją Supabase.';
  } catch (_) {
    log.w('[RADAR] startup.app unavailable reason=initialization_failed');
    return 'Nie udało się uruchomić połączenia z Supabase.';
  }
}

Future<void> _setOrientation() async {
  try {
    await logTimed(
      'startup.orientation',
      () =>
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
  } catch (_) {
    // Startup can continue if the host cannot set an orientation.
  }
}

void _installErrorLogging() {
  FlutterError.onError = (details) {
    log.e(
      '[RADAR] flutter.framework failed type=${details.exception.runtimeType} '
      'library=${details.library ?? 'unknown'}',
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logFailure('dart.unhandled', error, stack);
    return true;
  };
}

void _measureStartupFrames(Stopwatch stopwatch) {
  final binding = SchedulerBinding.instance;
  binding.addPostFrameCallback((_) {
    log.i(
      '[RADAR] startup.first_frame_submitted elapsed_ms=${stopwatch.elapsedMilliseconds}',
    );
  });

  var frameCount = 0;
  var slowFrameCount = 0;
  var maxBuildUs = 0;
  var maxRasterUs = 0;

  void collect(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildUs = timing.buildDuration.inMicroseconds;
      final rasterUs = timing.rasterDuration.inMicroseconds;
      if (frameCount == 0) {
        log.i(
          '[RADAR] startup.first_frame build_us=$buildUs raster_us=$rasterUs',
        );
      }
      frameCount++;
      if (buildUs > maxBuildUs) maxBuildUs = buildUs;
      if (rasterUs > maxRasterUs) maxRasterUs = rasterUs;
      if (buildUs > 16667 || rasterUs > 16667) slowFrameCount++;
    }
  }

  binding.addTimingsCallback(collect);
  Timer(const Duration(seconds: 8), () {
    binding.removeTimingsCallback(collect);
    log.i(
      '[RADAR] startup.frames window_s=8 count=$frameCount '
      'over_60hz_budget=$slowFrameCount max_build_us=$maxBuildUs max_raster_us=$maxRasterUs',
    );
  });
}
