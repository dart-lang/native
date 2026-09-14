// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../../objective_c/');
  final dartPath = outputDir != null
      ? outputDir.resolve('runtime_bindings_generated.dart')
      : packageRoot.resolve('lib/src/runtime_bindings_generated.dart');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      style: const NativeExternalBindings(),
      preamble: '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings for `src/objective_c_runtime.h`.
// Regenerate bindings with `dart run tool/generate_code.dart`.

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_element
// coverage:ignore-file
''',
    ),
    input: Input(
      entryPoints: [packageRoot.resolve('src/objective_c_runtime.h')],
    ),
    objectiveC: const ObjectiveC(generateForPackageObjectiveC: true),
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded =
              {
                'object_getClass',
                'sel_registerName',
                'sel_getName',
                'protocol_getMethodDescription',
                'protocol_getName',
              }.contains(node.originalName) ||
              node.originalName.startsWith('objc_');
          const rename = {
            'sel_registerName': 'registerName',
            'sel_getName': 'getName',
            'objc_getClass': 'getClass',
            'objc_retain': 'objectRetain',
            'objc_retainBlock': 'blockRetain',
            'objc_release': 'objectRelease',
            'objc_autorelease': 'objectAutorelease',
            'objc_msgSend': 'msgSend',
            'objc_msgSend_fpret': 'msgSendFpret',
            'objc_msgSend_stret': 'msgSendStret',
            'object_getClass': 'getObjectClass',
            'objc_copyClassList': 'copyClassList',
            'objc_getProtocol': 'getProtocol',
            'objc_autoreleasePoolPush': 'autoreleasePoolPush',
            'objc_autoreleasePoolPop': 'autoreleasePoolPop',
            'protocol_getMethodDescription': 'getMethodDescription',
            'protocol_getName': 'getProtocolName',
          };
          if (rename[node.name] case final r?) {
            node.name = r;
          }
          node.isLeaf = !node.originalName.startsWith('objc_msgSend');
        },
        struct: (node) {
          node.isIncluded = node.originalName.startsWith('_ObjC');
          final match = RegExp(r'^_ObjC(.*)$').firstMatch(node.name);
          if (match != null) {
            node.name = r'ObjC$1'.replaceAllMapped(
              RegExp(r'\$([0-9])'),
              (m) => match[int.parse(m[1]!)] ?? '',
            );
          }
          node.dependencies = CompoundDependencies.full;
        },
        global: (node) {
          node.isIncluded =
              {
                'NSKeyValueChangeIndexesKey',
                'NSKeyValueChangeKindKey',
                'NSKeyValueChangeNewKey',
                'NSKeyValueChangeNotificationIsPriorKey',
                'NSKeyValueChangeOldKey',
                'NSLocalizedDescriptionKey',
              }.contains(node.originalName) ||
              RegExp(r'^_NSConcrete.*Block$').hasMatch(node.originalName);
          node.name = node.name.replaceFirst(RegExp(r'^_'), '');
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
