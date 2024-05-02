// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffigen/ffigen.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart' as internal_for_testing
    show isValidClass, isValidBlock;
import 'package:path/path.dart' as path;

import '../test_utils.dart';

void generateBindingsForCoverage(String testName) {
  // The ObjC test bindings are generated in setup.dart (see #362), which means
  // that the ObjC related bits of ffigen are missed by test coverage. So this
  // function just regenerates those bindings. It doesn't test anything except
  // that the generation succeeded, by asserting the file exists.
  final config = testConfig(
      File(path.join('test', 'native_objc_test', '${testName}_config.yaml'))
          .readAsStringSync());
  final library = parse(config);
  final file = File(
    path.join('test', 'debug_generated', '${testName}_test.dart'),
  );
  library.generateFile(file);
  assert(file.existsSync());
  file.delete();
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

int getBlockRetainCount(Pointer<ObjCBlock> block) {
  if (!_isReadableMemory(block.cast())) return 0;
  if (!internal_for_testing.isValidBlock(block)) return 0;
  return _getBlockRetainCount(block.cast());
}

@Native<Uint64 Function(Pointer<Void>)>(
    isLeaf: true, symbol: 'getObjectRetainCount')
external int _getObjectRetainCount(Pointer<Void> object);

int getObjectRetainCount(Pointer<ObjCObject> object) {
  if (!_isReadableMemory(object.cast())) return 0;
  print("Reading U64");
  final header = object.cast<Uint64>().value;

  print("Header: ${header.toRadixString(16)}");
  final mask = Abi.current() == Abi.macosX64 ? 0x00007ffffffffff8 : 0x00000001fffffff8;
  final clazz = Pointer<ObjCObject>.fromAddress(header & mask);
  print("Class: $clazz");

  if (!internal_for_testing.isValidClass(clazz)) return 0;
  return _getObjectRetainCount(object.cast());
}
