library snadboy_logger;

import 'dart:isolate';
import 'package:logger/logger.dart' as plogger;

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
}

final _logger = plogger.Logger(printer: plogger.SimplePrinter(printTime: true, colors: true));

void log(String logMsg, {LogLevel level = LogLevel.info}) {
  if (level == LogLevel.verbose) {
    _logger.log(plogger.Level.verbose, 'I[${Isolate.current.debugName}] $logMsg');
  } else if (level == LogLevel.debug) {
    _logger.log(plogger.Level.verbose, 'I[${Isolate.current.debugName}] $logMsg');
  } else if (level == LogLevel.info) {
    _logger.log(plogger.Level.verbose, 'I[${Isolate.current.debugName}] $logMsg');
  } else if (level == LogLevel.warning) {
    _logger.log(plogger.Level.verbose, 'I[${Isolate.current.debugName}] $logMsg');
  } else if (level == LogLevel.error) {
    _logger.log(plogger.Level.verbose, 'I[${Isolate.current.debugName}] $logMsg');
  }
}
