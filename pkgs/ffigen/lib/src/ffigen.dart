// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_logging.dart' show Ansi;
import 'package:ffigen_symbols/ffigen_symbols.dart';
import 'package:logging/logging.dart';

import 'config_provider.dart' show FfiGenerator, FfiGeneratorResult;
import 'context.dart';
import 'header_parser.dart' show parse;
import 'logger.dart';

final _ansi = Ansi(Ansi.terminalSupportsAnsi);

extension FfiGenGenerator on FfiGenerator {
  /// Runs the entire generation pipeline for the given config.
  ///
  /// If provided, uses [logger] to output logs. Otherwise, uses a default
  /// logger that streams [Level.WARNING] to stdout and higher levels to stderr.
  Future<FfiGeneratorResult> generate({
    Logger? logger,
    Uri? libclangDylib,
  }) async {
    logger ??= createDefaultLogger();
    final context = Context(logger, this, libclangDylib: libclangDylib);

    // Parse the bindings according to config object provided.
    final library = parse(context);

    // Generate files for the parsed bindings.
    final gen = File(output.dart.path.toFilePath());
    await library.generateFile(gen, format: output.format);
    logger.info(
      _successPen('Finished, Bindings generated in ${gen.absolute.path}'),
    );

    File? objCFile;
    final objCGen = File(output.objCFile.toFilePath());
    if (library.generateObjCFile(objCGen)) {
      objCFile = objCGen;
      logger.info(
        _successPen(
          'Finished, Objective C bindings generated '
          'in ${objCGen.absolute.path}',
        ),
      );
    }

    File? cppFile;
    final cppGen = File(output.cppBindingsFile.toFilePath());
    if (library.generateCppFile(cppGen)) {
      cppFile = cppGen;
      logger.info(
        _successPen(
          'Finished, Cpp bindings generated in ${cppGen.absolute.path}',
        ),
      );
    }

    File? recordUseMappingGen;
    final recordUseMappingFile = output.recordUseMapping;
    if (recordUseMappingFile != null) {
      final file = File(recordUseMappingFile.toFilePath());
      if (await library.generateRecordUseMappingFile(
        file,
        format: output.format,
      )) {
        recordUseMappingGen = file;
        logger.info(
          _successPen(
            'Finished, RecordUse Mapping generated '
            'in ${file.absolute.path}',
          ),
        );
      }
    }

    FfigenSymbols? symbols;
    File? symbolFileGen;
    final symbolFile = output.symbolFile;
    if (symbolFile != null) {
      final symbolFileOutput = symbolFile.output;
      if (symbolFileOutput != null) {
        symbolFileGen = File(symbolFileOutput.toFilePath());
        symbols = library.generateSymbolOutputFile(
          symbolFileGen,
          symbolFile.importPath.toString(),
        );
        logger.info(
          _successPen(
            'Finished, Symbol Output generated in '
            '${symbolFileGen.absolute.path}',
          ),
        );
      } else {
        symbols = library.createSymbols(symbolFile.importPath.toString());
      }
    }

    return FfiGeneratorResult(
      dartFile: gen,
      symbols: symbols,
      objCFile: objCFile,
      cppFile: cppFile,
      symbolFile: symbolFileGen,
      recordUseMappingFile: recordUseMappingGen,
    );
  }

  static String _successPen(String str) => '${_ansi.green}$str${_ansi.none}';
}
