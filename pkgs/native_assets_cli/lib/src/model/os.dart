// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/os.dart';

final class OSImpl implements OS {
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

  static const _osTargets = {
    OSImpl.android: {
      ArchitectureImpl.arm,
      ArchitectureImpl.arm64,
      ArchitectureImpl.ia32,
      ArchitectureImpl.x64,
      ArchitectureImpl.riscv64,
    },
    OSImpl.fuchsia: {
      ArchitectureImpl.arm64,
      ArchitectureImpl.x64,
    },
    OSImpl.iOS: {
      ArchitectureImpl.arm,
      ArchitectureImpl.arm64,
      ArchitectureImpl.x64,
    },
    OSImpl.linux: {
      ArchitectureImpl.arm,
      ArchitectureImpl.arm64,
      ArchitectureImpl.ia32,
      ArchitectureImpl.riscv32,
      ArchitectureImpl.riscv64,
      ArchitectureImpl.x64,
    },
    OSImpl.macOS: {
      ArchitectureImpl.arm64,
      ArchitectureImpl.x64,
    },
    OSImpl.windows: {
      ArchitectureImpl.arm64,
      ArchitectureImpl.ia32,
      ArchitectureImpl.x64,
    },
  };

  Iterable<ArchitectureImpl> get architectures => _osTargets[this]!;

  /// Typical cross compilation between OSes.
  static const osCrossCompilationDefault = {
    OSImpl.macOS: [OSImpl.macOS, OSImpl.iOS, OSImpl.android],
    OSImpl.linux: [OSImpl.linux, OSImpl.android],
    OSImpl.windows: [OSImpl.windows, OSImpl.android],
  };

  @override
  String dylibFileName(String name) {
    final prefix = _dylibPrefix[this]!;
    final extension = _dylibExtension[this]!;
    return '$prefix$name.$extension';
  }

  @override
  String staticlibFileName(String name) {
    final prefix = _staticlibPrefix[this]!;
    final extension = _staticlibExtension[this]!;
    return '$prefix$name.$extension';
  }

  @override
  String libraryFileName(String name, LinkMode linkMode) {
    if (linkMode is DynamicLoading) {
      return dylibFileName(name);
    }
    assert(linkMode is StaticLinking);
    return staticlibFileName(name);
  }

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
  static final OSImpl current = Target.current.os;
}
