// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:code_assets/code_assets.dart';
import 'package:file/memory.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/src/cbuilder/linker_options.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:test/test.dart';

import '../utils/fake_archive.dart';

/// Host-independent tests of keeping only the symbols that the input archives
/// define, and of the linker flags that result.
void main() {
  late MemoryFileSystem fileSystem;
  late List<LogRecord> logRecords;
  late Logger logger;

  setUp(() {
    fileSystem = MemoryFileSystem.test(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix,
    );
    logRecords = [];
    logger = Logger.detached('')
      ..level = Level.ALL
      ..onRecord.listen(logRecords.add);
  });

  Uri file(String name, List<int> contents) =>
      (fileSystem.systemTempDirectory.childFile(
        name,
      )..writeAsBytesSync(contents)).uri;

  /// A COFF or GNU archive whose symbol table lists [symbols].
  Uri archive(String name, List<String> symbols) =>
      file(name, archiveWithSymbols(symbols));

  /// A BSD archive, as on macOS and iOS, whose symbol table lists [symbols].
  Uri bsdArchive(String name, List<String> symbols) =>
      file(name, bsdArchiveWithSymbols(symbols));

  /// The symbols that [LinkerOptions.treeshake] keeps for [sources], read from
  /// the flags for [tool].
  List<String> symbolsKept(
    List<String> symbolsToKeep,
    List<Uri> sources, {
    OS targetOS = OS.windows,
    Architecture targetArchitecture = Architecture.x64,
  }) {
    final options = LinkerOptions.treeshake(symbolsToKeep: symbolsToKeep)
        .withSymbolsDefinedIn(
          sources,
          targetOS: targetOS,
          targetArchitecture: targetArchitecture,
          fileSystem: fileSystem,
          logger: logger,
        );
    final flags = options
        .sourceFilesToFlags(
          targetOS == OS.windows ? cl : clang,
          sources.map((source) => source.toFilePath()),
          targetOS,
          targetArchitecture,
          fileSystem,
        )
        .toList();
    // The generated module-definition file, exported symbols list, or version
    // script lists the symbols; so do the `-u` flags outside of Windows.
    switch (targetOS) {
      case OS.windows:
        expect(flags.where((flag) => flag.startsWith('/INCLUDE:')), isEmpty);
        final lines = fileSystem
            .file(
              flags
                  .singleWhere((flag) => flag.startsWith('/DEF:'))
                  .substring('/DEF:'.length),
            )
            .readAsLinesSync();
        expect(lines.first, 'EXPORTS');
        return [for (final line in lines.skip(1)) line.trim()];
      case OS.macOS || OS.iOS:
        final symbols = flags
            .where((flag) => flag.startsWith('-Wl,-u,_'))
            .map((flag) => flag.substring('-Wl,-u,_'.length))
            .toList();
        final exported = fileSystem
            .file(
              flags
                  .singleWhere(
                    (flag) => flag.startsWith('-Wl,-exported_symbols_list,'),
                  )
                  .substring('-Wl,-exported_symbols_list,'.length),
            )
            .readAsLinesSync();
        expect(exported, symbols.map((symbol) => '_$symbol'));
        return symbols;
      case _:
        final symbols = flags
            .where((flag) => flag.startsWith('-Wl,-u,'))
            .map((flag) => flag.substring('-Wl,-u,'.length))
            .toList();
        final script = fileSystem
            .file(
              flags
                  .singleWhere(
                    (flag) => flag.startsWith('-Wl,--version-script='),
                  )
                  .substring('-Wl,--version-script='.length),
            )
            .readAsStringSync();
        for (final symbol in symbolsToKeep) {
          expect(script.contains('$symbol;'), symbols.contains(symbol));
        }
        return symbols;
    }
  }

  test('keeps only the symbols that the archives define', () {
    final sources = [
      archive('a.lib', ['foo', 'unused']),
      archive('b.lib', ['bar']),
    ];

    expect(symbolsKept(['foo', 'bar', 'missing'], sources), ['foo', 'bar']);
    expect(logRecords.single.level, Level.INFO);
    expect(logRecords.single.message, contains('missing'));
  });

  test('matches the leading underscore of C symbols on 32-bit x86', () {
    final sources = [
      archive('a.lib', ['_foo', 'bar']),
    ];

    expect(
      symbolsKept(['foo', 'bar'], sources, targetArchitecture: .ia32),
      ['foo', 'bar'],
    );
    expect(symbolsKept(['foo', 'bar'], sources), ['bar']);
  });

  test('matches the leading underscore of Mach-O symbols', () {
    final sources = [
      bsdArchive('liba.a', ['_foo', '_bar']),
    ];

    for (final os in [OS.macOS, OS.iOS]) {
      expect(
        symbolsKept(
          ['foo', 'missing'],
          sources,
          targetOS: os,
          targetArchitecture: .arm64,
        ),
        ['foo'],
        reason: '$os',
      );
    }
  });

  test('keeps only the symbols that the archives define on Linux', () {
    final sources = [
      archive('liba.a', ['foo']),
    ];

    expect(symbolsKept(['foo', 'missing'], sources, targetOS: .linux), [
      'foo',
    ]);
  });

  test('warns if the archives define none of the symbols', () {
    final sources = [
      archive('a.lib', ['_foo']),
    ];

    expect(symbolsKept(['foo'], sources), isEmpty);
    expect(logRecords.single.level, Level.WARNING);
    expect(logRecords.single.message, contains('foo'));
  });

  test('keeps all symbols if an input is not an archive', () {
    final sources = [
      archive('a.lib', ['foo']),
      // The start of an x64 COFF object file.
      file('b.obj', [0x64, 0x86, 0x02, 0x00, ...List.filled(80, 0)]),
    ];

    expect(symbolsKept(['foo', 'bar'], sources), ['foo', 'bar']);
    expect(logRecords, isEmpty);
  });

  test('also applies to the /INCLUDE flags of manual options', () {
    final moduleDefinition = file(
      'symbols.def',
      'EXPORTS\n    foo\n'.codeUnits,
    );
    final sources = [
      archive('a.lib', ['foo']),
    ];

    final flags =
        LinkerOptions.manual(
              symbolsToKeep: ['foo', 'missing'],
              linkerScript: moduleDefinition,
            )
            .withSymbolsDefinedIn(
              sources,
              targetOS: .windows,
              targetArchitecture: .x64,
              fileSystem: fileSystem,
            )
            .sourceFilesToFlags(
              cl,
              sources.map((source) => source.toFilePath()),
              .windows,
              .x64,
              fileSystem,
            );
    expect(flags.where((flag) => flag.startsWith('/INCLUDE:')), [
      '/INCLUDE:foo',
    ]);
    expect(flags, contains('/DEF:${moduleDefinition.toFilePath()}'));
  });
}
