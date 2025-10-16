// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

// ignore: deprecated_member_use_from_same_package
export 'overrideable_utils.dart';

/// Replaces any variable names in the path with the corresponding value.
String substituteVars(String path) {
  for (final variable in [_xcode, _iosSdk, _macSdk]) {
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

final _xcode = _LazyVariable('XCODE', 'xcode-select', ['-p']);
final _iosSdk = _LazyVariable('IOS_SDK', 'xcrun', [
  '--show-sdk-path',
  '--sdk',
  'iphoneos',
]);
final _macSdk = _LazyVariable('MACOS_SDK', 'xcrun', [
  '--show-sdk-path',
  '--sdk',
  'macosx',
]);

String firstLineOfStdout(String cmd, List<String> args) {
  final result = Process.runSync(cmd, args);
  assert(result.exitCode == 0);
  return (result.stdout as String)
      .split('\n')
      .where((line) => line.isNotEmpty)
      .first;
}

String get xcodePath => _xcode.value;
String get iosSdkPath => _iosSdk.value;
String get macSdkPath => _macSdk.value;
