// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'syntax.g.dart' as syntax;

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
  static const List<OS> values = [android, fuchsia, iOS, linux, macOS, windows];

  /// Typical cross compilation between OSes.
  static const osCrossCompilationDefault = {
    OS.macOS: [OS.macOS, OS.iOS, OS.android],
    OS.linux: [OS.linux, OS.android],
    OS.windows: [OS.windows, OS.android],
  };

  /// The name of this [OS].
  ///
  /// This returns a stable string that can be used to construct a
  /// [OS] via [OS.fromString].
  @override
  String toString() => name;

  /// Creates a [OS] from the given [name].
  ///
  /// The name can be obtained from [OS.name] or [OS.toString].
  factory OS.fromString(String name) =>
      OSSyntax.fromSyntax(syntax.OS.fromJson(name));

  /// The current [OS].
  ///
  /// Consisten with the [Platform.version] string.
  static final OS current = OS.fromString(Platform.operatingSystem);
}

extension OSSyntax on OS {
  static final _toSyntax = {
    for (final item in OS.values) item: syntax.OS.fromJson(item.name),
  };

  static final _fromSyntax = {
    for (var entry in _toSyntax.entries) entry.value: entry.key,
  };

  syntax.OS toSyntax() => _toSyntax[this]!;

  static OS fromSyntax(syntax.OS syntax) => switch (_fromSyntax[syntax]) {
    null => throw FormatException('The OS "${syntax.name}" is not known'),
    final e => e,
  };
}
