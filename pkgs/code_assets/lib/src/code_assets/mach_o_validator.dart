// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'architecture.dart';
import 'native_library_validation.dart';
import 'os.dart';

/// Validates that a bundled dynamic library is a thin Mach-O file built for the
/// target architecture.
///
/// Mach-O is the container format for iOS and macOS targets. For any other
/// target operating system this validator returns
/// [NativeLibraryValidation.notRecognized] without opening the file. A file
/// that is not a Mach-O binary is also [NativeLibraryValidation.notRecognized],
/// leaving it to another validator or to a warning.
///
/// The validator recognizes files according to the Mach-O format specified by
/// Apple.
final class MachOValidator implements NativeLibraryValidator {
  /// Creates a [MachOValidator].
  const MachOValidator();

  // The magic and CPU type values come from Apple's loader.h, fat.h, and
  // machine.h:
  // https://github.com/apple-oss-distributions/xnu/blob/main/EXTERNAL_HEADERS/mach-o/loader.h
  // https://github.com/apple-oss-distributions/cctools/blob/main/include/mach-o/fat.h
  // https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/machine.h
  static const _magic32 = 0xfeedface;
  static const _magic64 = 0xfeedfacf;
  static const _swappedMagic32 = 0xcefaedfe;
  static const _swappedMagic64 = 0xcffaedfe;
  static const _fatMagic32 = 0xcafebabe;
  static const _fatMagic64 = 0xcafebabf;
  static const _fatEntrySize32 = 20;
  static const _fatEntrySize64 = 32;
  static const _cpuTypeX86 = 0x00000007;
  static const _cpuTypeX64 = 0x01000007;
  static const _cpuTypeArm = 0x0000000c;
  static const _cpuTypeArm64 = 0x0100000c;
  static const _cpuSubtypeMask = 0xff000000;
  static const _cpuSubtypeArm64e = 2;

  // The magic number, CPU type, and CPU subtype for a thin binary occupy the
  // first 12 bytes. The fat path re-reads the architecture entries from the
  // file directly, so nothing past this is read from the header here.
  static const _minLength = 12;

  @override
  Future<NativeLibraryValidation> validate(
    NativeLibraryValidationContext context,
  ) async {
    final targetOS = context.config.targetOS;
    if (targetOS != OS.iOS && targetOS != OS.macOS) {
      return const NativeLibraryValidation.notRecognized();
    }

    final RandomAccessFile raf;
    try {
      raf = File.fromUri(context.file).openSync();
    } on FileSystemException {
      return const NativeLibraryValidation.notRecognized();
    }
    try {
      final head = raf.readSync(_minLength);
      if (head.length < _minLength) {
        return const NativeLibraryValidation.notRecognized();
      }
      final data = ByteData.sublistView(head);

      // The fat header and its arch entries are always big-endian.
      final fatMagic = data.getUint32(0, Endian.big);
      if (fatMagic == _fatMagic32 || fatMagic == _fatMagic64) {
        return _validateFat(
          raf,
          data,
          context.config.targetArchitecture,
          is64: fatMagic == _fatMagic64,
        );
      }

      final thinMagic = data.getUint32(0, Endian.little);
      final Endian endian;
      if (thinMagic == _magic32 || thinMagic == _magic64) {
        endian = Endian.little;
      } else if (thinMagic == _swappedMagic32 || thinMagic == _swappedMagic64) {
        endian = Endian.big;
      } else {
        return const NativeLibraryValidation.notRecognized();
      }
      final cpuType = data.getUint32(4, endian);
      final cpuSubtype = data.getUint32(8, endian);
      return _checkArchitecture(
        _architectureForCpu(cpuType: cpuType, cpuSubtype: cpuSubtype),
        cpuType,
        context.config.targetArchitecture,
      );
    } on FileSystemException {
      return const NativeLibraryValidation.notRecognized();
    } finally {
      raf.closeSync();
    }
  }

  NativeLibraryValidation _validateFat(
    RandomAccessFile raf,
    ByteData head,
    Architecture target, {
    required bool is64,
  }) {
    final sliceCount = head.getUint32(4, Endian.big);
    if (sliceCount == 0) return const NativeLibraryValidation.notRecognized();
    final entrySize = is64 ? _fatEntrySize64 : _fatEntrySize32;
    final entriesLength = sliceCount * entrySize;
    if (raf.lengthSync() < 8 + entriesLength) {
      return const NativeLibraryValidation.notRecognized();
    }
    raf.setPositionSync(8);
    final entries = raf.readSync(entriesLength);
    if (entries.length < entriesLength) {
      return const NativeLibraryValidation.notRecognized();
    }
    if (sliceCount > 1) return _multiArchitecture();

    final sliceData = ByteData.sublistView(entries);
    final cpuType = sliceData.getUint32(0, Endian.big);
    final cpuSubtype = sliceData.getUint32(4, Endian.big);
    return _checkArchitecture(
      _architectureForCpu(cpuType: cpuType, cpuSubtype: cpuSubtype),
      cpuType,
      target,
    );
  }

  static Architecture? _architectureForCpu({
    required int cpuType,
    required int cpuSubtype,
  }) => switch (cpuType) {
    _cpuTypeX86 => Architecture.ia32,
    _cpuTypeX64 => Architecture.x64,
    _cpuTypeArm => Architecture.arm,
    _cpuTypeArm64 =>
      (cpuSubtype & ~_cpuSubtypeMask) == _cpuSubtypeArm64e
          ? Architecture.arm64e
          : Architecture.arm64,
    _ => null,
  };

  NativeLibraryValidation _checkArchitecture(
    Architecture? architecture,
    int machineValue,
    Architecture target,
  ) {
    if (architecture == target) {
      return const NativeLibraryValidation.matched();
    }
    if (architecture == null) {
      return NativeLibraryValidation.inconclusive(
        'The built-in validator does not recognize machine value '
        '0x${machineValue.toRadixString(16)}.',
      );
    }
    return NativeLibraryValidation.rejected([
      'is built for $architecture, but the target architecture is $target.',
    ]);
  }

  static NativeLibraryValidation _multiArchitecture() =>
      NativeLibraryValidation.rejected([
        'is a multi-architecture Mach-O binary. Hooks run once per target '
            'architecture and must output a thin Mach-O binary.',
      ]);
}
