// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_logging.dart' show Ansi;
import 'package:logging/logging.dart';

import 'config_provider.dart' show FfiGen;
import 'header_parser.dart' show parse;

final _ansi = Ansi(Ansi.terminalSupportsAnsi);

extension FfiGenGenerator on FfiGen {
  /// Runs the entire generation pipeline for the given config.
  void generate(Logger logger) {
    final context = Context(logger, this);

    // Parse the bindings according to config object provided.
    final library = parse(context);

    // Generate files for the parsed bindings.
    final gen = File(output.toFilePath());
    library.generateFile(gen, format: formatOutput);
    logger.info(
      _successPen('Finished, Bindings generated in ${gen.absolute.path}'),
    );

    final objCGen = File(outputObjC.toFilePath());
    if (library.generateObjCFile(objCGen)) {
      logger.info(
        _successPen(
          'Finished, Objective C bindings generated '
          'in ${objCGen.absolute.path}',
        ),
      );
    }

    if (symbolFile != null) {
      final symbolFileGen = File(symbolFile!.output.toFilePath());
      library.generateSymbolOutputFile(
        symbolFileGen,
        symbolFile!.importPath.toString(),
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
