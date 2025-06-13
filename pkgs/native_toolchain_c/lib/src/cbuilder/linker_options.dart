// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';

import '../native_toolchain/tool_likeness.dart';
import '../tool/tool.dart';

/// Options to pass to the linker.
///
/// These can be manually set via the [LinkerOptions.manual] constructor.
/// Alternatively, if the goal of the linking is to treeshake unused symbols,
/// the [LinkerOptions.treeshake] constructor can be used.
class LinkerOptions {
  /// The flags to be passed to the linker. As they depend on the linker being
  /// invoked, the actual usage is via the [sourceFilesToFlags] method.
  final List<String> _linkerFlags;

  /// Enable garbage collection of unused input sections.
  ///
  /// See also the `ld` man page at https://linux.die.net/man/1/ld.
  final bool gcSections;

  /// The linker script to be passed via `--version-script`.
  ///
  /// See also the `ld` man page at https://linux.die.net/man/1/ld.
  final Uri? linkerScript;

  /// Whether to strip debugging symbols from the binary.
  final bool stripDebug;

  /// The symbols to keep in the resulting binaries.
  final List<String>? _symbolsToKeep;

  /// Create linking options manually for fine-grained control.
  LinkerOptions.manual({
    List<String>? flags,
    bool? gcSections,
    this.linkerScript,
    this.stripDebug = true,
    Iterable<String>? symbolsToKeep,
  }) : _linkerFlags = flags ?? [],
       gcSections = gcSections ?? true,
       _symbolsToKeep = symbolsToKeep?.toList(growable: false);

  /// Create linking options to tree-shake symbols from the input files.
  ///
  /// The [symbols] specify the symbols which should be kept.
  LinkerOptions.treeshake({
    Iterable<String>? flags,
    required Iterable<String>? symbols,
    this.stripDebug = true,
  }) : _linkerFlags = flags?.toList(growable: false) ?? [],
       _symbolsToKeep = symbols?.toList(growable: false),
       gcSections = true,
       linkerScript = _createLinkerScript(symbols);

  Iterable<String> _toLinkerSyntax(Tool linker, Iterable<String> flagList) {
    if (linker.isClangLike) {
      return flagList.map((e) => '-Wl,$e');
    } else if (linker.isLdLike) {
      return flagList;
    } else {
      throw UnsupportedError('Linker flags for $linker are not supported');
    }
  }

  static Uri? _createLinkerScript(Iterable<String>? symbols) {
    if (symbols == null) return null;
    final tempDir = Directory.systemTemp.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('symbols.lds');
    final symbolsFile = File.fromUri(symbolsFileUri)..createSync();
    symbolsFile.writeAsStringSync('''
{
  global:
    ${symbols.map((e) => '$e;').join('\n    ')}
  local:
    *;
};
''');
    return symbolsFileUri;
  }
}

extension LinkerOptionsExt on LinkerOptions {
  /// Takes [sourceFiles] and turns it into flags for the compiler driver while
  /// considering the current [LinkerOptions].
  Iterable<String> sourceFilesToFlags(
    Tool tool,
    Iterable<String> sourceFiles,
    OS targetOS,
  ) {
    final includeAllSymbols = _symbolsToKeep == null;

    if (targetOS == OS.macOS) {
      return [
        if (!includeAllSymbols) ...sourceFiles,
        ..._toLinkerSyntax(tool, [
          if (includeAllSymbols) ...sourceFiles.map((e) => '-force_load,$e'),
          ..._linkerFlags,
          ..._symbolsToKeep?.map((symbol) => '-u,_$symbol') ?? [],
          if (stripDebug) '-S',
          if (gcSections) '-dead_strip',
        ]),
      ];
    }

    final wholeArchiveSandwich =
        sourceFiles.any((source) => source.endsWith('.a')) || includeAllSymbols;

    return [
      if (wholeArchiveSandwich) ..._toLinkerSyntax(tool, ['--whole-archive']),
      ...sourceFiles,
      ..._toLinkerSyntax(tool, [
        ..._linkerFlags,
        ..._symbolsToKeep?.map((symbol) => '-u,$symbol') ?? [],
        if (stripDebug) '--strip-debug',
        if (gcSections) '--gc-sections',
        if (linkerScript != null)
          '--version-script=${linkerScript!.toFilePath()}',
        if (wholeArchiveSandwich) '--no-whole-archive',
      ]),
    ];
  }
}
