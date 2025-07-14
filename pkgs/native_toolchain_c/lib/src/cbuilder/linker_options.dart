// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';

import '../native_toolchain/msvc.dart';
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
  ///
  /// If null all symbols will be kept.
  final List<String>? _symbolsToKeep;

  final bool _generateLinkerScript;

  /// Create linking options manually for fine-grained control.
  LinkerOptions.manual({
    List<String>? flags,
    bool? gcSections,
    this.linkerScript,
    this.stripDebug = true,
    Iterable<String>? symbolsToKeep,
  }) : _linkerFlags = flags ?? [],
       gcSections = gcSections ?? true,
       _symbolsToKeep = symbolsToKeep?.toList(growable: false),
       _generateLinkerScript = false;

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
       linkerScript = null,
       _generateLinkerScript = symbols != null;

  Iterable<String> _toLinkerSyntax(Tool linker, Iterable<String> flagList) {
    if (linker.isClangLike) {
      return flagList.map((e) => '-Wl,$e');
    } else if (linker.isLdLike) {
      return flagList;
    } else {
      throw UnsupportedError('Linker flags for $linker are not supported');
    }
  }
}

extension LinkerOptionsExt on LinkerOptions {
  /// Takes [sourceFiles] and turns it into flags for the compiler driver while
  /// considering the current [LinkerOptions].
  Iterable<String> sourceFilesToFlags(
    Tool tool,
    Iterable<String> sourceFiles,
    OS targetOS,
    Architecture targetArchitecture,
  ) {
    if (tool.isClangLike || tool.isLdLike) {
      return _sourceFilesToFlagsForClangLike(tool, sourceFiles, targetOS);
    } else if (tool == cl) {
      return _sourceFilesToFlagsForCl(
        tool,
        sourceFiles,
        targetOS,
        targetArchitecture,
      );
    } else {
      throw UnimplementedError('This package does not know how to run $tool.');
    }
  }

  bool get _includeAllSymbols => _symbolsToKeep == null;

  Iterable<String> _sourceFilesToFlagsForClangLike(
    Tool tool,
    Iterable<String> sourceFiles,
    OS targetOS,
  ) {
    switch (targetOS) {
      case OS.macOS || OS.iOS:
        return [
          if (!_includeAllSymbols) ...sourceFiles,
          ..._toLinkerSyntax(tool, [
            if (_includeAllSymbols) ...sourceFiles.map((e) => '-force_load,$e'),
            ..._linkerFlags,
            ..._symbolsToKeep?.map((symbol) => '-u,_$symbol') ?? [],
            if (stripDebug) '-S',
            if (gcSections) '-dead_strip',
          ]),
        ];

      case OS.android || OS.linux:
        final wholeArchiveSandwich =
            sourceFiles.any((source) => source.endsWith('.a')) ||
            _includeAllSymbols;
        return [
          if (wholeArchiveSandwich)
            ..._toLinkerSyntax(tool, ['--whole-archive']),
          ...sourceFiles,
          ..._toLinkerSyntax(tool, [
            ..._linkerFlags,
            ..._symbolsToKeep?.map((symbol) => '-u,$symbol') ?? [],
            if (stripDebug) '--strip-debug',
            if (gcSections) '--gc-sections',
            if (linkerScript != null)
              '--version-script=${linkerScript!.toFilePath()}'
            else if (_generateLinkerScript && _symbolsToKeep != null)
              '--version-script=${_createClangLikeLinkScript(_symbolsToKeep)}',
            if (wholeArchiveSandwich) '--no-whole-archive',
          ]),
        ];
      case OS():
        throw UnimplementedError();
    }
  }

  Iterable<String> _sourceFilesToFlagsForCl(
    Tool tool,
    Iterable<String> sourceFiles,
    OS targetOS,
    Architecture targetArch,
  ) => [
    ...sourceFiles,
    '/link',
    if (_includeAllSymbols) ...sourceFiles.map((e) => '/WHOLEARCHIVE:$e'),
    ..._linkerFlags,
    ..._symbolsToKeep?.map(
          (symbol) =>
              '/INCLUDE:${targetArch == Architecture.ia32 ? '_' : ''}$symbol',
        ) ??
        [],
    if (linkerScript != null)
      '/DEF:${linkerScript!.toFilePath()}'
    else if (_generateLinkerScript && _symbolsToKeep != null)
      '/DEF:${_createClLinkScript(_symbolsToKeep)}',
    if (stripDebug) '/PDBSTRIPPED',
    if (gcSections) '/OPT:REF',
  ];

  static String _createClangLikeLinkScript(Iterable<String> symbols) {
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
    return symbolsFileUri.toFilePath();
  }

  static String _createClLinkScript(Iterable<String> symbols) {
    final tempDir = Directory.systemTemp.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('symbols.def');
    final symbolsFile = File.fromUri(symbolsFileUri)..createSync();
    symbolsFile.writeAsStringSync('''
LIBRARY MyDLL
EXPORTS
${symbols.map((s) => '    $s').join('\n')}      
''');
    return symbolsFileUri.toFilePath();
  }
}
