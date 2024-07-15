// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/utils.dart';
import 'package:test/test.dart';

void main() {
  group('ObjC framework header test', () {
    test('parsing', () {
      expect(parseObjCFrameworkHeader(''), null);
      expect(
          parseObjCFrameworkHeader(
              '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/'
              'Library/Frameworks/AppKit.framework/Versions/C/Headers/NSMatrix.h'),
          'AppKit/NSMatrix.h');
      expect(
          parseObjCFrameworkHeader(
              '/System/Library/Frameworks/Photos.framework/Versions/Current/'
              'Headers/SomeHeader.h'),
          'Photos/SomeHeader.h');
      expect(
          parseObjCFrameworkHeader(
              '/Library/Frameworks/macFUSE.framework/Headers/macFUSE.h'),
          'macFUSE/macFUSE.h');
      expect(
          parseObjCFrameworkHeader(
              '/Library/Frameworks/Foo.framework/Headers/Bar.h'),
          'Foo/Bar.h');
      expect(
          parseObjCFrameworkHeader(
              'a/b/c/Library/Frameworks/Foo.framework/Headers/Bar.h'),
          'Foo/Bar.h');
      expect(
          parseObjCFrameworkHeader(
              '/Library/a/b/c/Frameworks/Foo.framework/Headers/Bar.h'),
          'Foo/Bar.h');
      expect(
          parseObjCFrameworkHeader(
              '/Library/Frameworks/Foo.framework/a/b/c/Headers/Bar.h'),
          'Foo/Bar.h');
      expect(
          parseObjCFrameworkHeader(
              '/Library/Frameworks/Foo.framework/Headers/a/b/c/Bar.h'),
          'Foo/a/b/c/Bar.h');
    });
  });
}
