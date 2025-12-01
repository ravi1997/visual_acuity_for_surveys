import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:visual_acuity_for_surveys/Logger/socket_logger.dart';
import 'debug_file_logger.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true, // Print an emoji for each log message
    // Should each log print contain a timestamp
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

class DebugLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true, // Print an emoji for each log message
      // Should each log print contain a timestamp
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: kDebugMode ? DebugFileOutput() : ConsoleOutput(),
    level: kDebugMode ? Level.debug : Level.info,
  );

  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message) => _logger.w(message);
  static void e(dynamic message) => _logger.e(message);
  static void f(dynamic message) => _logger.f(message);
}

final networkLogger = Logger(
  level: kDebugMode ? Level.debug : Level.info,
  printer: PrettyPrinter(),
  output: SocketLogOutput(host: '127.0.0.1', port: 59540),
);

