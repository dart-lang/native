// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

abstract class Target {
  /// The application binary interface for Android on the Arm architecture.
  static const String androidArm = 'android_arm';

  /// The application binary interface for Android on the Arm64 architecture.
  static const String androidArm64 = 'android_arm64';

  /// The application binary interface for Android on the IA32 architecture.
  static const String androidIA32 = 'android_ia32';

  /// The application binary interface for android on the X64 architecture.
  static const String androidX64 = 'android_x64';

  /// The application binary interface for Fuchsia on the Arm64 architecture.
  static const String fuchsiaArm64 = 'fuchsia_arm64';

  /// The application binary interface for Fuchsia on the X64 architecture.
  static const String fuchsiaX64 = 'fuchsia_x64';

  /// The application binary interface for iOS on the Arm architecture.
  static const String iosArm = 'ios_arm';

  /// The application binary interface for iOS on the Arm64 architecture.
  static const String iosArm64 = 'ios_arm64';

  /// The application binary interface for iOS on the X64 architecture.
  static const String iosX64 = 'ios_x64';

  /// The application binary interface for Linux on the Arm architecture.
  ///
  /// Does not distinguish between hard and soft fp. Currently, no uses of Abi
  /// require this distinction.
  static const String linuxArm = 'linux_arm';

  /// The application binary interface for linux on the Arm64 architecture.
  static const String linuxArm64 = 'linux_arm64';

  /// The application binary interface for linux on the IA32 architecture.
  static const String linuxIA32 = 'linux_ia32';

  /// The application binary interface for linux on the X64 architecture.
  static const String linuxX64 = 'linux_x64';

  /// The application binary interface for linux on 32-bit RISC-V.
  static const String linuxRiscv32 = 'linux_riscv32';

  /// The application binary interface for linux on 64-bit RISC-V.
  static const String linuxRiscv64 = 'linux_riscv64';

  /// The application binary interface for MacOS on the Arm64 architecture.
  static const String macosArm64 = 'macos_arm64';

  /// The application binary interface for MacOS on the X64 architecture.
  static const String macosX64 = 'macos_x64';

  /// The application binary interface for Windows on the Arm64 architecture.
  static const String windowsArm64 = 'windows_arm64';

  /// The application binary interface for Windows on the IA32 architecture.
  static const String windowsIA32 = 'windows_ia32';

  /// The application binary interface for Windows on the X64 architecture.
  static const String windowsX64 = 'windows_x64';

  static const List<String> values = [
    androidArm,
    androidArm64,
    androidIA32,
    androidX64,
    fuchsiaArm64,
    fuchsiaX64,
    iosArm,
    iosArm64,
    iosX64,
    linuxArm,
    linuxArm64,
    linuxIA32,
    linuxX64,
    linuxRiscv32,
    linuxRiscv64,
    macosArm64,
    macosX64,
    windowsArm64,
    windowsIA32,
    windowsX64,
  ];

  /// Returns the target of the host machine.
  static String current() =>
      values.firstWhere((e) => e == Abi.current().toString());
}
