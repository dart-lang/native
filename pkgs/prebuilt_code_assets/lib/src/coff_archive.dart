// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:native_toolchain_c/native_toolchain_c.dart';

/// Reads the symbols defined by the members of a Windows COFF `.lib` [archive]
/// from its first linker member.
///
/// See https://learn.microsoft.com/windows/win32/debug/pe-format#first-linker-member.
Set<String> parseCoffArchiveSymbols(Uint8List archive) {
  const signature = '!<arch>\n';
  const memberHeaderSize = 60;
  const start = signature.length + memberHeaderSize;
  if (archive.length < start + 4 ||
      String.fromCharCodes(archive, 0, signature.length) != signature ||
      String.fromCharCodes(archive, signature.length, 24).trimRight() != '/') {
    throw const FormatException('Not an archive with a linker member.');
  }
  final count = ByteData.sublistView(archive).getUint32(start, Endian.big);
  // The member offsets are followed by the NUL-terminated symbol names.
  var offset = start + 4 + 4 * count;
  if (offset > archive.length) {
    throw const FormatException('Truncated archive linker member.');
  }
  final symbols = <String>{};
  for (var i = 0; i < count; i++) {
    final end = archive.indexOf(0, offset);
    if (end == -1) {
      throw const FormatException('Truncated archive symbol table.');
    }
    symbols.add(String.fromCharCodes(archive, offset, end));
    offset = end + 1;
  }
  return symbols;
}

/// Returns the subset of [candidateSymbols] that the COFF [archive] defines.
///
/// Accounts for 32-bit x86 C symbol underscore prefixes (`_symbol`).
Set<String> definedBindingsInCoffArchive(
  Uint8List archive,
  Iterable<String> candidateSymbols,
) {
  final defined = parseCoffArchiveSymbols(archive);
  return {
    for (final symbol in candidateSymbols)
      if (defined.contains(symbol) || defined.contains('_$symbol')) symbol,
  };
}

/// Creates [LinkerOptions] for linking a Windows DLL exporting [symbols] (or
/// all bound functions in [allKnownSymbols] if [symbols] is `null`).
///
/// Only exports functions that [staticLibrary] actually defines: a DLL has to
/// list its exports explicitly, and exporting a symbol that the archive does
/// not define fails the link.
Future<LinkerOptions> createWindowsLinkerOptions({
  required Uri staticLibrary,
  required List<String>? symbols,
  Iterable<String>? allKnownSymbols,
}) async {
  final archiveBytes = await File.fromUri(staticLibrary).readAsBytes();
  final candidates = allKnownSymbols ?? symbols;
  final defined = candidates != null
      ? definedBindingsInCoffArchive(archiveBytes, candidates)
      : parseCoffArchiveSymbols(archiveBytes);
  final exports = symbols?.where(defined.contains).toList() ?? [...defined];
  return LinkerOptions.treeshake(symbolsToKeep: exports);
}
