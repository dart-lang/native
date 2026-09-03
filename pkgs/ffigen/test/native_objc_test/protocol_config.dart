// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig([Uri? packageRoot]) {
  packageRoot ??= Uri.directory(Directory.current.path);
  final testDir = packageRoot.resolve('test/native_objc_test/');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: testDir.resolve('protocol_test_bindings.dart')),
      objectiveCFile: testDir.resolve('protocol_test_bindings.m'),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('protocol_test.h')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        func: (node) {
          const include = {
            'getClass',
            'getClassName',
            'objc_autoreleasePoolPop',
            'objc_autoreleasePoolPush',
          };
          if (include.contains(node.name)) {
            node.isIncluded = true;
          }
        },
        objCInterface: (node) {
          const include = {
            'ProtocolConsumer',
            'ObjCProtocolImpl',
            'ObjCProtocolImplMissingMethod',
          };
          if (include.contains(node.originalName)) {
            node.isIncluded = true;
          }
        },
        objCProtocol: (node) {
          const include = {
            'EmptyProtocol',
            'MyProtocol',
            'SecondaryProtocol',
            'UnusedProtocol',
          };
          if (include.contains(node.originalName)) {
            node.isIncluded = true;
          }
        },
      ),
    ],
  );
}
