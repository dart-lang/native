// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'link_mode.dart';

part '../model/target.dart';

/// The hardware architectures the Dart VM runs on.
abstract class Architecture {
  static const Architecture arm = ArchitectureImpl.arm;
  static const Architecture arm64 = ArchitectureImpl.arm64;
  static const Architecture ia32 = ArchitectureImpl.ia32;
  static const Architecture riscv32 = ArchitectureImpl.riscv32;
  static const Architecture riscv64 = ArchitectureImpl.riscv64;
  static const Architecture x64 = ArchitectureImpl.x64;

  /// Known values for [Architecture].
  static const List<Architecture> values = [
    arm,
    arm64,
    ia32,
    riscv32,
    riscv64,
    x64,
  ];

  /// The current [Architecture].
  ///
  /// Read from the [Platform.version] string.
  static Architecture get current => ArchitectureImpl.current;
}

/// The operating systems the Dart VM runs on.
abstract class OS {
  static const OS android = OSImpl.android;
  static const OS fuchsia = OSImpl.fuchsia;
  static const OS iOS = OSImpl.iOS;
  static const OS linux = OSImpl.linux;
  static const OS macOS = OSImpl.macOS;
  static const OS windows = OSImpl.windows;

  /// Known values for [OS].
  static const List<OS> values = [
    android,
    fuchsia,
    iOS,
    linux,
    macOS,
    windows,
  ];

  /// The default dynamic library file name on this [OS].
  String dylibFileName(String name);

  /// The default static library file name on this [OS].
  String staticlibFileName(String name);

  String libraryFileName(String name, LinkMode linkMode);

  /// The default executable file name on this [OS].
  String executableFileName(String name);

  /// The current [OS].
  ///
  /// Read from the [Platform.version] string.
  static OS get current => OSImpl.current;
}

/// Application binary interface.
///
/// The Dart VM can run on a variety of [Target]s, see [Target.values].
abstract class Target implements Comparable<Target> {
  static const Target androidArm = TargetImpl.androidArm;
  static const Target androidArm64 = TargetImpl.androidArm64;
  static const Target androidIA32 = TargetImpl.androidIA32;
  static const Target androidX64 = TargetImpl.androidX64;
  static const Target androidRiscv64 = TargetImpl.androidRiscv64;
  static const Target fuchsiaArm64 = TargetImpl.fuchsiaArm64;
  static const Target fuchsiaX64 = TargetImpl.fuchsiaX64;
  static const Target iOSArm = TargetImpl.iOSArm;
  static const Target iOSArm64 = TargetImpl.iOSArm64;
  static const Target iOSX64 = TargetImpl.iOSX64;
  static const Target linuxArm = TargetImpl.linuxArm;
  static const Target linuxArm64 = TargetImpl.linuxArm64;
  static const Target linuxIA32 = TargetImpl.linuxIA32;
  static const Target linuxRiscv32 = TargetImpl.linuxRiscv32;
  static const Target linuxRiscv64 = TargetImpl.linuxRiscv64;
  static const Target linuxX64 = TargetImpl.linuxX64;
  static const Target macOSArm64 = TargetImpl.macOSArm64;
  static const Target macOSX64 = TargetImpl.macOSX64;
  static const Target windowsArm64 = TargetImpl.windowsArm64;
  static const Target windowsIA32 = TargetImpl.windowsIA32;
  static const Target windowsX64 = TargetImpl.windowsX64;

  /// All Targets that native assets can be built for.
  ///
  /// Note that for some of these a Dart SDK is not available and they are only
  /// used as target architectures for Flutter apps.
  static const Set<Target> values = TargetImpl.values;

  /// The current [Target].
  ///
  /// Read from the [Platform.version] string.
  static Target get current => TargetImpl.current;

  Architecture get architecture;

  OS get os;
}
