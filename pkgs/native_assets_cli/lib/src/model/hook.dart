// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The two types of scripts which are hooked into the compilation process.
///
/// The `build.dart` script runs before, and the `link.dart` script after
/// compilation.
enum Hook {
  link('link'),
  build('build');

  final String _scriptName;

  String get scriptName => '$_scriptName.dart';

  const Hook(this._scriptName);
}
