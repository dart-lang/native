// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

/// The prefix of environment variables that set user-defines.
///
/// The full format is `DART_HOOK_DEFINE__<package>__<key>=<value>`.
///
/// The prefix is matched case-insensitively, because environment variable names
/// are case-insensitive on Windows.
const hookDefineEnvironmentVariablePrefix = 'DART_HOOK_DEFINE__';

/// Parses command-line arguments of the form `<package>.<key>=<value>` into
/// user-defines per package name.
///
/// The package name is everything before the first `.`, the key is everything
/// after it. Nested user-defines cannot be set from the command line, use a
/// JSON value instead, for example
/// `--hook-define=<package>.<key>={"nested": "value"}`.
///
/// The values are decoded with [decodeUserDefineValue].
///
/// Throws a [FormatException] if any of the [arguments] is malformed. The
/// [FormatException.message] is suitable for presenting to the user.
Map<String, Map<String, Object?>> parseCommandLineUserDefines(
  Iterable<String> arguments,
) {
  final result = <String, Map<String, Object?>>{};
  for (final argument in arguments) {
    final equalsIndex = argument.indexOf('=');
    if (equalsIndex == -1) {
      throw FormatException(
        "Expected '<package>.<key>=<value>', found '$argument'.",
        argument,
      );
    }
    final name = argument.substring(0, equalsIndex);
    final rawValue = argument.substring(equalsIndex + 1);
    final dotIndex = name.indexOf('.');
    if (dotIndex == -1) {
      throw FormatException(
        "Expected '<package>.<key>=<value>', found '$argument'.",
        argument,
      );
    }
    final packageName = name.substring(0, dotIndex);
    final key = name.substring(dotIndex + 1);
    if (packageName.isEmpty) {
      throw FormatException(
        "Expected a non-empty package name in '<package>.<key>=<value>',"
        " found '$argument'.",
        argument,
      );
    }
    if (key.isEmpty) {
      throw FormatException(
        "Expected a non-empty key in '<package>.<key>=<value>',"
        " found '$argument'.",
        argument,
      );
    }
    if (key.contains('.')) {
      final example =
          '--hook-define=$packageName.<key>=\'{"nested": "value"}\'';
      throw FormatException(
        'Nested user-defines cannot be set with command-line arguments,'
        " found '$argument'. Pass a JSON value instead, for example"
        ' $example.',
        argument,
      );
    }
    (result[packageName] ??= {})[key] = decodeUserDefineValue(rawValue);
  }
  return result;
}

/// The result of parsing user-defines from environment variables.
typedef ParsedEnvironmentUserDefines = ({
  /// The user-defines per package name.
  Map<String, Map<String, Object?>> defines,

  /// Human-readable warnings for environment variables that could not be
  /// attributed to a package.
  ///
  /// Environment variables are machine-wide, so a malformed or unused
  /// environment variable must not fail the build.
  List<String> warnings,
});

/// Parses `DART_HOOK_DEFINE__<package>__<key>=<value>` environment variables.
///
/// Package names may contain `__` themselves, so the environment variable names
/// are attributed to the packages in [knownPackageNames] using the longest
/// matching package name. If [knownPackageNames] is empty, the package name is
/// everything before the first `__`.
///
/// Environment variables that cannot be attributed to a package are reported as
/// warnings.
///
/// The values are decoded with [decodeUserDefineValue].
ParsedEnvironmentUserDefines parseEnvironmentUserDefines(
  Map<String, String> environment, {
  required Set<String> knownPackageNames,
}) {
  final defines = <String, Map<String, Object?>>{};
  final warnings = <String>[];
  for (final MapEntry(key: name, value: rawValue) in environment.entries) {
    if (!name.toUpperCase().startsWith(hookDefineEnvironmentVariablePrefix)) {
      continue;
    }
    final suffix = name.substring(hookDefineEnvironmentVariablePrefix.length);
    final packageName = knownPackageNames.isEmpty
        ? _firstPackageNamePrefix(suffix)
        : _longestPackageNamePrefix(suffix, knownPackageNames);
    if (packageName == null) {
      final packageNameSeparatorIndex = suffix.indexOf('__');
      final packageNameInVariable = packageNameSeparatorIndex <= 0
          ? null
          : suffix.substring(0, packageNameSeparatorIndex);
      warnings.add(
        switch (packageNameInVariable) {
          null =>
            "Ignoring environment variable '$name': "
                'expected '
                '$hookDefineEnvironmentVariablePrefix<package>__<key>=<value>.',
          final packageNameInVariable =>
            "Ignoring environment variable '$name': "
                "'$packageNameInVariable' is not a package"
                '${knownPackageNames.isEmpty ? '' : ' in this project'}.\n'
                'Expected: $hookDefineEnvironmentVariablePrefix'
                '<package>__<key>=<value>.',
        },
      );
      continue;
    }
    final key = suffix.substring(packageName.length + 2);
    if (key.isEmpty) {
      warnings.add(
        "Ignoring environment variable '$name': "
        'expected a non-empty key in '
        '$hookDefineEnvironmentVariablePrefix<package>__<key>=<value>.',
      );
      continue;
    }
    (defines[packageName] ??= {})[key] = decodeUserDefineValue(rawValue);
  }
  return (defines: defines, warnings: warnings);
}

/// Decodes a user-define value from a command-line argument or environment
/// variable.
///
/// Values are decoded as JSON, so that `true`, `42`, `["arm64"]` and
/// `{"nested": "value"}` have the same types as their `pubspec.yaml`
/// counterparts. Values that are not valid JSON are used as a string.
///
/// To pass a string that is itself valid JSON, quote it, for example
/// `--hook-define=<package>.<key>='"true"'`.
Object? decodeUserDefineValue(String rawValue) {
  try {
    return jsonDecode(rawValue);
  } on FormatException {
    return rawValue;
  }
}

/// Returns the package name before the first `__` in [suffix], or `null` if
/// there is none.
String? _firstPackageNamePrefix(String suffix) {
  final separatorIndex = suffix.indexOf('__');
  if (separatorIndex <= 0) {
    return null;
  }
  return suffix.substring(0, separatorIndex);
}

/// Returns the longest package name in [packageNames] that is a prefix of
/// [suffix] followed by `__`, or `null` if there is none.
String? _longestPackageNamePrefix(
  String suffix,
  Set<String> packageNames,
) {
  final lowerSuffix = suffix.toLowerCase();
  String? result;
  for (final packageName in packageNames) {
    final lowerPackageName = packageName.toLowerCase();
    if (!lowerSuffix.startsWith('${lowerPackageName}__')) {
      continue;
    }
    if (result == null || packageName.length > result.length) {
      result = packageName;
    }
  }
  return result;
}
