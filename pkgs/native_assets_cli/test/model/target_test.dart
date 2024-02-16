// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

void main() {
  test('OS naming conventions', () async {
    expect(OSImpl.android.dylibFileName('foo'), 'libfoo.so');
    expect(OSImpl.android.staticlibFileName('foo'), 'libfoo.a');
    expect(OSImpl.windows.dylibFileName('foo'), 'foo.dll');
    expect(
        OSImpl.windows.libraryFileName('foo', LinkModeImpl.dynamic), 'foo.dll');
    expect(OSImpl.windows.staticlibFileName('foo'), 'foo.lib');
    expect(
        OSImpl.windows.libraryFileName('foo', LinkModeImpl.static), 'foo.lib');
    expect(OSImpl.windows.executableFileName('foo'), 'foo.exe');
  });

  test('Target current', () async {
    final current = TargetImpl.current;
    expect(current.toString(), Abi.current().toString());
  });

  test('Target fromDartPlatform', () async {
    final current = TargetImpl.fromDartPlatform(Platform.version);
    expect(current.toString(), Abi.current().toString());
    expect(
      () => TargetImpl.fromDartPlatform('bogus'),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains('bogus') &&
            e.message.contains('Unknown version'),
      )),
    );
    expect(
      () => TargetImpl.fromDartPlatform(
        '3.0.0 (be) (Wed Apr 5 14:19:42 2023 +0000) on "myfancyos_ia32"',
      ),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains('myfancyos_ia32') &&
            e.message.contains('Unknown ABI'),
      )),
    );
  });

  test('Target cross compilation', () async {
    // All hosts can cross compile to Android.
    expect(TargetImpl.current.supportedTargetTargets(),
        contains(TargetImpl.androidArm64));
    expect(TargetImpl.macOSArm64.supportedTargetTargets(),
        contains(TargetImpl.iOSArm64));
  });

  test('Target fromArchitectureAndOs', () async {
    final current = TargetImpl.fromArchitectureAndOs(
        ArchitectureImpl.current, OSImpl.current);
    expect(current.toString(), Abi.current().toString());

    expect(
      () => TargetImpl.fromArchitectureAndOs(
          ArchitectureImpl.arm, OSImpl.windows),
      throwsA(predicate(
        (e) =>
            e is ArgumentError &&
            (e.message as String).contains('arm') &&
            (e.message as String).contains('windows'),
      )),
    );
  });
}
