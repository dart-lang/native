// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../../objective_c/');
  final dartPath = outputDir != null
      ? outputDir.resolve('c_bindings_generated.dart')
      : packageRoot.resolve('lib/src/c_bindings_generated.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const NativeExternalBindings(
        assetId: 'package:objective_c/objective_c.dylib',
      ),
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c.h` etc.
// Regenerate bindings with `dart run tool/generate_code.dart`.

// coverage:ignore-file
''',
    ),
    input: Input(
      entryPoints: [
        packageRoot.resolve('src/include/dart_api_dl.h'),
        packageRoot.resolve('src/objective_c.h'),
        packageRoot.resolve('src/os_version.h'),
      ],
    ),
    objectiveC: const ObjectiveC(generateForPackageObjectiveC: true),
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded =
              node.originalName == 'newFinalizableHandle' ||
              node.originalName.startsWith('DOBJC_');
          node.name = node.name.replaceFirst(RegExp(r'^DOBJC_'), '');
          node.isLeaf = !{
            'DOBJC_deleteFinalizableHandle',
            'DOBJC_disposeObjCBlockWithClosure',
            'DOBJC_newFinalizableBool',
            'DOBJC_newFinalizableHandle',
            'DOBJC_awaitWaiter',
            'DOBJC_invokeListenerPortBlock',
            'DOBJC_invokeBlockingPortBlock',
          }.contains(node.originalName);
        },
        struct: (node) {
          node.isIncluded = {
            '_ObjCBlockImpl',
            '_ObjCBlockDesc',
            '_Version',
          }.contains(node.originalName);
          const rename = {
            '_Dart_FinalizableHandle': 'Dart_FinalizableHandle_',
            '_DOBJC_Context': 'DOBJC_Context',
          };
          if (rename[node.name] case final r?) {
            node.name = r;
          }
          final match = RegExp(r'^_ObjC(.*)$').firstMatch(node.name);
          if (match != null) {
            node.name = r'ObjC$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
          node.dependencies = CompoundDependencies.opaque;
        },
        macroConstant: (node) =>
            node.isIncluded = node.originalName == 'ILLEGAL_PORT',
        typealias: (node) =>
            node.isIncluded = (node.originalName == 'Dart_FinalizableHandle')
            ? TypealiasInclude.ifUsed
            : TypealiasInclude.never,
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
