// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'architecture.dart';
import 'native_library_validation.dart';
import 'os.dart';

/// Validates that a bundled dynamic library is an ELF file built for the target
/// architecture.
///
/// ELF is the container format for Android, Fuchsia, and Linux targets. For any
/// other target operating system this validator returns
/// [NativeLibraryValidation.notRecognized] without opening the file. A file
/// that is not an ELF binary is also [NativeLibraryValidation.notRecognized],
/// leaving it to another validator or to a warning.
final class ElfValidator implements NativeLibraryValidator {
  /// Creates an [ElfValidator].
  const ElfValidator();

  // The identification and machine values come from the System V ABI machine
  // table and the RISC-V ELF psABI:
  // https://gabi.xinuos.com/elf/a-emachine.html
  // https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc
  static const _magic = [0x7f, 0x45, 0x4c, 0x46];
  static const _classOffset = 4;
  static const _class32 = 1;
  static const _class64 = 2;
  static const _dataOffset = 5;
  static const _dataLittleEndian = 1;
  static const _dataBigEndian = 2;
  static const _machineOffset = 18;
  static const _machineX86 = 3;
  static const _machineArm = 40;
  static const _machineX64 = 62;
  static const _machineArm64 = 183;
  static const _machineRiscV = 243;

  // The identification and the machine field occupy the first 20 bytes.
  static const _minLength = 20;

  @override
  Future<NativeLibraryValidation> validate(
    NativeLibraryValidationContext context,
  ) async {
    final targetOS = context.config.targetOS;
    if (targetOS != OS.android &&
        targetOS != OS.fuchsia &&
        targetOS != OS.linux) {
      return const NativeLibraryValidation.notRecognized();
    }

    final Uint8List head;
    try {
      final raf = File.fromUri(context.file).openSync();
      try {
        head = raf.readSync(_minLength);
      } finally {
        raf.closeSync();
      }
    } on FileSystemException {
      return const NativeLibraryValidation.notRecognized();
    }

    if (head.length < _minLength || !_hasMagic(head)) {
      return const NativeLibraryValidation.notRecognized();
    }
    final elfClass = head[_classOffset];
    final elfData = head[_dataOffset];
    if ((elfClass != _class32 && elfClass != _class64) ||
        (elfData != _dataLittleEndian && elfData != _dataBigEndian)) {
      return const NativeLibraryValidation.notRecognized();
    }

    final machine = ByteData.sublistView(head).getUint16(
      _machineOffset,
      elfData == _dataLittleEndian ? Endian.little : Endian.big,
    );
    final architecture = switch (machine) {
      _machineX86 => Architecture.ia32,
      _machineArm => Architecture.arm,
      _machineX64 => Architecture.x64,
      _machineArm64 => Architecture.arm64,
      _machineRiscV =>
        elfClass == _class32 ? Architecture.riscv32 : Architecture.riscv64,
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
  }

  static bool _hasMagic(Uint8List head) =>
      head[0] == _magic[0] &&
      head[1] == _magic[1] &&
      head[2] == _magic[2] &&
      head[3] == _magic[3];
}
