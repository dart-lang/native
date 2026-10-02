// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

/// Creates an archive containing only a symbol table that lists [symbols],
/// like the first linker member of a COFF archive.
Uint8List archiveWithSymbols(
  List<String> symbols, {
  String symbolTableName = '/',
}) {
  final names = BytesBuilder();
  for (final symbol in symbols) {
    names
      ..add(utf8.encode(symbol))
      ..addByte(0);
  }
  final symbolTable =
      (BytesBuilder()
            ..add(
              (ByteData(
                4,
              )..setUint32(0, symbols.length, Endian.big)).buffer.asUint8List(),
            )
            // The offsets of the members defining the symbols.
            ..add(Uint8List(4 * symbols.length))
            ..add(names.takeBytes()))
          .takeBytes();
  return (BytesBuilder()
        ..add(ascii.encode('!<arch>\n'))
        ..add(ascii.encode(archiveMemberHeader(symbolTableName, symbolTable)))
        ..add(symbolTable)
        // Members are aligned to two bytes.
        ..add(symbolTable.length.isOdd ? [0x0a] : []))
      .takeBytes();
}

/// The header of an archive member named [name] with [contents].
String archiveMemberHeader(String name, List<int> contents) => [
  name.padRight(16),
  '0'.padRight(12), // Modification date.
  '0'.padRight(6), // User ID.
  '0'.padRight(6), // Group ID.
  '644'.padRight(8), // Mode.
  '${contents.length}'.padRight(10),
  '`\n',
].join();
