// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'architecture.dart';
import 'build_config.dart';
import 'ios_sdk.dart';
import 'os.dart';

part '../model/target.dart';

/// Application binary interface.
///
/// The Dart VM can run on a variety of [Target]s, see [Target.values].
///
/// Please note that the [Target] does _not_ uniquely define a compilation
/// target. For example, the [IOSSdk], [BuildConfig.targetIOSSdk], and
/// [BuildConfig.targetAndroidNdkApi] also influence the compilation.
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

  /// All the application binary interfaces (ABIs) the Dart VM runs on.
  ///
  /// Note that for some of these a Dart SDK is not available and they are only
  /// used as target architectures for Flutter apps.
  static const Set<Target> values = TargetImpl.values;

  /// The current [Target].
  ///
  /// Consistent with the [Platform.version] string.
  static Target get current => TargetImpl.current;

  /// The architecture for this target.
  Architecture get architecture;

  /// The operating system for this target.
  OS get os;
}
