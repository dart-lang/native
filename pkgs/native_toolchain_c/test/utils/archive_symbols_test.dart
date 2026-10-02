// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:file/memory.dart';
import 'package:native_toolchain_c/src/utils/archive_symbols.dart';
import 'package:test/test.dart';

import 'fake_archive.dart';

void main() {
  final fileSystem = MemoryFileSystem.test();

  Set<String>? read(List<int> bytes) {
    final file = fileSystem.file('test.lib')..writeAsBytesSync(bytes);
    return readArchiveSymbols(file);
  }

  test('reads the symbol table', () {
    expect(read(archiveWithSymbols(['foo', '_bar', '?baz@@YAXXZ'])), {
      'foo',
      '_bar',
      '?baz@@YAXXZ',
    });
    expect(read(archiveWithSymbols([])), isEmpty);
  });

  test('only reads the symbol table', () {
    final member = List.filled(10, 0x41);
    expect(
      read([
        ...archiveWithSymbols(['foo']),
        ...archiveMemberHeader('foo.obj/', member).codeUnits,
        ...member,
      ]),
      {'foo'},
    );
  });

  test('returns null if the file does not exist', () {
    expect(readArchiveSymbols(fileSystem.file('missing.lib')), isNull);
  });

  test('returns null for files that are not archives', () {
    // The start of an x64 COFF object file.
    expect(read([0x64, 0x86, 0x02, 0x00, ...List.filled(80, 0)]), isNull);
    expect(read([]), isNull);
  });

  test('returns null for archives without a symbol table', () {
    expect(
      read(archiveWithSymbols(['foo'], symbolTableName: '__.SYMDEF')),
      isNull,
    );
    expect(
      read(archiveWithSymbols(['foo'], symbolTableName: '/SYM64/')),
      isNull,
    );
  });

  test('returns null for truncated archives', () {
    final archive = archiveWithSymbols(['foo', 'bar']);
    for (final length in [10, 68, 72, archive.length - 2]) {
      expect(
        read(Uint8List.sublistView(archive, 0, length)),
        isNull,
        reason: 'Truncated to $length bytes.',
      );
    }
  });

  test('returns null if the symbol count exceeds the symbol table', () {
    final archive = archiveWithSymbols(['foo']);
    // Overwrite the symbol count after the signature and member header.
    ByteData.sublistView(archive).setUint32(8 + 60, 1000, Endian.big);
    expect(read(archive), isNull);
  });
}
