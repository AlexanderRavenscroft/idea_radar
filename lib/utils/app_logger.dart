import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInException;
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException;

final log = Logger(
  filter: ProductionFilter(),
  level: kReleaseMode ? Level.off : Level.debug,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 6,
    noBoxingByDefault: true,
    colors: false,
    printEmojis: false,
  ),
);

void logFailure(
  String operation,
  Object error,
  StackTrace stack, {
  int? elapsedMs,
}) {
  if (kReleaseMode) return;

  final code = switch (error) {
    PostgrestException(:final code) => code,
    AuthException(:final code, :final statusCode) => code ?? statusCode,
    GoogleSignInException(:final code) => code.name,
    _ => null,
  };
  final duration = elapsedMs == null ? '' : ' elapsed_ms=$elapsedMs';
  final errorCode = code == null ? '' : ' code=$code';
  log.e(
    '[RADAR] $operation failed$duration type=${error.runtimeType}$errorCode',
    error: 'Diagnostic stack',
    stackTrace: stack,
  );
}

Future<T> logTimed<T>(String operation, Future<T> Function() run) async {
  if (kReleaseMode) return run();

  final stopwatch = Stopwatch()..start();
  log.d('[RADAR] $operation started');
  try {
    final result = await run();
    log.d(
      '[RADAR] $operation finished elapsed_ms=${stopwatch.elapsedMilliseconds}',
    );
    return result;
  } catch (error, stack) {
    logFailure(
      operation,
      error,
      stack,
      elapsedMs: stopwatch.elapsedMilliseconds,
    );
    rethrow;
  }
}
