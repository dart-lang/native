// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

export 'src/code_generator.dart' show Library;
export 'src/config_provider.dart' show Config;
export 'src/header_parser.dart' show parse;

final _logger = Logger('ffigen.generate');

/// Runs the entire generation pipeline for the given config.
void generate(Config config) {
  // Parse the bindings according to config object provided.
  final library = parse(config);

  // Generate files for the parsed bindings.
  final gen = File(config.output);
  library.generateFile(gen, format: config.formatOutput);
  _logger
      .info(successPen('Finished, Bindings generated in ${gen.absolute.path}'));

  final objCGen = File(config.outputObjC);
  if (library.generateObjCFile(objCGen)) {
    _logger.info(successPen('Finished, Objective C bindings generated '
        'in ${objCGen.absolute.path}'));
  }

  if (config.symbolFile != null) {
    final symbolFileGen = File(config.symbolFile!.output);
    library.generateSymbolOutputFile(
        symbolFileGen, config.symbolFile!.importPath);
    _logger.info(successPen(
        'Finished, Symbol Output generated in ${symbolFileGen.absolute.path}'));
  }
}
