// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:file/file.dart';

/// Reads the names of the symbols that the members of the archive [file]
/// define, from the symbol table of the archive.
///
/// Supports the symbol table that COFF archives (`.lib`) store in their first
/// linker member, which has the same format as the symbol table of System V
/// and GNU archives (`.a`). See
/// https://learn.microsoft.com/windows/win32/debug/pe-format#first-linker-member.
///
/// Only reads the symbol table, not the rest of the archive.
///
/// Returns `null` if [file] can't be read or is not such an archive, for
/// example an object file or an archive without a symbol table.
Set<String>? readArchiveSymbols(File file) {
  try {
    final input = file.openSync();
    try {
      return _readArchiveSymbols(input);
    } finally {
      input.closeSync();
    }
  } on FileSystemException {
    return null;
  }
}

const _signature = '!<arch>\n';

// An archive member header consists of the name (16 bytes), modification date
// (12), user ID (6), group ID (6), mode (8), size (10), and the end
// characters (2), all as ASCII text.
const _headerSize = 60;
const _nameOffset = 0;
const _nameLength = 16;
const _sizeOffset = 48;
const _sizeLength = 10;
const _endOffset = 58;
const _end = '`\n';

Set<String>? _readArchiveSymbols(RandomAccessFile input) {
  final bytes = input.readSync(_signature.length + _headerSize);
  if (bytes.length < _signature.length + _headerSize ||
      _ascii(bytes, 0, _signature.length) != _signature) {
    return null;
  }
  final header = Uint8List.sublistView(bytes, _signature.length);
  // The symbol table is the first member, named `/`.
  if (_ascii(header, _nameOffset, _nameLength).trimRight() != '/' ||
      _ascii(header, _endOffset, _end.length) != _end) {
    return null;
  }
  final size = int.tryParse(
    _ascii(header, _sizeOffset, _sizeLength).trimRight(),
  );
  if (size == null || size < 4) {
    return null;
  }
  final symbolTable = input.readSync(size);
  if (symbolTable.length < size) {
    return null;
  }
  return _parseSymbolTable(symbolTable);
}

/// Parses a symbol table: the number of symbols (a big-endian 32-bit integer),
/// the offset of the member defining each symbol (unused here), and the
/// NUL-terminated symbol names.
Set<String>? _parseSymbolTable(Uint8List symbolTable) {
  final count = ByteData.sublistView(symbolTable).getUint32(0, Endian.big);
  var offset = 4 + 4 * count;
  if (offset > symbolTable.length) {
    return null;
  }
  final symbols = <String>{};
  for (var i = 0; i < count; i++) {
    final end = symbolTable.indexOf(0, offset);
    if (end == -1) {
      return null;
    }
    symbols.add(
      utf8.decode(
        Uint8List.sublistView(symbolTable, offset, end),
        allowMalformed: true,
      ),
    );
    offset = end + 1;
  }
  return symbols;
}

String _ascii(Uint8List bytes, int offset, int length) =>
    String.fromCharCodes(bytes, offset, offset + length);
