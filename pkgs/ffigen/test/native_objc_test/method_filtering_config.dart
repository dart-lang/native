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
          node.isIncluded = node.originalName == 'MethodFilteringTestInterface';
        },
        objCProtocol: (node) {
          node.isIncluded = node.originalName == 'MethodFilteringTestProtocol';
        },
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface &&
              parent.originalName == 'MethodFilteringTestInterface') {
            node.isIncluded =
                !node.selector.startsWith('excluded') &&
                (node.selector == 'includedStaticMethod' ||
                    node.selector == 'includedProperty' ||
                    RegExp(r'inc.*Ins.*Me.*od:wi.*').hasMatch(node.selector));
          } else if (parent is ObjCProtocol &&
              parent.originalName == 'MethodFilteringTestProtocol') {
            node.isIncluded = node.selector == 'includedProtocolMethod';
          }
        },
      ),
    ],
  );
}
