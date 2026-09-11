// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/native_objc_test/');
  final dartPath = outputDir != null
      ? outputDir.resolve('method_filtering_test_bindings.dart')
      : configDir.resolve('method_filtering_test_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('method_filtering_test_bindings.m')
      : configDir.resolve('method_filtering_test_bindings.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [configDir.resolve('method_filtering_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) => node.isIncluded =
            node.originalName == 'MethodFilteringTestInterface',
        objCProtocol: (node) => node.isIncluded =
            node.originalName == 'MethodFilteringTestProtocol',
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface) {
            if (RegExp(r'^Metho.*ngTe.*rface$').hasMatch(parent.originalName)) {
              node.isIncluded = true;
            }
            if (parent.originalName == 'MethodFilteringTestInterface') {
              node.isIncluded =
                  !node.selector.startsWith('excluded') &&
                  ({
                        'includedStaticMethod',
                        'excludedStaticMethod',
                        'includedProperty',
                      }.contains(node.selector) ||
                      RegExp(
                        r'^inc.*Ins.*Me.*od:wi.*$',
                      ).hasMatch(node.selector));
            }
          }
          if (parent is ObjCProtocol) {
            if (RegExp(r'^Met.*ringT.*ocol$').hasMatch(parent.originalName)) {
              node.isIncluded = node.selector == 'includedProtocolMethod';
            }
          }
        },
      ),
    ],
  );
}

Future<void> main(List<String> args) async {
  final outputDir = args.isNotEmpty
      ? Uri.directory(args.first)
      : Platform.environment['OUTPUT_DIR'] != null
      ? Uri.directory(Platform.environment['OUTPUT_DIR']!)
      : null;
  await getConfig(outputDir: outputDir).generate();
}
