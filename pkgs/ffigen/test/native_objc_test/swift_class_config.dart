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
      dart: DartOutput(path: testDir.resolve('swift_class_test_bindings.dart')),
      objectiveCFile: testDir.resolve('swift_class_test_bindings.m'),
      style: const NativeExternalBindings(
        assetId: 'package:ffigen/swift_class_test',
      ),
    ),
    input: Input(entryPoints: [testDir.resolve('swift_class_test-Swift.h')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          node.isIncluded = node.originalName == 'MySwiftClass';
          node.module = 'swift_class_test';
        },
        objCProtocol: (node) {
          node.isIncluded = node.originalName == 'MySwiftProtocol';
          node.module = 'swift_class_test';
        },
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface &&
              parent.originalName == 'NSURLProtectionSpace' &&
              node.selector == 'isProxy') {
            node.isIncluded = false;
          }
        },
      ),
    ],
  );
}
