// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:file/file.dart' show FileSystem;
import 'package:logging/logging.dart';

import '../native_toolchain/msvc.dart';
import '../native_toolchain/tool_likeness.dart';
import '../tool/tool.dart';
import '../utils/archive_symbols.dart';

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
  ///
  /// On Windows, only the [symbolsToKeep] that the input archives define are
  /// passed to the linker (as `/INCLUDE:` flags), see [LinkerOptions.treeshake].
  /// A [linkerScript] is passed as is.
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
  /// `null` implies that all symbols should be kept. Passing an empty list
  /// implies that no library will be output at all.
  ///
  /// On Windows, a DLL only exports the [symbolsToKeep] that the input
  /// archives define, as the linker fails if a symbol to export is not defined.
  /// The skipped symbols are logged. If an input is not an archive, such as an
  /// object file, all [symbolsToKeep] are exported, and linking fails if one of
  /// them is not defined.
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

  /// Whether to skip linking because no symbols are to be kept.
  bool get skipWholeLibrary => !_keepAllSymbols && _symbols.isEmpty;

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
    FileSystem fileSystem, {
    Logger? logger,
  }) {
    if (tool.isClangLike || tool.isLdLike) {
      return _sourceFilesToFlagsForClangLike(
        tool,
        sourceFiles,
        targetOS,
        fileSystem,
      );
    } else if (tool == cl) {
      return _sourceFilesToFlagsForCl(
        tool,
        sourceFiles,
        targetOS,
        targetArchitecture,
        fileSystem,
        logger,
      );
    } else {
      throw UnimplementedError('This package does not know how to run $tool.');
    }
  }

  Iterable<String> _sourceFilesToFlagsForClangLike(
    Tool tool,
    Iterable<String> sourceFiles,
    OS targetOS,
    FileSystem fileSystem,
  ) {
    switch (targetOS) {
      case .macOS || .iOS:
        return [
          if (!_keepAllSymbols) ...sourceFiles,
          ..._toLinkerSyntax(tool, [
            if (_keepAllSymbols) ...sourceFiles.map((e) => '-force_load,$e'),
            ..._linkerFlags,
            ..._symbols.map((symbol) => '-u,_$symbol'),
            if (stripDebug) '-S',
            if (gcSections) '-dead_strip',
            if (_linkerScriptMode is ManualLinkerScript)
              '-exported_symbols_list,${_linkerScriptMode.script.toFilePath()}'
            else if (_linkerScriptMode is GenerateLinkerScript)
              '-exported_symbols_list,'
                  '${_createMacSymbolList(_symbols, fileSystem)}',
          ]),
        ];

      case .android || .linux:
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
              '--version-script='
                  '${_createClangLikeLinkScript(_symbols, fileSystem)}',
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
    FileSystem fileSystem,
    Logger? logger,
  ) {
    final symbols = _definedSymbols(
      sourceFiles,
      targetArch,
      fileSystem,
      logger,
    );
    return [
      ...sourceFiles,
      '/link',
      if (_keepAllSymbols) ...sourceFiles.map((e) => '/WHOLEARCHIVE:$e'),
      ..._linkerFlags,
      // The generated module-definition file exports, and therefore keeps, all
      // symbols. Passing an `/INCLUDE:` per symbol as well is redundant, and
      // for thousands of symbols exceeds the 32,767 character command-line
      // limit of Windows.
      if (_linkerScriptMode is! GenerateLinkerScript)
        ...symbols.map(
          (symbol) => '/INCLUDE:${targetArch == .ia32 ? '_' : ''}$symbol',
        ),
      if (_linkerScriptMode is ManualLinkerScript)
        '/DEF:${_linkerScriptMode.script.toFilePath()}'
      else if (_linkerScriptMode is GenerateLinkerScript)
        '/DEF:${_createClLinkScript(symbols, fileSystem)}',
      if (stripDebug) '/PDBSTRIPPED',
      if (gcSections) '/OPT:REF',
    ];
  }

  /// The symbols to keep that [sourceFiles] define.
  ///
  /// The linker fails if a symbol to include or to export is not defined, and
  /// tree-shaking can ask for symbols that a library doesn't define, for
  /// example functions that are not available on the target.
  ///
  /// Returns all symbols to keep if one of the [sourceFiles] is not an archive
  /// with a symbol table, such as an object file.
  List<String> _definedSymbols(
    Iterable<String> sourceFiles,
    Architecture targetArch,
    FileSystem fileSystem,
    Logger? logger,
  ) {
    if (_symbols.isEmpty || sourceFiles.isEmpty) return _symbols;
    final defined = <String>{};
    for (final sourceFile in sourceFiles) {
      final symbols = readArchiveSymbols(fileSystem.file(sourceFile));
      if (symbols == null) return _symbols;
      defined.addAll(symbols);
    }
    final result = <String>[];
    final undefined = <String>[];
    for (final symbol in _symbols) {
      // C symbols have a leading underscore on 32-bit x86.
      if (defined.contains(symbol) ||
          (targetArch == .ia32 && defined.contains('_$symbol'))) {
        result.add(symbol);
      } else {
        undefined.add(symbol);
      }
    }
    if (result.isEmpty) {
      // Most likely a mistake, such as symbol names with a prefix the archives
      // don't have, and the library would export nothing.
      logger?.warning(
        'None of the ${_symbols.length} symbols to keep is defined by '
        '${sourceFiles.join(', ')}: ${undefined.join(', ')}',
      );
    } else if (undefined.isNotEmpty) {
      logger?.info(
        'Skipping ${undefined.length} symbols to keep that '
        '${sourceFiles.join(', ')} do not define: ${undefined.join(', ')}',
      );
    }
    return result;
  }

  /// This creates a list of exported symbols.
  ///
  /// If this is not set, some symbols might be kept. This can be inspected
  /// using `ld -why_live`, see https://www.unix.com/man_page/osx/1/ld/, where
  /// the reason will show up as `global-dont-strip`.
  /// This might possibly be a Rust only feature.
  static String _createMacSymbolList(
    Iterable<String> symbols,
    FileSystem fileSystem,
  ) {
    final tempDir = fileSystem.systemTempDirectory.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('exported_symbols_list.txt');
    final symbolsFile = fileSystem.file(symbolsFileUri)..createSync();
    symbolsFile.writeAsStringSync(symbols.map((e) => '_$e').join('\n'));
    return symbolsFileUri.toFilePath();
  }

  static String _createClangLikeLinkScript(
    Iterable<String> symbols,
    FileSystem fileSystem,
  ) {
    final tempDir = fileSystem.systemTempDirectory.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('symbols.lds');
    final symbolsFile = fileSystem.file(symbolsFileUri)..createSync();
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

  static String _createClLinkScript(
    Iterable<String> symbols,
    FileSystem fileSystem,
  ) {
    final tempDir = fileSystem.systemTempDirectory.createTempSync();
    final symbolsFileUri = tempDir.uri.resolve('symbols.def');
    final symbolsFile = fileSystem.file(symbolsFileUri)..createSync();
    symbolsFile.writeAsStringSync(
      ['EXPORTS', for (final symbol in symbols) '    $symbol', ''].join('\n'),
    );
    return symbolsFileUri.toFilePath();
  }
}
