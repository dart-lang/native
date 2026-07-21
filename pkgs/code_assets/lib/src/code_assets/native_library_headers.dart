// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'architecture.dart';

/// The binary format of a native library file.
enum BinaryFormat {
  /// The Executable and Linkable Format used on Linux, Android, and Fuchsia.
  elf('ELF'),

  /// The Mach object format used on macOS and iOS.
  machO('Mach-O'),

  /// The Portable Executable format used on Windows.
  pe('PE');

  const BinaryFormat(this.displayName);

  /// The name of this format in messages.
  final String displayName;
}

/// The result of reading a native library's header.
sealed class NativeLibraryHeader {
  const NativeLibraryHeader();
}

/// A header whose binary format was recognized.
final class RecognizedHeader extends NativeLibraryHeader {
  /// Constructs a [RecognizedHeader].
  const RecognizedHeader(this.format, this.architectures, this.machineValues);

  /// The binary format of the file.
  final BinaryFormat format;

  /// The architectures the file was built for, aligned with [machineValues].
  ///
  /// A `null` entry means the format was recognized but its machine value is
  /// not one of the [Architecture]s. Fat Mach-O files contain one entry per
  /// slice; the other formats always contain exactly one.
  final List<Architecture?> architectures;

  /// The raw machine values from the header, for diagnostics.
  final List<int> machineValues;
}

/// A file whose binary format was not recognized.
final class UnrecognizedHeader extends NativeLibraryHeader {
  /// Constructs an [UnrecognizedHeader].
  const UnrecognizedHeader();
}

/// Reads just enough of [file] to identify its binary format and the
/// architectures it was built for.
///
/// Never throws for file contents: anything that cannot be identified,
/// including short and empty files, is an [UnrecognizedHeader].
NativeLibraryHeader readNativeLibraryHeader(File file) {
  final RandomAccessFile raf;
  try {
    raf = file.openSync();
  } on FileSystemException {
    return const UnrecognizedHeader();
  }
  try {
    final length = raf.lengthSync();
    final head = raf.readSync(64);
    if (head.length >= 20 && _hasElfMagic(head)) return _readElf(head);
    if (head.length >= 8) {
      final bigEndianMagic = _u32(head, 0, littleEndian: false);
      if (bigEndianMagic == 0xcafebabe || bigEndianMagic == 0xcafebabf) {
        return _readFatMachO(raf, head, is64: bigEndianMagic == 0xcafebabf);
      }
      final thin = _readThinMachO(head);
      if (thin != null) return thin;
    }
    if (head.length >= 0x40 && head[0] == 0x4d && head[1] == 0x5a) {
      return _readPe(raf, head, length);
    }
    return const UnrecognizedHeader();
  } on FileSystemException {
    return const UnrecognizedHeader();
  } finally {
    raf.closeSync();
  }
}

bool _hasElfMagic(Uint8List head) =>
    head[0] == 0x7f && head[1] == 0x45 && head[2] == 0x4c && head[3] == 0x46;

NativeLibraryHeader _readElf(Uint8List head) {
  final elfClass = head[4];
  final elfData = head[5];
  if ((elfClass != 1 && elfClass != 2) || (elfData != 1 && elfData != 2)) {
    return const UnrecognizedHeader();
  }
  final machine = _u16(head, 18, littleEndian: elfData == 1);
  final architecture = switch (machine) {
    3 => Architecture.ia32,
    40 => Architecture.arm,
    62 => Architecture.x64,
    183 => Architecture.arm64,
    243 => elfClass == 1 ? Architecture.riscv32 : Architecture.riscv64,
    _ => null,
  };
  return RecognizedHeader(BinaryFormat.elf, [architecture], [machine]);
}

Architecture? _machOArchitecture(int cpuType) => switch (cpuType) {
  0x00000007 => Architecture.ia32,
  0x01000007 => Architecture.x64,
  0x0000000c => Architecture.arm,
  0x0100000c => Architecture.arm64,
  _ => null,
};

NativeLibraryHeader? _readThinMachO(Uint8List head) {
  final littleEndianMagic = _u32(head, 0, littleEndian: true);
  final bool littleEndian;
  if (littleEndianMagic == 0xfeedface || littleEndianMagic == 0xfeedfacf) {
    littleEndian = true;
  } else if (littleEndianMagic == 0xcefaedfe ||
      littleEndianMagic == 0xcffaedfe) {
    littleEndian = false;
  } else {
    return null;
  }
  final cpuType = _u32(head, 4, littleEndian: littleEndian);
  return RecognizedHeader(
    BinaryFormat.machO,
    [_machOArchitecture(cpuType)],
    [cpuType],
  );
}

NativeLibraryHeader _readFatMachO(
  RandomAccessFile raf,
  Uint8List head, {
  required bool is64,
}) {
  // The fat header and arch entries are always big-endian. The number of
  // slices is tiny in practice; the bound also rejects Java class files,
  // which share the 0xcafebabe magic but carry a version number here.
  final sliceCount = _u32(head, 4, littleEndian: false);
  if (sliceCount == 0 || sliceCount > 32) return const UnrecognizedHeader();
  final entrySize = is64 ? 32 : 20;
  raf.setPositionSync(8);
  final entries = raf.readSync(sliceCount * entrySize);
  if (entries.length < sliceCount * entrySize) {
    return const UnrecognizedHeader();
  }
  final machineValues = [
    for (var slice = 0; slice < sliceCount; slice++)
      _u32(entries, slice * entrySize, littleEndian: false),
  ];
  return RecognizedHeader(BinaryFormat.machO, [
    for (final cpuType in machineValues) _machOArchitecture(cpuType),
  ], machineValues);
}

NativeLibraryHeader _readPe(RandomAccessFile raf, Uint8List head, int length) {
  final peOffset = _u32(head, 0x3c, littleEndian: true);
  if (peOffset + 6 > length) return const UnrecognizedHeader();
  raf.setPositionSync(peOffset);
  final signature = raf.readSync(6);
  if (signature.length < 6 ||
      signature[0] != 0x50 ||
      signature[1] != 0x45 ||
      signature[2] != 0 ||
      signature[3] != 0) {
    return const UnrecognizedHeader();
  }
  final machine = _u16(signature, 4, littleEndian: true);
  final architecture = switch (machine) {
    0x014c => Architecture.ia32,
    0x01c4 => Architecture.arm,
    0x5064 => Architecture.riscv64,
    0x8664 => Architecture.x64,
    0xaa64 => Architecture.arm64,
    _ => null,
  };
  return RecognizedHeader(BinaryFormat.pe, [architecture], [machine]);
}

int _u16(Uint8List bytes, int offset, {required bool littleEndian}) =>
    littleEndian
    ? bytes[offset] | (bytes[offset + 1] << 8)
    : (bytes[offset] << 8) | bytes[offset + 1];

int _u32(Uint8List bytes, int offset, {required bool littleEndian}) =>
    littleEndian
    ? bytes[offset] |
          (bytes[offset + 1] << 8) |
          (bytes[offset + 2] << 16) |
          (bytes[offset + 3] << 24)
    : (bytes[offset] << 24) |
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];
