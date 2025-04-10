// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets.dart';

import '../native_toolchain/tool_likeness.dart';
import '../tool/tool.dart';

/// Options to pass to the linker.
///
/// These can be manually set via the [LinkerOptions.manual] constructor.
/// Alternatively, if the goal of the linking is to treeshake unused symbols,
/// the [LinkerOptions.treeshake] constructor can be used.
class LinkerOptions {
  /// The flags to be passed to the linker. As they depend on the linker being
  /// invoked, the actual usage is via the [postSourcesFlags] method.
  final List<String> linkerFlags;

  /// Enable garbage collection of unused input sections.
  ///
  /// See also the `ld` man page at https://linux.die.net/man/1/ld.
  final bool gcSections;

  /// The linker script to be passed via `--version-script`.
  ///
  /// See also the `ld` man page at https://linux.die.net/man/1/ld.
  final Uri? linkerScript;

  /// Whether to include all symbols from the sources.
  ///
  /// This is achieved by setting the `whole-archive` flag before passing the
  /// sources, and the `no-whole-archive` flag after.
  final bool includeAllSymbols;

  final bool linkStandardLibraries;

  final bool stripDebug;

  /// Create linking options manually for fine-grained control.
  LinkerOptions.manual({
    List<String>? flags,
    bool? gcSections,
    this.linkerScript,
    this.linkStandardLibraries = true,
    this.includeAllSymbols = true,
    this.stripDebug = true,
  }) : linkerFlags = flags ?? [],
       gcSections = gcSections ?? true;

  /// Create linking options to tree-shake symbols from the input files.
  ///
  /// The [symbols] specify the symbols which should be kept.
  LinkerOptions.treeshake({
    Iterable<String>? flags,
    required Iterable<String>? symbols,
    this.linkStandardLibraries = true,
    this.stripDebug = true,
  }) : linkerFlags =
           <String>[
             ...flags ?? [],
             if (symbols != null)
               ...symbols.expand(
                 (e) => ['-u', (OS.current == OS.macOS ? '_' : '') + e],
               ),
           ].toList(),
       gcSections = true,
       includeAllSymbols = symbols == null,
       linkerScript = _createLinkerScript(symbols);

  Iterable<String> toLinkerSyntax(Tool linker, List<String> flagList) {
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
