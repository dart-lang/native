// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show Abi;
import 'dart:io';

import '../api/architecture.dart';
import '../api/os.dart';

final class Target implements Comparable<Target> {
  final Abi abi;

  const Target._(this.abi);

  factory Target.fromString(String target) => _stringToTarget[target]!;

  /// The [Target] corresponding the substring of [Platform.version]
  /// describing the [Target].
  ///
  /// The [Platform.version] strings are formatted as follows:
  /// `<version> (<date>) on "<Target>"`.
  factory Target.fromDartPlatform(String versionStringFull) {
    final split = versionStringFull.split('"');
    if (split.length < 2) {
      throw FormatException(
          "Unknown version from Platform.version '$versionStringFull'.");
    }
    final versionString = split[1];
    final target = _dartVMstringToTarget[versionString];
    if (target == null) {
      throw FormatException("Unknown ABI '$versionString' from Platform.version"
          " '$versionStringFull'.");
    }
    return target;
  }

  factory Target.fromArchitectureAndOS(
    ArchitectureImpl architecture,
    OSImpl os,
  ) {
    for (final value in values) {
      if (value.os == os && value.architecture == architecture) {
        return value;
      }
    }
    throw ArgumentError('Unsupported combination of OS and architecture: '
        "'${os}_$architecture'");
  }

  static const androidArm = Target._(Abi.androidArm);
  static const androidArm64 = Target._(Abi.androidArm64);
  static const androidIA32 = Target._(Abi.androidIA32);
  static const androidX64 = Target._(Abi.androidX64);
  static const androidRiscv64 = Target._(Abi.androidRiscv64);
  static const fuchsiaArm64 = Target._(Abi.fuchsiaArm64);
  static const fuchsiaX64 = Target._(Abi.fuchsiaX64);
  static const iOSArm = Target._(Abi.iosArm);
  static const iOSArm64 = Target._(Abi.iosArm64);
  static const iOSX64 = Target._(Abi.iosX64);
  static const linuxArm = Target._(Abi.linuxArm);
  static const linuxArm64 = Target._(Abi.linuxArm64);
  static const linuxIA32 = Target._(Abi.linuxIA32);
  static const linuxRiscv32 = Target._(Abi.linuxRiscv32);
  static const linuxRiscv64 = Target._(Abi.linuxRiscv64);
  static const linuxX64 = Target._(Abi.linuxX64);
  static const macOSArm64 = Target._(Abi.macosArm64);
  static const macOSX64 = Target._(Abi.macosX64);
  static const windowsArm64 = Target._(Abi.windowsArm64);
  static const windowsIA32 = Target._(Abi.windowsIA32);
  static const windowsX64 = Target._(Abi.windowsX64);

  static const Set<Target> values = {
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
  };

  /// Mapping from strings as used in [Target.toString] to [Target]s.
  static final Map<String, Target> _stringToTarget = Map.fromEntries(
      Target.values.map((target) => MapEntry(target.toString(), target)));

  /// Mapping from lowercased strings as used in [Platform.version] to
  /// [Target]s.
  static final Map<String, Target> _dartVMstringToTarget = Map.fromEntries(
      Target.values.map((target) => MapEntry(target.dartVMToString(), target)));

  /// The current [Target].
  ///
  /// Read from the [Platform.version] string.
  static final Target current = Target.fromDartPlatform(Platform.version);

  ArchitectureImpl get architecture => ArchitectureImpl.fromAbi(abi);

  OSImpl get os => OSImpl.fromAbi(abi);

  String get _architectureString => architecture.dartPlatform;

  String get _osString => os.dartPlatform;

  @override
  String toString() => dartVMToString();

  /// As used in [Platform.version].
  String dartVMToString() => '${_osString}_$_architectureString';

  /// Compares `this` to [other].
  ///
  /// If [other] is also an [Target], consistent with sorting on [toString].
  @override
  int compareTo(Target other) => toString().compareTo(other.toString());

  /// A list of supported target [Target]s from this host [os].
  List<Target> supportedTargetTargets(
          {Map<OSImpl, List<OSImpl>> osCrossCompilation =
              OSImpl.osCrossCompilationDefault}) =>
      Target.values
          .where((target) =>
              // Only valid cross compilation.
              osCrossCompilation[os]!.contains(target.os) &&
              // And no deprecated architectures.
              target != Target.iOSArm)
          .sorted;
}

/// Common methods for manipulating iterables of [Target]s.
extension on Iterable<Target> {
  /// The [Target]s in `this` sorted by name alphabetically.
  List<Target> get sorted => [for (final target in this) target]..sort();
}
