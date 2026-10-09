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

/// Creates a BSD archive containing only a symbol table that lists [symbols],
/// like the first member of an archive created by Apple's `ar` or `libtool`.
///
/// The member is named [symbolTableName]. With [longName], the name is stored
/// at the start of the member data, after a `#1/<length>` header name, like
/// Apple's tools store every name; otherwise in the header, which fits
/// `__.SYMDEF SORTED` exactly. The integers are [wordSize] bytes wide.
Uint8List bsdArchiveWithSymbols(
  List<String> symbols, {
  String symbolTableName = '__.SYMDEF SORTED',
  bool longName = true,
  int wordSize = 4,
}) {
  final strings = BytesBuilder();
  final offsets = <int>[];
  for (final symbol in symbols) {
    offsets.add(strings.length);
    strings
      ..add(utf8.encode(symbol))
      ..addByte(0);
  }
  final stringTable = strings.takeBytes();
  Uint8List word(int value) {
    final data = ByteData(wordSize);
    if (wordSize == 8) {
      data.setUint64(0, value, Endian.little);
    } else {
      data.setUint32(0, value, Endian.little);
    }
    return data.buffer.asUint8List();
  }

  final symbolTable = BytesBuilder();
  // Apple's tools pad the name to a multiple of four bytes.
  final storedName = longName
      ? utf8.encode(
          symbolTableName.padRight(
            (symbolTableName.length + 3) ~/ 4 * 4,
            '\x00',
          ),
        )
      : <int>[];
  symbolTable
    ..add(storedName)
    ..add(word(offsets.length * 2 * wordSize));
  for (final offset in offsets) {
    symbolTable
      ..add(word(offset))
      // The offset of the member defining the symbol.
      ..add(word(0));
  }
  symbolTable
    ..add(word(stringTable.length))
    ..add(stringTable);
  final contents = symbolTable.takeBytes();
  final headerName = longName ? '#1/${storedName.length}' : symbolTableName;
  return (BytesBuilder()
        ..add(ascii.encode('!<arch>\n'))
        ..add(ascii.encode(archiveMemberHeader(headerName, contents)))
        ..add(contents)
        ..add(contents.length.isOdd ? [0x0a] : []))
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
