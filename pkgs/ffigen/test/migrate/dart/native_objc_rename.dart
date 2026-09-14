// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/native_objc_test/');
  final dartPath = outputDir != null
      ? outputDir.resolve('rename_test_bindings.dart')
      : configDir.resolve('rename_test_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('rename_test_bindings.dart.m')
      : configDir.resolve('rename_test_bindings.dart.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const NativeExternalBindings(assetId: 'package:ffigen/objc_test'),
    ),
    input: Input(entryPoints: [configDir.resolve('rename_test.m')]),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        struct: (node) {
          node.isIncluded = node.originalName == 'CollidingStructName';
          node.dependencies = CompoundDependencies.full;
        },
        objCInterface: (node) {
          node.isIncluded = node.originalName == '_Renamed';
          node.name = node.name.replaceFirst(RegExp(r'^_'), '');
        },
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface) {
            if (parent.originalName == '_Renamed' &&
                node.selector == 'renamedMethod:otherArg:') {
              node.name = 'fooBarBaz';
            }
            if (parent.originalName == '_Renamed' &&
                RegExp(r'^ren.*P.*rty$').hasMatch(node.selector)) {
              node.name = 'reProp';
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
