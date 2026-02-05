// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_logging.dart' show Ansi;
import 'package:logging/logging.dart';

import 'config_provider.dart' show Config, FfiGenerator;
import 'context.dart';
import 'header_parser.dart' show parse;
import 'logger.dart';

final _ansi = Ansi(Ansi.terminalSupportsAnsi);

extension FfiGenGenerator on FfiGenerator {
  /// Runs the entire generation pipeline for the given config.
  ///
  /// If provided, uses [logger] to output logs. Otherwise, uses a default
  /// logger that streams [Level.WARNING] to stdout and higher levels to stderr.
  void generate({Logger? logger, Uri? libclangDylib}) {
    logger ??= createDefaultLogger();
    final config = Config(this);
    final context = Context(logger, config, libclangDylib: libclangDylib);

    // Parse the bindings according to config object provided.
    final library = parse(context);

    // Generate files for the parsed bindings.
    final gen = File(config.output.dartFile.toFilePath());
    library.generateFile(gen, format: config.ffiGen.output.format);
    logger.info(
      _successPen('Finished, Bindings generated in ${gen.absolute.path}'),
    );

    final objCGen = File(config.output.objCFile.toFilePath());
    if (library.generateObjCFile(objCGen)) {
      logger.info(
        _successPen(
          'Finished, Objective C bindings generated '
          'in ${objCGen.absolute.path}',
        ),
      );
    }

    final symbolFile = config.output.symbolFile;
    if (symbolFile != null) {
      final symbolFileGen = File(symbolFile.output.toFilePath());
      library.generateSymbolOutputFile(
        symbolFileGen,
        symbolFile.importPath.toString(),
      );
      logger.info(
        _successPen(
          'Finished, Symbol Output generated in '
          '${symbolFileGen.absolute.path}',
        ),
      );
    }
  }

  static String _successPen(String str) => '${_ansi.green}$str${_ansi.none}';
}
