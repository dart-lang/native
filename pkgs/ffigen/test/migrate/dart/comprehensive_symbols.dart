// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

FfiGenerator getConfig({Uri? outputDir, Uri? packageRoot}) {
  packageRoot ??= Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/migrate/yaml/');
  final dartPath = outputDir != null
      ? outputDir.resolve('comprehensive_symbols_bindings.dart')
      : configDir.resolve('comprehensive_symbols_bindings.dart');
  final objcPath = outputDir != null
      ? outputDir.resolve('comprehensive_symbols_bindings.dart.m')
      : configDir.resolve('comprehensive_symbols_bindings.dart.m');
  return FfiGenerator(
    output: Output(
      dart: DartOutput(path: dartPath),
      objectiveCFile: objcPath,
      style: const DynamicLibraryBindings(
        wrapperName: 'ComprehensiveSymbols',
        wrapperDocComment: 'Comprehensive symbols bindings',
      ),
    ),
    input: Input(
      entryPoints: [
        xcodeUri.resolve(
          'Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/AppKit.framework/Headers/NSColorPicker.h',
        ),
        macSdkUri.resolve(
          'System/Library/Frameworks/AppKit.framework/Headers/NSTextList.h',
        ),
      ],
    ),
    objectiveC: const ObjectiveC(),
    importType: importFromSymbolFile(
      packageRoot.resolve(
        'example/shared_bindings/lib/generated/base_symbols.yaml',
      ),
    ),
    visitors: [
      Visitor(
        objCInterface: (node) => node.isIncluded = {
          'NSColorPicker',
          'NSTextList',
        }.contains(node.originalName),
        objCMethod: (node) {
          final parent = node.parent;
          if (parent is ObjCInterface) {
            if (parent.originalName == 'NSTextList' &&
                node.selector == 'includesTextListMarkers') {
              node.isIncluded = false;
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
