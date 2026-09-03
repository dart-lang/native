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
      dart: DartOutput(
        path: testDir.resolve('method_filtering_test_bindings.dart'),
      ),
      objectiveCFile: testDir.resolve('method_filtering_test_bindings.m'),
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [testDir.resolve('method_filtering_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) {
          if (node.originalName == 'MethodFilteringTestInterface') {
            node.isIncluded = true;
          }
        },
        objCProtocol: (node) {
          if (node.originalName == 'MethodFilteringTestProtocol') {
            node.isIncluded = true;
          }
        },
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface &&
              parent.originalName == 'MethodFilteringTestInterface') {
            if (node.selector.startsWith('excluded')) {
              node.isIncluded = false;
            } else if (node.selector == 'includedStaticMethod' ||
                node.selector == 'includedProperty' ||
                RegExp(r'inc.*Ins.*Me.*od:wi.*').hasMatch(node.selector)) {
              node.isIncluded = true;
            } else {
              node.isIncluded = false;
            }
          } else if (parent is ObjCProtocol &&
              parent.originalName == 'MethodFilteringTestProtocol') {
            node.isIncluded = node.selector == 'includedProtocolMethod';
          }
        },
      ),
    ],
  );
}
