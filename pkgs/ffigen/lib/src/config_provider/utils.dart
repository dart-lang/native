// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;

// Replaces the path separators according to current platform.
String _replaceSeparators(String path) {
  if (Platform.isWindows) {
    return path.replaceAll(p.posix.separator, p.windows.separator);
  } else {
    return path.replaceAll(p.windows.separator, p.posix.separator);
  }
}

/// Replaces the path separators according to current platform, and normalizes .
/// and .. in the path. If a relative path is passed in, it is resolved relative
/// to the config path, and the absolute path is returned.
String normalizePath(String path, String? configFilename) {
  final resolveInConfigDir =
      (configFilename == null) || p.isAbsolute(path) || path.startsWith('**');
  return _replaceSeparators(p.normalize(resolveInConfigDir
      ? path
      : p.absolute(p.join(p.dirname(configFilename), path))));
}

/// Replaces any variable names in the path with the corresponding value.
String substituteVars(String path) {
  for (final variable in _variables) {
    final key = '\$${variable.key}';
    if (path.contains(key)) {
      path = path.replaceAll(key, variable.value);
    }
  }
  return path;
}

class _LazyVariable {
  _LazyVariable(this.key, this._cmd, this._args);
  final String key;
  final String _cmd;
  final List<String> _args;
  String? _value;
  String get value => _value ??= firstLineOfStdout(_cmd, _args);
}

final _variables = <_LazyVariable>[
  _LazyVariable('XCODE', 'xcode-select', ['-p']),
  _LazyVariable('IOS_SDK', 'xcrun', ['--show-sdk-path', '--sdk', 'iphoneos']),
  _LazyVariable('MACOS_SDK', 'xcrun', ['--show-sdk-path', '--sdk', 'macosx']),
];

String firstLineOfStdout(String cmd, List<String> args) {
  final result = Process.runSync(cmd, args);
  assert(result.exitCode == 0);
  return (result.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .first;
}
