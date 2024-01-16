// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../model/target.dart' as model;
import 'link_mode.dart';

/// The hardware architectures the Dart VM runs on.
abstract class Architecture {
  static const Architecture arm = model.Architecture.arm;
  static const Architecture arm64 = model.Architecture.arm64;
  static const Architecture ia32 = model.Architecture.ia32;
  static const Architecture riscv32 = model.Architecture.riscv32;
  static const Architecture riscv64 = model.Architecture.riscv64;
  static const Architecture x64 = model.Architecture.x64;

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
  static Architecture get current => model.Architecture.current;
}

/// The operating systems the Dart VM runs on.
abstract class OS {
  static const OS android = model.OS.android;
  static const OS fuchsia = model.OS.fuchsia;
  static const OS iOS = model.OS.iOS;
  static const OS linux = model.OS.linux;
  static const OS macOS = model.OS.macOS;
  static const OS windows = model.OS.windows;

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
  static OS get current => model.OS.current;
}

/// Application binary interface.
///
/// The Dart VM can run on a variety of [Target]s, see [Target.values].
abstract class Target implements Comparable<Target> {
  static const Target androidArm = model.Target.androidArm;
  static const Target androidArm64 = model.Target.androidArm64;
  static const Target androidIA32 = model.Target.androidIA32;
  static const Target androidX64 = model.Target.androidX64;
  static const Target androidRiscv64 = model.Target.androidRiscv64;
  static const Target fuchsiaArm64 = model.Target.fuchsiaArm64;
  static const Target fuchsiaX64 = model.Target.fuchsiaX64;
  static const Target iOSArm = model.Target.iOSArm;
  static const Target iOSArm64 = model.Target.iOSArm64;
  static const Target iOSX64 = model.Target.iOSX64;
  static const Target linuxArm = model.Target.linuxArm;
  static const Target linuxArm64 = model.Target.linuxArm64;
  static const Target linuxIA32 = model.Target.linuxIA32;
  static const Target linuxRiscv32 = model.Target.linuxRiscv32;
  static const Target linuxRiscv64 = model.Target.linuxRiscv64;
  static const Target linuxX64 = model.Target.linuxX64;
  static const Target macOSArm64 = model.Target.macOSArm64;
  static const Target macOSX64 = model.Target.macOSX64;
  static const Target windowsArm64 = model.Target.windowsArm64;
  static const Target windowsIA32 = model.Target.windowsIA32;
  static const Target windowsX64 = model.Target.windowsX64;

  /// All Targets that native assets can be built for.
  ///
  /// Note that for some of these a Dart SDK is not available and they are only
  /// used as target architectures for Flutter apps.
  static const values = <Target>{
    androidArm,
    androidArm64,
    androidIA32,
    androidX64,
    androidRiscv64,
    fuchsiaArm64,
    fuchsiaX64,
    iOSArm,
    iOSArm64,
    iOSX64,
    linuxArm,
    linuxArm64,
    linuxIA32,
    linuxRiscv32,
    linuxRiscv64,
    linuxX64,
    macOSArm64,
    macOSX64,
    windowsArm64,
    windowsIA32,
    windowsX64,
    // TODO(dacoharkes): Add support for `wasm`.
  };

  /// The current [Target].
  ///
  /// Read from the [Platform.version] string.
  static Target get current => model.Target.current;

  Architecture get architecture;

  OS get os;
}
