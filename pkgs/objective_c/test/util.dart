// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO: Should we share this with ffigen and move it to an unpublished util
// package in this repo?

// ignore_for_file: avoid_catching_errors

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart' as internal_for_testing
    show isValidClass;
import 'package:path/path.dart' as p;

final _executeInternalCommand = () {
  try {
    return DynamicLibrary.process()
        .lookup<NativeFunction<Void Function(Pointer<Char>, Pointer<Void>)>>(
            'Dart_ExecuteInternalCommand')
        .asFunction<void Function(Pointer<Char>, Pointer<Void>)>();
  } on ArgumentError {
    return null;
  }
}();

bool canDoGC = _executeInternalCommand != null;

void doGC() {
  final gcNow = 'gc-now'.toNativeUtf8();
  _executeInternalCommand!(gcNow.cast(), nullptr);
  calloc.free(gcNow);
}

@Native<Pointer<Void> Function()>(
    isLeaf: true, symbol: 'objc_autoreleasePoolPush')
external Pointer<Void> objc_autoreleasePoolPush();

@Native<Void Function(Pointer<Void>)>(
    isLeaf: true, symbol: 'objc_autoreleasePoolPop')
external void objc_autoreleasePoolPop(Pointer<Void> pool);

@Native<Int Function(Pointer<Void>)>(isLeaf: true, symbol: 'isReadableMemory')
external int _isReadableMemory(Pointer<Void> ptr);

@Native<Uint64 Function(Pointer<Void>)>(
    isLeaf: true, symbol: 'getObjectRetainCount')
external int _getObjectRetainCount(Pointer<Void> object);

int objectRetainCount(Pointer<ObjCObject> object) {
  if (_isReadableMemory(object.cast()) == 0) return 0;
  final header = object.cast<Uint64>().value;

  // package:objective_c's isValidObject function internally calls
  // object_getClass then isValidClass. But object_getClass can occasionally
  // crash for invalid objects. This masking logic is a simplified version of
  // what object_getClass does internally. This is less likely to crash, but
  // more likely to break due to ObjC runtime updates, which is a reasonable
  // trade off to make in tests where we're explicitly calling it many times
  // on invalid objects. In package:objective_c's case, it doesn't matter so
  // much if isValidObject crashes, since it's a best effort attempt to give a
  // nice stack trace before the real crash, but it would be a problem if
  // isValidObject broke due to a runtime update.
  // These constants are the ISA_MASK macro defined in runtime/objc-private.h.
  const maskX64 = 0x00007ffffffffff8;
  const maskArm = 0x00000001fffffff8;
  final mask = Abi.current() == Abi.macosX64 ? maskX64 : maskArm;
  final clazz = Pointer<ObjCObject>.fromAddress(header & mask);

  if (!internal_for_testing.isValidClass(clazz)) return 0;
  return _getObjectRetainCount(object.cast());
}

String pkgDir = findPackageRoot('objective_c').toFilePath();

// TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
String testDylib = p.join(pkgDir, 'test', 'objective_c.dylib');

/// Test files are run in a variety of ways, find this package root in all.
///
/// Test files can be run from source from any working directory. The Dart SDK
/// `tools/test.py` runs them from the root of the SDK for example.
///
/// Test files can be run from dill from the root of package. `package:test`
/// does this.
///
/// https://github.com/dart-lang/test/issues/110
Uri findPackageRoot(String packageName) {
  final script = Platform.script;
  final fileName = script.name;
  if (fileName.endsWith('.dart')) {
    // We're likely running from source in the package somewhere.
    var directory = script.resolve('.');
    while (true) {
      final dirName = directory.name;
      if (dirName == packageName) {
        return directory;
      }
      final parent = directory.resolve('..');
      if (parent == directory) break;
      directory = parent;
    }
  } else if (fileName.endsWith('.dill')) {
    // Probably from the package root.
    final cwd = Directory.current.uri;
    final dirName = cwd.name;
    if (dirName == packageName) {
      return cwd;
    }
  }
  // Or the workspace root.
  final cwd = Directory.current.uri;
  final candidate = cwd.resolve('pkgs/$packageName/');
  if (Directory.fromUri(candidate).existsSync()) {
    return candidate;
  }
  throw StateError(
    "Could not find package root for package '$packageName'. "
    'Tried finding the package root via Platform.script '
    "'${Platform.script.toFilePath()}' and Directory.current "
    "'${Directory.current.uri.toFilePath()}'.",
  );
}

extension on Uri {
  String get name => pathSegments.where((e) => e != '').last;
}
