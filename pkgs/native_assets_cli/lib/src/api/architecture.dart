// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show Abi;
import 'dart:io';

import '../model/target.dart';

part '../model/architecture.dart';

/// A hardware architecture which the Dart VM can run on.
abstract final class Architecture {
  /// The [arm](https://en.wikipedia.org/wiki/ARM_architecture_family)
  /// architecture.
  static const Architecture arm = ArchitectureImpl.arm;

  /// The [AArch64](https://en.wikipedia.org/wiki/AArch64) architecture.
  static const Architecture arm64 = ArchitectureImpl.arm64;

  /// The [IA-32](https://en.wikipedia.org/wiki/IA-32) architecture.
  static const Architecture ia32 = ArchitectureImpl.ia32;

  /// The [RISC-V](https://en.wikipedia.org/wiki/RISC-V) 32 bit architecture.
  static const Architecture riscv32 = ArchitectureImpl.riscv32;

  /// The [RISC-V](https://en.wikipedia.org/wiki/RISC-V) 64 bit architecture.
  static const Architecture riscv64 = ArchitectureImpl.riscv64;

  /// The [x86-64](https://en.wikipedia.org/wiki/X86-64) architecture.
  static const Architecture x64 = ArchitectureImpl.x64;

  /// Known values for [Architecture].
  static const List<Architecture> values = ArchitectureImpl.values;

  /// The current [Architecture].
  ///
  /// Read from the [Platform.version] string.
  static Architecture get current => ArchitectureImpl.current;
}
