// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/architecture.dart';

final class ArchitectureImpl implements Architecture {
  /// This architecture as used in [Platform.version].
  final String dartPlatform;

  const ArchitectureImpl._(this.dartPlatform);

  factory ArchitectureImpl.fromAbi(Abi abi) => _abiToArch[abi]!;

  static const ArchitectureImpl arm = ArchitectureImpl._('arm');
  static const ArchitectureImpl arm64 = ArchitectureImpl._('arm64');
  static const ArchitectureImpl ia32 = ArchitectureImpl._('ia32');
  static const ArchitectureImpl riscv32 = ArchitectureImpl._('riscv32');
  static const ArchitectureImpl riscv64 = ArchitectureImpl._('riscv64');
  static const ArchitectureImpl x64 = ArchitectureImpl._('x64');

  static const List<ArchitectureImpl> values = [
    arm,
    arm64,
    ia32,
    riscv32,
    riscv64,
    x64,
  ];

  static const _abiToArch = {
    Abi.androidArm: ArchitectureImpl.arm,
    Abi.androidArm64: ArchitectureImpl.arm64,
    Abi.androidIA32: ArchitectureImpl.ia32,
    Abi.androidX64: ArchitectureImpl.x64,
    Abi.androidRiscv64: ArchitectureImpl.riscv64,
    Abi.fuchsiaArm64: ArchitectureImpl.arm64,
    Abi.fuchsiaX64: ArchitectureImpl.x64,
    Abi.iosArm: ArchitectureImpl.arm,
    Abi.iosArm64: ArchitectureImpl.arm64,
    Abi.iosX64: ArchitectureImpl.x64,
    Abi.linuxArm: ArchitectureImpl.arm,
    Abi.linuxArm64: ArchitectureImpl.arm64,
    Abi.linuxIA32: ArchitectureImpl.ia32,
    Abi.linuxRiscv32: ArchitectureImpl.riscv32,
    Abi.linuxRiscv64: ArchitectureImpl.riscv64,
    Abi.linuxX64: ArchitectureImpl.x64,
    Abi.macosArm64: ArchitectureImpl.arm64,
    Abi.macosX64: ArchitectureImpl.x64,
    Abi.windowsArm64: ArchitectureImpl.arm64,
    Abi.windowsIA32: ArchitectureImpl.ia32,
    Abi.windowsX64: ArchitectureImpl.x64,
  };

  static const String configKey = 'target_architecture';

  @override
  String toString() => dartPlatform;

  static final Map<String, ArchitectureImpl> _architectureByName = {
    for (var architecture in values) architecture.dartPlatform: architecture
  };

  factory ArchitectureImpl.fromString(String target) =>
      _architectureByName[target]!;

  static final ArchitectureImpl current = Target.current.architecture;
}
