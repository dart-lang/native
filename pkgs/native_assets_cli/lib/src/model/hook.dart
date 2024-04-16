// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The two types of scripts which are hooked into the compilation process.
///
/// The `build.dart` hook runs before, and the `link.dart` hook after
/// compilation. This enum holds static information about these hooks.
enum Hook {
  link('link', 'link_config'),
  build('build', 'config');

  final String _scriptName;
  final String _configName;

  String get scriptName => '$_scriptName.dart';
  String get configName => '$_configName.json';

  const Hook(this._scriptName, this._configName);
}
