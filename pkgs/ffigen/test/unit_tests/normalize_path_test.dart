// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/config_provider/spec_utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final abs = Platform.isWindows ? r'\\' : '/';
  final config = p.joinAll([abs, 'foo', 'package', 'ffigen.yaml']);

  group('normalizePath', () {
    test('All separators replaced with platform separators', () {
      // Unix style.
      expect(normalizePath('relative/header.h', null),
          p.joinAll(['relative', 'header.h']));

      // Windows style.
      expect(normalizePath(r'relative\header.h', null),
          p.joinAll(['relative', 'header.h']));
    });

    test('Relative path normalized and resolved relative to config', () {
      expect(normalizePath('relative/src/header.h', config),
          p.joinAll([abs, 'foo', 'package', 'relative', 'src', 'header.h']));
      expect(normalizePath('./../src/header.h', config),
          p.joinAll([abs, 'foo', 'src', 'header.h']));
      expect(normalizePath('./././src/header.h', config),
          p.joinAll([abs, 'foo', 'package', 'src', 'header.h']));
      expect(normalizePath('./../src/.././header.h', config),
          p.joinAll([abs, 'foo', 'header.h']));
    });

    test('Absolute path normalized but not resolved', () {
      expect(normalizePath(p.joinAll([abs, 'absolute/src/header.h']), config),
          p.joinAll([abs, 'absolute', 'src', 'header.h']));
      expect(normalizePath(p.joinAll([abs, './src/.././header.h']), config),
          p.joinAll([abs, 'header.h']));
    });

    test('Glob path normalized but not resolved', () {
      expect(normalizePath('**/glob/*/header.h', config),
          p.joinAll(['**', 'glob', '*', 'header.h']));
      expect(normalizePath('**/glob/./*/../header.h', config),
          p.joinAll(['**', 'glob', 'header.h']));
    });

    test('Null configFilename normalized but not resolved', () {
      expect(normalizePath(p.joinAll(['relative/src/header.h']), null),
          p.joinAll(['relative', 'src', 'header.h']));
      expect(normalizePath(p.joinAll(['./src/.././header.h']), null),
          p.joinAll(['header.h']));
    });
  });
}
