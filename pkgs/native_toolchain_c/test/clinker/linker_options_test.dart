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

/// Host-independent tests of the linker flags for tree-shaking.
void main() {
  late MemoryFileSystem fileSystem;

  setUp(() {
    fileSystem = MemoryFileSystem.test(
      style: Platform.isWindows
          ? FileSystemStyle.windows
          : FileSystemStyle.posix,
    );
  });

  String archive(String name, List<String> symbols) =>
      (fileSystem.systemTempDirectory.childFile(
        name,
      )..writeAsBytesSync(archiveWithSymbols(symbols))).path;

  /// The exports of the module-definition file for linking [sources].
  List<String> exports(
    List<String> symbolsToKeep,
    List<String> sources, {
    Architecture architecture = Architecture.x64,
    Logger? logger,
  }) {
    final flags = LinkerOptions.treeshake(symbolsToKeep: symbolsToKeep)
        .sourceFilesToFlags(
          cl,
          sources,
          OS.windows,
          architecture,
          fileSystem,
          logger: logger,
        )
        .toList();
    expect(flags.where((flag) => flag.startsWith('/INCLUDE:')), isEmpty);
    final moduleDefinition = flags
        .singleWhere((flag) => flag.startsWith('/DEF:'))
        .substring('/DEF:'.length);
    final lines = fileSystem.file(moduleDefinition).readAsLinesSync();
    expect(lines.first, 'EXPORTS');
    return [for (final line in lines.skip(1)) line.trim()];
  }

  test('only exports symbols that the archives define', () {
    final records = <LogRecord>[];
    final logger = Logger.detached('')
      ..level = Level.ALL
      ..onRecord.listen(records.add);
    final sources = [
      archive('a.lib', ['foo', 'unused']),
      archive('b.lib', ['bar']),
    ];

    expect(exports(['foo', 'bar', 'missing'], sources, logger: logger), [
      'foo',
      'bar',
    ]);
    expect(records.single.message, contains('missing'));
  });

  test('matches the leading underscore of C symbols on 32-bit x86', () {
    final sources = [
      archive('a.lib', ['_foo', 'bar']),
    ];

    expect(exports(['foo', 'bar'], sources, architecture: Architecture.ia32), [
      'foo',
      'bar',
    ]);
    expect(exports(['foo', 'bar'], sources), ['bar']);
  });

  test('warns if the archives define none of the symbols', () {
    final records = <LogRecord>[];
    final logger = Logger.detached('')
      ..level = Level.ALL
      ..onRecord.listen(records.add);
    final sources = [
      archive('a.lib', ['_foo']),
    ];

    expect(exports(['foo'], sources, logger: logger), isEmpty);
    expect(records.single.level, Level.WARNING);
    expect(records.single.message, contains('foo'));
  });

  test('only includes symbols that the archives define with a manual '
      'module-definition file', () {
    final moduleDefinition = fileSystem.systemTempDirectory.childFile(
      'symbols.def',
    )..writeAsStringSync('EXPORTS\n    foo\n');
    final sources = [
      archive('a.lib', ['foo']),
    ];

    final flags = LinkerOptions.manual(
      symbolsToKeep: ['foo', 'missing'],
      linkerScript: moduleDefinition.uri,
    ).sourceFilesToFlags(cl, sources, OS.windows, Architecture.x64, fileSystem);
    expect(
      flags.where((flag) => flag.startsWith('/INCLUDE:')),
      ['/INCLUDE:foo'],
    );
    expect(flags, contains('/DEF:${moduleDefinition.path}'));
  });

  test('only keeps symbols that the archives define on macOS and iOS', () {
    final records = <LogRecord>[];
    final logger = Logger.detached('')
      ..level = Level.ALL
      ..onRecord.listen(records.add);
    // Mach-O symbols have a leading underscore.
    final sources = [
      (fileSystem.systemTempDirectory.childFile(
        'liba.a',
      )..writeAsBytesSync(bsdArchiveWithSymbols(['_foo', '_bar']))).path,
    ];

    for (final os in [OS.macOS, OS.iOS]) {
      final flags = LinkerOptions.treeshake(symbolsToKeep: ['foo', 'missing'])
          .sourceFilesToFlags(
            clang,
            sources,
            os,
            Architecture.arm64,
            fileSystem,
            logger: logger,
          )
          .toList();
      expect(flags, contains('-Wl,-u,_foo'));
      expect(flags, isNot(contains('-Wl,-u,_missing')));
      final exportedSymbols = flags
          .singleWhere((flag) => flag.startsWith('-Wl,-exported_symbols_list,'))
          .substring('-Wl,-exported_symbols_list,'.length);
      expect(fileSystem.file(exportedSymbols).readAsLinesSync(), ['_foo']);
    }
    expect(records, hasLength(2));
    expect(records.first.message, contains('missing'));
  });

  test('only keeps symbols that the archives define on Linux', () {
    final sources = [
      archive('liba.a', ['foo']),
    ];

    final flags = LinkerOptions.treeshake(symbolsToKeep: ['foo', 'missing'])
        .sourceFilesToFlags(
          clang,
          sources,
          OS.linux,
          Architecture.x64,
          fileSystem,
        )
        .toList();
    expect(flags, contains('-Wl,-u,foo'));
    expect(flags, isNot(contains('-Wl,-u,missing')));
    final versionScript = flags
        .singleWhere((flag) => flag.startsWith('-Wl,--version-script='))
        .substring('-Wl,--version-script='.length);
    final script = fileSystem.file(versionScript).readAsStringSync();
    expect(script, contains('foo;'));
    expect(script, isNot(contains('missing')));
  });

  test('exports all symbols if an input is not an archive', () {
    final object = (fileSystem.systemTempDirectory.childFile('b.obj')
      ..writeAsBytesSync([0x64, 0x86, ...List.filled(80, 0)]));
    final sources = [
      archive('a.lib', ['foo']),
      object.path,
    ];

    expect(exports(['foo', 'bar'], sources), ['foo', 'bar']);
  });
}
