// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'architecture.dart';
import 'native_library_validation.dart';
import 'os.dart';

/// Validates that a bundled dynamic library is a Portable Executable (PE) file
/// built for the target architecture.
///
/// PE is the container format for Windows targets. For any other target
/// operating system this validator returns
/// [NativeLibraryValidation.notRecognized] without opening the file. A file
/// that is not a PE binary is also [NativeLibraryValidation.notRecognized],
/// leaving it to another validator or to a warning.
final class PortableExecutableValidator implements NativeLibraryValidator {
  /// Creates a [PortableExecutableValidator].
  const PortableExecutableValidator();

  // The offsets, signatures, and machine values come from Microsoft's PE format
  // specification:
  // https://learn.microsoft.com/en-us/windows/win32/debug/pe-format
  static const _dosMagic = [0x4d, 0x5a];
  static const _peHeaderOffsetLocation = 0x3c;
  static const _signature = [0x50, 0x45, 0x00, 0x00];
  static const _machineX86 = 0x014c;
  static const _machineArm = 0x01c4;
  static const _machineRiscV64 = 0x5064;
  static const _machineX64 = 0x8664;
  static const _machineArm64 = 0xaa64;

  // The smallest read that includes the 4-byte PE header offset stored at
  // _peHeaderOffsetLocation (0x3c).
  static const _minLength = _peHeaderOffsetLocation + 4;

  @override
  Future<NativeLibraryValidation> validate(
    NativeLibraryValidationContext context,
  ) async {
    final targetOS = context.config.targetOS;
    if (targetOS != OS.windows) {
      return const NativeLibraryValidation.notRecognized();
    }

    final RandomAccessFile raf;
    try {
      raf = File.fromUri(context.file).openSync();
    } on FileSystemException {
      return const NativeLibraryValidation.notRecognized();
    }
    try {
      final length = raf.lengthSync();
      final head = raf.readSync(_minLength);
      if (head.length < _minLength ||
          head[0] != _dosMagic[0] ||
          head[1] != _dosMagic[1]) {
        return const NativeLibraryValidation.notRecognized();
      }
      final peOffset = ByteData.sublistView(
        head,
      ).getUint32(_peHeaderOffsetLocation, Endian.little);
      if (peOffset + 6 > length) {
        return const NativeLibraryValidation.notRecognized();
      }

      raf.setPositionSync(peOffset);
      final signature = raf.readSync(6);
      if (signature.length < 6 ||
          signature[0] != _signature[0] ||
          signature[1] != _signature[1] ||
          signature[2] != _signature[2] ||
          signature[3] != _signature[3]) {
        return const NativeLibraryValidation.notRecognized();
      }
      final machine = ByteData.sublistView(
        signature,
      ).getUint16(4, Endian.little);
      final architecture = switch (machine) {
        _machineX86 => Architecture.ia32,
        _machineArm => Architecture.arm,
        _machineRiscV64 => Architecture.riscv64,
        _machineX64 => Architecture.x64,
        _machineArm64 => Architecture.arm64,
        _ => null,
      };

      final target = context.config.targetArchitecture;
      if (architecture == target) {
        return const NativeLibraryValidation.matched();
      }
      if (architecture == null) {
        return NativeLibraryValidation.inconclusive(
          'The built-in validator does not recognize machine value '
          '0x${machine.toRadixString(16)}.',
        );
      }
      return NativeLibraryValidation.rejected([
        'is built for $architecture, but the target architecture is $target.',
      ]);
    } on FileSystemException {
      return const NativeLibraryValidation.notRecognized();
    } finally {
      raf.closeSync();
    }
  }
}
