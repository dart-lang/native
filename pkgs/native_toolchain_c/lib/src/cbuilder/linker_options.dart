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

  final LinkerScriptMode? _linkerScriptMode;

  /// Whether to strip debugging symbols from the binary.
  final bool stripDebug;

  /// The symbols to keep in the resulting binaries.
  final List<String> _symbols;

  final bool _keepAllSymbols;

  /// Create linking options manually for fine-grained control.
  ///
  /// If [symbolsToKeep] is null, all symbols will be kept.
  LinkerOptions.manual({
    List<String>? flags,
    bool? gcSections,
    Uri? linkerScript,
    this.stripDebug = true,
    Iterable<String>? symbolsToKeep,
  }) : _linkerFlags = flags ?? [],
       gcSections = gcSections ?? true,
       _symbols = symbolsToKeep?.toList(growable: false) ?? const [],
       _keepAllSymbols = symbolsToKeep == null,
       _linkerScriptMode = linkerScript != null
           ? ManualLinkerScript(script: linkerScript)
           : null;

  /// Create linking options to tree-shake symbols from the input files.
  ///
  /// The [symbolsToKeep] specify the symbols which should be kept. Passing
  /// `null` implies that all symbols should be kept.
  LinkerOptions.treeshake({
    Iterable<String>? flags,
    required Iterable<String>? symbolsToKeep,
    this.stripDebug = true,
  }) : _linkerFlags = flags?.toList(growable: false) ?? [],
       _symbols = symbolsToKeep?.toList(growable: false) ?? const [],
       _keepAllSymbols = symbolsToKeep == null,
       gcSections = true,
       _linkerScriptMode = symbolsToKeep != null
           ? GenerateLinkerScript()
           : null;

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

sealed class LinkerScriptMode {}

final class GenerateLinkerScript extends LinkerScriptMode {}

final class ManualLinkerScript extends LinkerScriptMode {
  /// The linker script to be passed via `--version-script`.
  ///
  /// See also the `ld` man page at https://linux.die.net/man/1/ld.
  final Uri script;

  ManualLinkerScript({required this.script});
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

  Iterable<String> _sourceFilesToFlagsForClangLike(
    Tool tool,
    Iterable<String> sourceFiles,
    OS targetOS,
  ) {
    switch (targetOS) {
      case OS.macOS || OS.iOS:
        return [
          if (!_keepAllSymbols) ...sourceFiles,
          ..._toLinkerSyntax(tool, [
            if (_keepAllSymbols) ...sourceFiles.map((e) => '-force_load,$e'),
            ..._linkerFlags,
            ..._symbols.map((symbol) => '-u,_$symbol'),
            '-encryptable',
            if (stripDebug) '-S',
            if (gcSections) '-dead_strip',
            if (_linkerScriptMode is ManualLinkerScript)
              '-exported_symbols_list,${_linkerScriptMode.script.toFilePath()}'
            else if (_linkerScriptMode is GenerateLinkerScript)
              '-exported_symbols_list,${_createMacSymbolList(_symbols)}',
          ]),
        ];

      case OS.android || OS.linux:
        final wholeArchiveSandwich =
            sourceFiles.any((source) => source.endsWith('.a')) ||
            _keepAllSymbols;
        return [
          if (wholeArchiveSandwich)
            ..._toLinkerSyntax(tool, ['--whole-archive']),
          ...sourceFiles,
          ..._toLinkerSyntax(tool, [
            ..._linkerFlags,
            ..._symbols.map((symbol) => '-u,$symbol'),
            if (stripDebug) '--strip-debug',
            if (gcSections) '--gc-sections',
            if (_linkerScriptMode is ManualLinkerScript)
              '--version-script=${_linkerScriptMode.script.toFilePath()}'
            else if (_linkerScriptMode is GenerateLinkerScript)
              '--version-script=${_createClangLikeLinkScript(_symbols)}',
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
    if (_keepAllSymbols) ...sourceFiles.map((e) => '/WHOLEARCHIVE:$e'),
    ..._linkerFlags,
    ..._symbols.map(
      (symbol) =>
          '/INCLUDE:${targetArch == Architecture.ia32 ? '_' : ''}$symbol',
    ),
    if (_linkerScriptMode is ManualLinkerScript)
      '/DEF:${_linkerScriptMode.script.toFilePath()}'
    else if (_linkerScriptMode is GenerateLinkerScript)
      '/DEF:${_createClLinkScript(_symbols)}',
    if (stripDebug) '/PDBSTRIPPED',
    if (gcSections) '/OPT:REF',
  ];

  /// This creates a list of exported symbols.
  ///
  /// If this is not set, some symbols might be kept. This can be inspected
  /// using `ld -why_live`, see https://www.unix.com/man_page/osx/1/ld/, where
  /// the reason will show up as `global-dont-strip`.
  /// This might possibly be a Rust only feature.
  static String _createMacSymbolList(Iterable<String> symbols) {
    final tempDir = Directory.systemTemp.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('exported_symbols_list.txt');
    final symbolsFile = File.fromUri(symbolsFileUri)..createSync();
    symbolsFile.writeAsStringSync(symbols.map((e) => '_$e').join('\n'));
    return symbolsFileUri.toFilePath();
  }

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
