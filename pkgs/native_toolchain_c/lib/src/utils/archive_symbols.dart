// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:file/file.dart';

/// Reads the names of the symbols that the members of the archive [file]
/// define, from the symbol table of the archive.
///
/// Supports the symbol tables of:
///
/// - System V and GNU archives (`.a` on Linux and Android), whose first member
///   `/` is a big-endian table, and COFF archives (`.lib` on Windows), whose
///   first linker member has the same format. See
///   https://learn.microsoft.com/windows/win32/debug/pe-format#first-linker-member.
/// - BSD archives (`.a` on macOS and iOS), whose first member `__.SYMDEF` or
///   `__.SYMDEF SORTED` (`__.SYMDEF_64` for a 64-bit table) is a little-endian
///   `ranlib` table. The symbols have the leading underscore of Mach-O.
///
/// Only reads the symbol table, not the rest of the archive.
///
/// Returns `null` if [file] can't be read or is not such an archive, for
/// example an object file, a universal binary, or an archive without a symbol
/// table.
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

/// The prefix of a BSD member name that is longer than [_nameLength], and in
/// archives created by Apple's tools of every name, followed by the length of
/// the name, which is stored at the start of the member data.
const _bsdLongNamePrefix = '#1/';

Set<String>? _readArchiveSymbols(RandomAccessFile input) {
  final bytes = input.readSync(_signature.length + _headerSize);
  if (bytes.length < _signature.length + _headerSize ||
      _ascii(bytes, 0, _signature.length) != _signature) {
    return null;
  }
  final header = Uint8List.sublistView(bytes, _signature.length);
  if (_ascii(header, _endOffset, _end.length) != _end) {
    return null;
  }
  var name = _ascii(header, _nameOffset, _nameLength).trimRight();
  final size = int.tryParse(
    _ascii(header, _sizeOffset, _sizeLength).trimRight(),
  );
  if (size == null || size < 0) {
    return null;
  }
  // The symbol table is the first member.
  var member = input.readSync(size);
  if (member.length < size) {
    return null;
  }
  if (name.startsWith(_bsdLongNamePrefix)) {
    final nameLength = int.tryParse(name.substring(_bsdLongNamePrefix.length));
    if (nameLength == null || nameLength < 0 || nameLength > member.length) {
      return null;
    }
    name = _nulTerminated(member, 0, nameLength);
    member = Uint8List.sublistView(member, nameLength);
  }
  return switch (name) {
    '/' => _parseSystemVSymbolTable(member),
    '__.SYMDEF' || '__.SYMDEF SORTED' => _parseBsdSymbolTable(
      member,
      wordSize: 4,
    ),
    '__.SYMDEF_64' || '__.SYMDEF_64 SORTED' => _parseBsdSymbolTable(
      member,
      wordSize: 8,
    ),
    _ => null,
  };
}

/// Parses a System V symbol table: the number of symbols (a big-endian 32-bit
/// integer), the offset of the member defining each symbol (unused here), and
/// the NUL-terminated symbol names.
Set<String>? _parseSystemVSymbolTable(Uint8List symbolTable) {
  if (symbolTable.length < 4) {
    return null;
  }
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
    symbols.add(_utf8(symbolTable, offset, end));
    offset = end + 1;
  }
  return symbols;
}

/// Parses a BSD symbol table: the size in bytes of the `ranlib` entries, the
/// entries, each the offset of the symbol name in the string table and the
/// offset of the member defining the symbol (unused here), the size of the
/// string table, and the string table of NUL-terminated symbol names. All
/// integers are little-endian and [wordSize] bytes wide.
Set<String>? _parseBsdSymbolTable(
  Uint8List symbolTable, {
  required int wordSize,
}) {
  final data = ByteData.sublistView(symbolTable);
  int word(int offset) => wordSize == 8
      ? data.getUint64(offset, Endian.little)
      : data.getUint32(offset, Endian.little);

  if (symbolTable.length < wordSize) {
    return null;
  }
  final entriesSize = word(0);
  final entrySize = 2 * wordSize;
  final stringsOffset = wordSize + entriesSize + wordSize;
  if (entriesSize % entrySize != 0 || stringsOffset > symbolTable.length) {
    return null;
  }
  final stringsSize = word(wordSize + entriesSize);
  if (stringsSize > symbolTable.length - stringsOffset) {
    return null;
  }
  final strings = Uint8List.sublistView(
    symbolTable,
    stringsOffset,
    stringsOffset + stringsSize,
  );
  final symbols = <String>{};
  for (
    var entry = wordSize;
    entry < wordSize + entriesSize;
    entry += entrySize
  ) {
    final start = word(entry);
    if (start >= strings.length) {
      return null;
    }
    final end = strings.indexOf(0, start);
    if (end == -1) {
      return null;
    }
    symbols.add(_utf8(strings, start, end));
  }
  return symbols;
}

String _ascii(Uint8List bytes, int offset, int length) =>
    String.fromCharCodes(bytes, offset, offset + length);

/// The string of up to [length] bytes at [offset], ending at the first NUL.
String _nulTerminated(Uint8List bytes, int offset, int length) {
  var end = bytes.indexOf(0, offset);
  if (end == -1 || end > offset + length) {
    end = offset + length;
  }
  return _ascii(bytes, offset, end - offset);
}

String _utf8(Uint8List bytes, int start, int end) => utf8.decode(
  Uint8List.sublistView(bytes, start, end),
  allowMalformed: true,
);
