// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show Abi;
import 'dart:io';

import '../api/architecture.dart';
import '../api/os.dart';

final class TargetImpl implements Comparable<TargetImpl> {
  final Abi abi;

  const TargetImpl._(this.abi);

  factory TargetImpl.fromString(String target) => _stringToTarget[target]!;

  /// The [TargetImpl] corresponding the substring of [Platform.version]
  /// describing the [TargetImpl].
  ///
  /// The [Platform.version] strings are formatted as follows:
  /// `<version> (<date>) on "<Target>"`.
  factory TargetImpl.fromDartPlatform(String versionStringFull) {
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

  factory TargetImpl.fromArchitectureAndOs(
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

  static const androidArm = TargetImpl._(Abi.androidArm);
  static const androidArm64 = TargetImpl._(Abi.androidArm64);
  static const androidIA32 = TargetImpl._(Abi.androidIA32);
  static const androidX64 = TargetImpl._(Abi.androidX64);
  static const androidRiscv64 = TargetImpl._(Abi.androidRiscv64);
  static const fuchsiaArm64 = TargetImpl._(Abi.fuchsiaArm64);
  static const fuchsiaX64 = TargetImpl._(Abi.fuchsiaX64);
  static const iOSArm = TargetImpl._(Abi.iosArm);
  static const iOSArm64 = TargetImpl._(Abi.iosArm64);
  static const iOSX64 = TargetImpl._(Abi.iosX64);
  static const linuxArm = TargetImpl._(Abi.linuxArm);
  static const linuxArm64 = TargetImpl._(Abi.linuxArm64);
  static const linuxIA32 = TargetImpl._(Abi.linuxIA32);
  static const linuxRiscv32 = TargetImpl._(Abi.linuxRiscv32);
  static const linuxRiscv64 = TargetImpl._(Abi.linuxRiscv64);
  static const linuxX64 = TargetImpl._(Abi.linuxX64);
  static const macOSArm64 = TargetImpl._(Abi.macosArm64);
  static const macOSX64 = TargetImpl._(Abi.macosX64);
  static const windowsArm64 = TargetImpl._(Abi.windowsArm64);
  static const windowsIA32 = TargetImpl._(Abi.windowsIA32);
  static const windowsX64 = TargetImpl._(Abi.windowsX64);

  static const Set<TargetImpl> values = {
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

  /// Mapping from strings as used in [TargetImpl.toString] to [TargetImpl]s.
  static final Map<String, TargetImpl> _stringToTarget = Map.fromEntries(
      TargetImpl.values.map((target) => MapEntry(target.toString(), target)));

  /// Mapping from lowercased strings as used in [Platform.version] to
  /// [TargetImpl]s.
  static final Map<String, TargetImpl> _dartVMstringToTarget = Map.fromEntries(
      TargetImpl.values
          .map((target) => MapEntry(target.dartVMToString(), target)));

  /// The current [TargetImpl].
  ///
  /// Read from the [Platform.version] string.
  static final TargetImpl current =
      TargetImpl.fromDartPlatform(Platform.version);

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
  /// If [other] is also an [TargetImpl], consistent with sorting on [toString].
  @override
  int compareTo(TargetImpl other) => toString().compareTo(other.toString());

  /// A list of supported target [TargetImpl]s from this host [os].
  List<TargetImpl> supportedTargetTargets(
          {Map<OSImpl, List<OSImpl>> osCrossCompilation =
              OSImpl.osCrossCompilationDefault}) =>
      TargetImpl.values
          .where((target) =>
              // Only valid cross compilation.
              osCrossCompilation[os]!.contains(target.os) &&
              // And no deprecated architectures.
              target != TargetImpl.iOSArm)
          .sorted;
}

/// Common methods for manipulating iterables of [TargetImpl]s.
extension on Iterable<TargetImpl> {
  /// The [TargetImpl]s in `this` sorted by name alphabetically.
  List<TargetImpl> get sorted => [for (final target in this) target]..sort();
}
