// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// An operating system the Dart VM runs on.
final class OS {
  /// The name of this operating system.
  final String name;

  const OS._(this.name);

  /// The
  /// [Android](https://en.wikipedia.org/wiki/Android_%28operating_system%29)
  /// operating system.
  static const OS android = OS._('android');

  /// The [Fuchsia](https://en.wikipedia.org/wiki/Google_Fuchsia) operating
  /// system.
  static const OS fuchsia = OS._('fuchsia');

  /// The [iOS](https://en.wikipedia.org/wiki/IOS) operating system.
  static const OS iOS = OS._('ios');

  /// The [Linux](https://en.wikipedia.org/wiki/Linux) operating system.
  static const OS linux = OS._('linux');

  /// The [macOS](https://en.wikipedia.org/wiki/MacOS) operating system.
  static const OS macOS = OS._('macos');

  /// The
  /// [Microsoft Windows](https://en.wikipedia.org/wiki/Microsoft_Windows)
  /// operating system.
  static const OS windows = OS._('windows');

  /// Known values for [OS].
  static const List<OS> values = [
    android,
    fuchsia,
    iOS,
    linux,
    macOS,
    windows,
  ];

  /// Typical cross compilation between OSes.
  static const osCrossCompilationDefault = {
    OS.macOS: [OS.macOS, OS.iOS, OS.android],
    OS.linux: [OS.linux, OS.android],
    OS.windows: [OS.windows, OS.android],
  };

  static const String configKey = 'target_os';

  /// The name of this [OS].
  ///
  /// This returns a stable string that can be used to construct a
  /// [OS] via [OS.fromString].
  @override
  String toString() => name;

  /// Mapping from strings as used in [OS.toString] to
  /// [OS]s.
  static final Map<String, OS> _stringToOS =
      Map.fromEntries(OS.values.map((os) => MapEntry(os.toString(), os)));

  /// Creates a [OS] from the given [name].
  ///
  /// The name can be obtained from [OS.name] or [OS.toString].
  factory OS.fromString(String name) => _stringToOS[name]!;

  /// The current [OS].
  ///
  /// Consisten with the [Platform.version] string.
  static final OS current = OS.fromString(Platform.operatingSystem);
}
