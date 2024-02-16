// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/target.dart';

/// The hardware architectures the Dart VM runs on.
class ArchitectureImpl implements Architecture {
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

  /// Known values for [ArchitectureImpl].
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

  /// The `package:config` key preferably used.
  static const String configKey = 'target_architecture';

  @override
  String toString() => dartPlatform;

  /// Mapping from strings as used in [ArchitectureImpl.toString] to
  /// [ArchitectureImpl]s.
  static final Map<String, ArchitectureImpl> _stringToArchitecture =
      Map.fromEntries(ArchitectureImpl.values.map(
          (architecture) => MapEntry(architecture.toString(), architecture)));

  factory ArchitectureImpl.fromString(String target) =>
      _stringToArchitecture[target]!;

  /// The current [ArchitectureImpl].
  ///
  /// Read from the [Platform.version] string.
  static final ArchitectureImpl current = TargetImpl.current.architecture;
}

/// The operating systems the Dart VM runs on.
class OSImpl implements OS {
  /// This OS as used in [Platform.version]
  final String dartPlatform;

  const OSImpl._(this.dartPlatform);

  factory OSImpl.fromAbi(Abi abi) => _abiToOS[abi]!;

  static const OSImpl android = OSImpl._('android');
  static const OSImpl fuchsia = OSImpl._('fuchsia');
  static const OSImpl iOS = OSImpl._('ios');
  static const OSImpl linux = OSImpl._('linux');
  static const OSImpl macOS = OSImpl._('macos');
  static const OSImpl windows = OSImpl._('windows');

  /// Known values for [OSImpl].
  static const List<OSImpl> values = [
    android,
    fuchsia,
    iOS,
    linux,
    macOS,
    windows,
  ];

  static const _abiToOS = {
    Abi.androidArm: OSImpl.android,
    Abi.androidArm64: OSImpl.android,
    Abi.androidIA32: OSImpl.android,
    Abi.androidX64: OSImpl.android,
    Abi.androidRiscv64: OSImpl.android,
    Abi.fuchsiaArm64: OSImpl.fuchsia,
    Abi.fuchsiaX64: OSImpl.fuchsia,
    Abi.iosArm: OSImpl.iOS,
    Abi.iosArm64: OSImpl.iOS,
    Abi.iosX64: OSImpl.iOS,
    Abi.linuxArm: OSImpl.linux,
    Abi.linuxArm64: OSImpl.linux,
    Abi.linuxIA32: OSImpl.linux,
    Abi.linuxRiscv32: OSImpl.linux,
    Abi.linuxRiscv64: OSImpl.linux,
    Abi.linuxX64: OSImpl.linux,
    Abi.macosArm64: OSImpl.macOS,
    Abi.macosX64: OSImpl.macOS,
    Abi.windowsArm64: OSImpl.windows,
    Abi.windowsIA32: OSImpl.windows,
    Abi.windowsX64: OSImpl.windows,
  };

  /// Typical cross compilation between OSes.
  static const _osCrossCompilationDefault = {
    OSImpl.macOS: [OSImpl.macOS, OSImpl.iOS, OSImpl.android],
    OSImpl.linux: [OSImpl.linux, OSImpl.android],
    OSImpl.windows: [OSImpl.windows, OSImpl.android],
  };

  /// The default dynamic library file name on this [OSImpl].
  @override
  String dylibFileName(String name) {
    final prefix = _dylibPrefix[this]!;
    final extension = _dylibExtension[this]!;
    return '$prefix$name.$extension';
  }

  /// The default static library file name on this [OSImpl].
  @override
  String staticlibFileName(String name) {
    final prefix = _staticlibPrefix[this]!;
    final extension = _staticlibExtension[this]!;
    return '$prefix$name.$extension';
  }

  @override
  String libraryFileName(String name, LinkMode linkMode) {
    if (linkMode == LinkModeImpl.dynamic) {
      return dylibFileName(name);
    }
    assert(linkMode == LinkModeImpl.static);
    return staticlibFileName(name);
  }

  /// The default executable file name on this [OSImpl].
  @override
  String executableFileName(String name) {
    final extension = _executableExtension[this]!;
    final dot = extension.isNotEmpty ? '.' : '';
    return '$name$dot$extension';
  }

  /// The default name prefix for dynamic libraries per [OSImpl].
  static const _dylibPrefix = {
    OSImpl.android: 'lib',
    OSImpl.fuchsia: 'lib',
    OSImpl.iOS: 'lib',
    OSImpl.linux: 'lib',
    OSImpl.macOS: 'lib',
    OSImpl.windows: '',
  };

  /// The default extension for dynamic libraries per [OSImpl].
  static const _dylibExtension = {
    OSImpl.android: 'so',
    OSImpl.fuchsia: 'so',
    OSImpl.iOS: 'dylib',
    OSImpl.linux: 'so',
    OSImpl.macOS: 'dylib',
    OSImpl.windows: 'dll',
  };

  /// The default name prefix for static libraries per [OSImpl].
  static const _staticlibPrefix = _dylibPrefix;

  /// The default extension for static libraries per [OSImpl].
  static const _staticlibExtension = {
    OSImpl.android: 'a',
    OSImpl.fuchsia: 'a',
    OSImpl.iOS: 'a',
    OSImpl.linux: 'a',
    OSImpl.macOS: 'a',
    OSImpl.windows: 'lib',
  };

  /// The default extension for executables per [OSImpl].
  static const _executableExtension = {
    OSImpl.android: '',
    OSImpl.fuchsia: '',
    OSImpl.iOS: '',
    OSImpl.linux: '',
    OSImpl.macOS: '',
    OSImpl.windows: 'exe',
  };

  /// The `package:config` key preferably used.
  static const String configKey = 'target_os';

  @override
  String toString() => dartPlatform;

  /// Mapping from strings as used in [OSImpl.toString] to
  /// [OSImpl]s.
  static final Map<String, OSImpl> _stringToOS =
      Map.fromEntries(OSImpl.values.map((os) => MapEntry(os.toString(), os)));

  factory OSImpl.fromString(String target) => _stringToOS[target]!;

  /// The current [OSImpl].
  ///
  /// Read from the [Platform.version] string.
  static final OSImpl current = TargetImpl.current.os;
}

/// Application binary interface.
///
/// The Dart VM can run on a variety of [TargetImpl]s, see [TargetImpl.values].
class TargetImpl implements Target {
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
      ArchitectureImpl architecture, OSImpl os) {
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

  /// All Targets that we can build for.
  ///
  /// Note that for some of these a Dart SDK is not available and they are only
  /// used as target architectures for Flutter apps.
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
    // TODO(dacoharkes): Add support for `wasm`.
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

  @override
  ArchitectureImpl get architecture => ArchitectureImpl.fromAbi(abi);

  @override
  OSImpl get os => OSImpl.fromAbi(abi);

  String get _architectureString => architecture.dartPlatform;

  String get _osString => os.dartPlatform;

  /// A string representation of this object.
  @override
  String toString() => dartVMToString();

  /// As used in [Platform.version].
  String dartVMToString() => '${_osString}_$_architectureString';

  /// Compares `this` to [other].
  ///
  /// If [other] is also an [TargetImpl], consistent with sorting on [toString].
  @override
  int compareTo(Target other) => toString().compareTo(other.toString());

  /// A list of supported target [TargetImpl]s from this host [os].
  List<TargetImpl> supportedTargetTargets(
          {Map<OSImpl, List<OSImpl>> osCrossCompilation =
              OSImpl._osCrossCompilationDefault}) =>
      TargetImpl.values
          .where((target) =>
              // Only valid cross compilation.
              osCrossCompilation[os]!.contains(target.os) &&
              // And no deprecated architectures.
              target != TargetImpl.iOSArm)
          .sorted;
}

/// Common methods for manipulating iterables of [TargetImpl]s.
extension TargetList on Iterable<TargetImpl> {
  /// The [TargetImpl]s in `this` sorted by name alphabetically.
  List<TargetImpl> get sorted => [for (final target in this) target]..sort();
}
