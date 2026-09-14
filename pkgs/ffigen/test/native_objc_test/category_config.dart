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
      dart: DartOutput(path: testDir.resolve('category_test_bindings.dart')),
      objectiveCFile: testDir.resolve('category_test_bindings.m'),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(
      entryPoints: [
        testDir.resolve('category_test.h'),
        testDir.resolve('category_test.h'),
      ],
    ),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          const include = {'Thing', 'ChildOfThing', 'NSURL', 'ChildOfNSString'};
          node.isIncluded = include.contains(node.originalName);
          node.includeCategories = false;
        },
        objCCategory: (node) {
          const include = {
            'Sub',
            'Mul',
            'CatImplementsProto',
            'InstanceTypeCategory',
            'InterfaceOnBuiltInType',
            'StaticAndInstanceMethodsWithSameNameCategory',
            'NSString',
            'NSURLCategory',
          };
          node.isIncluded = include.contains(node.originalName);
        },
      ),
    ],
  );
}
