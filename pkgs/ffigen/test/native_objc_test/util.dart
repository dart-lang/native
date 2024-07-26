// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart' show Level;
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart' as internal_for_testing
    show isValidClass, isValidBlock;
import 'package:path/path.dart' as p;

import '../test_utils.dart';

void generateBindingsForCoverage(String testName) {
  // The ObjC test bindings are generated in setup.dart (see #362), which means
  // that the ObjC related bits of ffigen are missed by test coverage. So this
  // function just regenerates those bindings. It doesn't test anything except
  // that the generation succeeded, by asserting the file exists.
  final path = p.join('test', 'native_objc_test', '${testName}_config.yaml');
  final config = testConfig(File(path).readAsStringSync(), filename: path);
  FfiGen(logLevel: Level.SEVERE).generate(config);
}

@Native<Void Function(Pointer<Char>, Pointer<Void>)>(
    symbol: 'Dart_ExecuteInternalCommand')
external void _executeInternalCommand(Pointer<Char> cmd, Pointer<Void> arg);

void doGC() {
  final gcNow = "gc-now".toNativeUtf8();
  _executeInternalCommand(gcNow.cast(), nullptr);
  calloc.free(gcNow);
}

@Native<Bool Function(Pointer<Void>)>(isLeaf: true, symbol: 'isReadableMemory')
external bool _isReadableMemory(Pointer<Void> ptr);

@Native<Uint64 Function(Pointer<Void>)>(
    isLeaf: true, symbol: 'getBlockRetainCount')
external int _getBlockRetainCount(Pointer<Void> block);

int blockRetainCount(Pointer<ObjCBlock> block) {
  if (!_isReadableMemory(block.cast())) return 0;
  if (!internal_for_testing.isValidBlock(block)) return 0;
  return _getBlockRetainCount(block.cast());
}

@Native<Uint64 Function(Pointer<Void>)>(
    isLeaf: true, symbol: 'getObjectRetainCount')
external int _getObjectRetainCount(Pointer<Void> object);

int objectRetainCount(Pointer<ObjCObject> object) {
  if (!_isReadableMemory(object.cast())) return 0;
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
