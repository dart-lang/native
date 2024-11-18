// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show Abi;

/// A hardware architecture which the Dart VM can run on.
final class Architecture {
  /// The name of this architecture.
  final String name;

  const Architecture._(this.name);

  /// The [Architecture] corresponding to the given [abi].
  factory Architecture.fromAbi(Abi abi) => _abiToArch[abi]!;

  /// The [arm](https://en.wikipedia.org/wiki/ARM_architecture_family)
  /// architecture.
  static const Architecture arm = Architecture._('arm');

  /// The [AArch64](https://en.wikipedia.org/wiki/AArch64) architecture.
  static const Architecture arm64 = Architecture._('arm64');

  /// The [IA-32](https://en.wikipedia.org/wiki/IA-32) architecture.
  static const Architecture ia32 = Architecture._('ia32');

  /// The [RISC-V](https://en.wikipedia.org/wiki/RISC-V) 32 bit architecture.
  static const Architecture riscv32 = Architecture._('riscv32');

  /// The [RISC-V](https://en.wikipedia.org/wiki/RISC-V) 64 bit architecture.
  static const Architecture riscv64 = Architecture._('riscv64');

  /// The [x86-64](https://en.wikipedia.org/wiki/X86-64) architecture.
  static const Architecture x64 = Architecture._('x64');

  /// Known values for [Architecture].
  static const List<Architecture> values = [
    arm,
    arm64,
    ia32,
    riscv32,
    riscv64,
    x64,
  ];

  static const _abiToArch = {
    Abi.androidArm: Architecture.arm,
    Abi.androidArm64: Architecture.arm64,
    Abi.androidIA32: Architecture.ia32,
    Abi.androidX64: Architecture.x64,
    Abi.androidRiscv64: Architecture.riscv64,
    Abi.fuchsiaArm64: Architecture.arm64,
    Abi.fuchsiaRiscv64: Architecture.riscv64,
    Abi.fuchsiaX64: Architecture.x64,
    Abi.iosArm: Architecture.arm,
    Abi.iosArm64: Architecture.arm64,
    Abi.iosX64: Architecture.x64,
    Abi.linuxArm: Architecture.arm,
    Abi.linuxArm64: Architecture.arm64,
    Abi.linuxIA32: Architecture.ia32,
    Abi.linuxRiscv32: Architecture.riscv32,
    Abi.linuxRiscv64: Architecture.riscv64,
    Abi.linuxX64: Architecture.x64,
    Abi.macosArm64: Architecture.arm64,
    Abi.macosX64: Architecture.x64,
    Abi.windowsArm64: Architecture.arm64,
    Abi.windowsIA32: Architecture.ia32,
    Abi.windowsX64: Architecture.x64,
  };

  /// The name of this [Architecture].
  ///
  /// This returns a stable string that can be used to construct an
  /// [Architecture] via [Architecture.fromString].
  @override
  String toString() => name;

  static final Map<String, Architecture> _architectureByName = {
    for (var architecture in values) architecture.name: architecture
  };

  /// Creates an [Architecture] from the given [name].
  ///
  /// The name can be obtained from [Architecture.name] or
  /// [Architecture.toString].
  factory Architecture.fromString(String name) => _architectureByName[name]!;

  /// The current [Architecture].
  static final Architecture current = _abiToArch[Abi.current()]!;
}
