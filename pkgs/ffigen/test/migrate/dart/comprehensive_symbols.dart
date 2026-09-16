// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/migrate/yaml/');
  await FfiGenerator(
    output: Output(
      dart: DartOutput(
        path: configDir.resolve('comprehensive_symbols_bindings.dart'),
      ),
      objectiveCFile: configDir.resolve(
        'comprehensive_symbols_bindings.dart.m',
      ),
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
        objCInterface: (node) {
          node.isIncluded = {
            'NSColorPicker',
            'NSTextList',
          }.contains(node.originalName);
        },
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
  ).generate();
}
