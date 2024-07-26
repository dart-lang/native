// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_logging.dart' show Ansi;
import 'package:logging/logging.dart';

import 'config_provider.dart' show Config;
import 'header_parser.dart' show parse;

final _logger = Logger('ffigen.ffigen');
final _ansi = Ansi(Ansi.terminalSupportsAnsi);

class FfiGen {
  FfiGen({Level? logLevel = null}) {
    if (logLevel != null) {
      // Setup logger for printing (if verbosity was set by user).
      Logger.root.level = logLevel;
      Logger.root.onRecord.listen((record) {
        final levelStr = '[${record.level.name}]'.padRight(9);
        _printLog('$levelStr: ${record.message}', record.level);
      });
    } else {
      // Setup logger for printing (if verbosity was not set by user).
      Logger.root.onRecord.listen((record) {
        if (record.level.value > Level.INFO.value) {
          final levelStr = '[${record.level.name}]'.padRight(9);
          _printLog('$levelStr: ${record.message}', record.level);
        } else {
          _printLog(record.message, record.level);
        }
      });
    }
  }

  /// Runs the entire generation pipeline for the given config.
  void generate(Config config) {
    // Parse the bindings according to config object provided.
    final library = parse(config);

    // Generate files for the parsed bindings.
    final gen = File(config.output);
    library.generateFile(gen, format: config.formatOutput);
    _logger.info(
        _successPen('Finished, Bindings generated in ${gen.absolute.path}'));

    final objCGen = File(config.outputObjC);
    if (library.generateObjCFile(objCGen)) {
      _logger.info(_successPen('Finished, Objective C bindings generated '
          'in ${objCGen.absolute.path}'));
    }

    if (config.symbolFile != null) {
      final symbolFileGen = File(config.symbolFile!.output);
      library.generateSymbolOutputFile(
          symbolFileGen, config.symbolFile!.importPath);
      _logger.info(_successPen(
          'Finished, Symbol Output generated in ${symbolFileGen.absolute.path}'));
    }
  }

  static void _printLog(String log, Level level) {
    // Prints text in red for Severe logs only.
    if (level < Level.SEVERE) {
      print(log);
    } else {
      print(_errorPen(log));
    }
  }

  static String _successPen(String str) => '${_ansi.green}$str${_ansi.none}';
  static String _errorPen(String str) => '${_ansi.red}$str${_ansi.none}';
}
