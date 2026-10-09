// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart' show BuildError, HookInputUserDefines;

/// How the build hook should obtain the native library.
///
/// Configured with the `buildMode` key under
/// `hooks.user_defines.<package_name>`.
enum NativeBuildMode {
  /// Use a prebuilt binary (from a bundled `prebuilt/` directory if present, or
  /// downloaded from a release URL and verified against SHA-256 hashes).
  fetch,

  /// Compile the native library from source, in-tree or at `checkoutPath`.
  ///
  /// The user-define value `checkout` is accepted as an alias.
  build,

  /// Bundle a pre-existing dynamic library from `localPath` on disk.
  local,
}

/// How `hook/link.dart` should handle tree-shaking of the native library.
///
/// Configured with the `treeshake` key under
/// `hooks.user_defines.<package_name>`.
enum TreeshakeMode {
  /// Always tree-shake in `hook/link.dart`, and fail the build if that is not
  /// possible.
  on,

  /// Never tree-shake; bundle the dynamic library directly without running the
  /// C linker.
  off,

  /// Tree-shake in `hook/link.dart` when possible, and fall back to bundling
  /// the prebuilt dynamic library (printing a warning) otherwise.
  auto,
}

/// Parsed `hooks.user_defines.<package_name>` configuration for native asset
/// hooks.
class BuildOptions {
  /// How the build hook obtains the native library.
  final NativeBuildMode buildMode;

  /// Whether and how `hook/link.dart` tree-shakes the native library.
  final TreeshakeMode treeshake;

  /// Path to a prebuilt dynamic library, used when [buildMode] is
  /// [NativeBuildMode.local].
  final Uri? localPath;

  /// Path to a source checkout, used when [buildMode] is
  /// [NativeBuildMode.build] (and when `fetch` falls back to building from
  /// source).
  final Uri? checkoutPath;

  const BuildOptions({
    required this.buildMode,
    this.treeshake = TreeshakeMode.auto,
    this.localPath,
    this.checkoutPath,
  });

  /// Parses [BuildOptions] from `input.userDefines`.
  ///
  /// Recognized keys:
  /// - `buildMode`: `fetch`, `build` (alias `checkout`), or `local`.
  /// - `local_build`: boolean shorthand used by `dart-lang/native` examples;
  ///   `true` maps to [NativeBuildMode.build]. Ignored if `buildMode` is set.
  /// - `treeshake`: `on`, `off`, `auto`, or a boolean.
  /// - `localPath`, `checkoutPath`: paths, resolved relative to the pubspec
  ///   that defines them.
  ///
  /// Values of the wrong type always throw a [BuildError]. When [strict] is
  /// `true` (the default), unrecognized `buildMode`/`treeshake` values also
  /// throw; when `false`, they fall back to [defaultMode] /
  /// [defaultTreeshake].
  factory BuildOptions.fromDefines(
    HookInputUserDefines defines, {
    String? packageName,
    NativeBuildMode defaultMode = NativeBuildMode.fetch,
    TreeshakeMode defaultTreeshake = TreeshakeMode.auto,
    bool strict = true,
  }) {
    final pkg = packageName ?? '<package>';

    Never invalid(String key, Object? value, String expected) =>
        throw BuildError(
          message:
              'Invalid value for `$key`: ${_describe(value)}.\n\n'
              'Set `$key` to $expected in your pubspec.yaml:\n'
              'hooks:\n'
              '  user_defines:\n'
              '    $pkg:\n'
              '      $key: ...\n',
        );

    const modeHelp = '`fetch`, `build`, or `local`';
    final rawMode = defines['buildMode'];
    final rawLocalBuild = defines['local_build'];
    final String? modeString;
    switch ((rawMode, rawLocalBuild)) {
      case (final String s, _):
        modeString = s;
      case (null, null):
        modeString = null;
      case (null, final bool b):
        modeString = b ? NativeBuildMode.build.name : null;
      case (null, final other):
        invalid('local_build', other, '`true` or `false`');
      case (final other, _):
        invalid('buildMode', other, modeHelp);
    }

    final NativeBuildMode buildMode;
    if (modeString == null) {
      buildMode = defaultMode;
    } else {
      final normalized = modeString == 'checkout'
          ? NativeBuildMode.build.name
          : modeString;
      final matched = NativeBuildMode.values
          .where((e) => e.name == normalized)
          .firstOrNull;
      if (matched != null) {
        buildMode = matched;
      } else if (strict) {
        invalid('buildMode', modeString, modeHelp);
      } else {
        buildMode = defaultMode;
      }
    }

    const treeshakeHelp = '`on`, `off`, or `auto`';
    final rawTreeshake = defines['treeshake'];
    final treeshakeString = switch (rawTreeshake) {
      null => null,
      final String s => switch (s.toLowerCase()) {
        'true' => TreeshakeMode.on.name,
        'false' => TreeshakeMode.off.name,
        final lower => lower,
      },
      final bool b => b ? TreeshakeMode.on.name : TreeshakeMode.off.name,
      final other => invalid('treeshake', other, treeshakeHelp),
    };

    final TreeshakeMode treeshake;
    if (treeshakeString == null) {
      treeshake = defaultTreeshake;
    } else {
      final matched = TreeshakeMode.values
          .where((e) => e.name == treeshakeString)
          .firstOrNull;
      if (matched != null) {
        treeshake = matched;
      } else if (strict) {
        invalid('treeshake', rawTreeshake, treeshakeHelp);
      } else {
        treeshake = defaultTreeshake;
      }
    }

    Uri? readPath(String key) {
      final raw = defines[key];
      if (raw == null) return null;
      if (raw is! String) invalid(key, raw, 'a path');
      return defines.path(key);
    }

    return BuildOptions(
      buildMode: buildMode,
      treeshake: treeshake,
      localPath: readPath('localPath'),
      checkoutPath: readPath('checkoutPath'),
    );
  }

  static String _describe(Object? value) =>
      value is String ? '"$value"' : '$value (${value.runtimeType})';

  @override
  String toString() =>
      'BuildOptions(buildMode: ${buildMode.name}, '
      'treeshake: ${treeshake.name}, '
      'localPath: $localPath, checkoutPath: $checkoutPath)';
}
