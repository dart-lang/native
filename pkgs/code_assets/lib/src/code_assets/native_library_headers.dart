// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'architecture.dart';

/// ELF identification and machine values from the
/// [System V ABI machine table](https://gabi.xinuos.com/elf/a-emachine.html)
/// and the
/// [RISC-V ELF psABI](https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc).
abstract final class _Elf {
  static const magic = [0x7f, 0x45, 0x4c, 0x46];
  static const class32 = 1;
  static const class64 = 2;
  static const littleEndian = 1;
  static const bigEndian = 2;
  static const machineOffset = 18;
  static const machineX86 = 3;
  static const machineArm = 40;
  static const machineX64 = 62;
  static const machineArm64 = 183;
  static const machineRiscV = 243;
}

/// Mach-O magic and CPU values from Apple's
/// [`loader.h`](https://github.com/apple-oss-distributions/xnu/blob/main/EXTERNAL_HEADERS/mach-o/loader.h),
/// [`fat.h`](https://github.com/apple-oss-distributions/cctools/blob/main/include/mach-o/fat.h),
/// and
/// [`machine.h`](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/machine.h).
abstract final class _MachO {
  static const magic32 = 0xfeedface;
  static const magic64 = 0xfeedfacf;
  static const swappedMagic32 = 0xcefaedfe;
  static const swappedMagic64 = 0xcffaedfe;
  static const fatMagic32 = 0xcafebabe;
  static const fatMagic64 = 0xcafebabf;
  static const cpuTypeX86 = 0x00000007;
  static const cpuTypeX64 = 0x01000007;
  static const cpuTypeArm = 0x0000000c;
  static const cpuTypeArm64 = 0x0100000c;
}

/// PE offsets, signatures, and machine values from Microsoft's
/// [PE format specification](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format).
abstract final class _Pe {
  static const dosMagic = [0x4d, 0x5a];
  static const peHeaderOffset = 0x3c;
  static const signature = [0x50, 0x45, 0x00, 0x00];
  static const machineX86 = 0x014c;
  static const machineArm = 0x01c4;
  static const machineRiscV64 = 0x5064;
  static const machineX64 = 0x8664;
  static const machineArm64 = 0xaa64;
}

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
      if (bigEndianMagic == _MachO.fatMagic32 ||
          bigEndianMagic == _MachO.fatMagic64) {
        return _readFatMachO(
          raf,
          head,
          is64: bigEndianMagic == _MachO.fatMagic64,
        );
      }
      final thin = _readThinMachO(head);
      if (thin != null) return thin;
    }
    if (head.length >= _Pe.peHeaderOffset + 4 &&
        head[0] == _Pe.dosMagic[0] &&
        head[1] == _Pe.dosMagic[1]) {
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
    head[0] == _Elf.magic[0] &&
    head[1] == _Elf.magic[1] &&
    head[2] == _Elf.magic[2] &&
    head[3] == _Elf.magic[3];

NativeLibraryHeader _readElf(Uint8List head) {
  final elfClass = head[4];
  final elfData = head[5];
  if ((elfClass != _Elf.class32 && elfClass != _Elf.class64) ||
      (elfData != _Elf.littleEndian && elfData != _Elf.bigEndian)) {
    return const UnrecognizedHeader();
  }
  final machine = _u16(
    head,
    _Elf.machineOffset,
    littleEndian: elfData == _Elf.littleEndian,
  );
  final architecture = switch (machine) {
    _Elf.machineX86 => Architecture.ia32,
    _Elf.machineArm => Architecture.arm,
    _Elf.machineX64 => Architecture.x64,
    _Elf.machineArm64 => Architecture.arm64,
    _Elf.machineRiscV =>
      elfClass == _Elf.class32 ? Architecture.riscv32 : Architecture.riscv64,
    _ => null,
  };
  return RecognizedHeader(BinaryFormat.elf, [architecture], [machine]);
}

Architecture? _machOArchitecture(int cpuType) => switch (cpuType) {
  _MachO.cpuTypeX86 => Architecture.ia32,
  _MachO.cpuTypeX64 => Architecture.x64,
  _MachO.cpuTypeArm => Architecture.arm,
  // arm64e uses CPU_TYPE_ARM64 and identifies the ABI in cpusubtype. Until
  // TODO(https://github.com/dart-lang/native/issues/3379) reads that subtype,
  // treat arm64e as arm64 rather than claiming to validate its ABI.
  _MachO.cpuTypeArm64 => Architecture.arm64,
  _ => null,
};

NativeLibraryHeader? _readThinMachO(Uint8List head) {
  final littleEndianMagic = _u32(head, 0, littleEndian: true);
  final bool littleEndian;
  if (littleEndianMagic == _MachO.magic32 ||
      littleEndianMagic == _MachO.magic64) {
    littleEndian = true;
  } else if (littleEndianMagic == _MachO.swappedMagic32 ||
      littleEndianMagic == _MachO.swappedMagic64) {
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
  final peOffset = _u32(head, _Pe.peHeaderOffset, littleEndian: true);
  if (peOffset + 6 > length) return const UnrecognizedHeader();
  raf.setPositionSync(peOffset);
  final signature = raf.readSync(6);
  if (signature.length < 6 ||
      signature[0] != _Pe.signature[0] ||
      signature[1] != _Pe.signature[1] ||
      signature[2] != _Pe.signature[2] ||
      signature[3] != _Pe.signature[3]) {
    return const UnrecognizedHeader();
  }
  final machine = _u16(signature, 4, littleEndian: true);
  final architecture = switch (machine) {
    _Pe.machineX86 => Architecture.ia32,
    _Pe.machineArm => Architecture.arm,
    _Pe.machineRiscV64 => Architecture.riscv64,
    _Pe.machineX64 => Architecture.x64,
    _Pe.machineArm64 => Architecture.arm64,
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
