// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@DefaultAsset('package:objective_c/objective_c.dylib')
library;

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:leak_tracker/leak_tracker.dart' as leak_tracker;
import 'package:logging/logging.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart'
    as internal_for_testing
    show isValidBlock, isValidClass;
import 'package:path/path.dart' as p;

import '../test_utils.dart';

void verifyBindings(
  String testName, {
  Logger? logger,
  bool Function(String expected, String actual)? dartVerify,
  bool Function(String expected, String actual)? objCVerify,
}) {
  final thisDir = p.join(packagePathForTests, 'test', 'native_objc_test');
  final configFile = p.join(thisDir, '${testName}_config.yaml');

  final config = testConfigFromPath(configFile, logger: logger);
  final context = testContext(config);
  final library = parse(context);

  final bindingsName = context.config.output.dartFile.pathSegments.last;
  matchLibraryWithExpected(context, library, bindingsName, [
    'test',
    'native_objc_test',
    bindingsName,
  ], verify: dartVerify);

  final mFileName = context.config.output.objCFile.pathSegments.last;
  matchObjCFileWithExpected(context, library, mFileName, [
    'test',
    'native_objc_test',
    mFileName,
  ], verify: objCVerify);
}

final _executeInternalCommand = () {
  try {
    return DynamicLibrary.process()
        .lookup<NativeFunction<Void Function(Pointer<Char>, Pointer<Void>)>>(
          'Dart_ExecuteInternalCommand',
        )
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

// Dart_ExecuteInternalCommand("gc-now") doesn't work on flutter, so we use
// leak_tracker's forceGC function instead. It's less reliable, and to combat
// that we need to wait for quite a long time, which breaks autorelease pools.
Future<void> flutterDoGC() async {
  await leak_tracker.forceGC();
  await Future<void>.delayed(const Duration(milliseconds: 500));
}

// Defined in package:objective_c's test-only util, reference_tracker.h.
@Native<Void Function(Pointer<Void>, Pointer<Bool>)>(
  symbol: 'attachReferenceTracker',
)
external void _attachReferenceTracker(
  Pointer<Void> host,
  Pointer<Bool> isAlive,
);

class ReferenceTracker {
  bool _tracking = false;
  final Pointer<Bool> _isAlivePtr;

  ReferenceTracker(Arena arena) : this._(arena, arena<Bool>()..value = true);

  ReferenceTracker._(Arena arena, this._isAlivePtr);

  bool get isAlive => _isAlivePtr.value;

  void track(ObjCObject host) {
    assert(!_tracking);
    _tracking = true;
    final hostRef = host.ref;
    _attachReferenceTracker(hostRef.pointer.cast(), _isAlivePtr);
  }

  void trackBlock(ObjCBlock host) {
    assert(!_tracking);
    _tracking = true;
    final hostRef = host.ref;
    _attachReferenceTracker(hostRef.pointer.cast(), _isAlivePtr);
  }
}

bool isValidClass(Pointer<Void> clazz) =>
    internal_for_testing.isValidClass(clazz.cast(), forceReloadClasses: true);

String findDylib(String name) =>
    p.join(packagePathForTests, '.dart_tool', 'lib', '$name.dylib');
