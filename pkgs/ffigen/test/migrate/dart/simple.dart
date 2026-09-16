// ignore_for_file: unused_import
import 'dart:io';
import 'package:ffigen/ffigen.dart';
import 'package:glob/glob.dart';

Future<void> main() async {
  final packageRoot = Platform.script.resolve('../../../');
  final configDir = packageRoot.resolve('test/migrate/yaml/');
  await FfiGenerator(
    output: Output(
      dart: DartOutput(path: configDir.resolve('simple_bindings.dart')),
      style: const DynamicLibraryBindings(
        wrapperName: 'SimpleBindings',
        wrapperDocComment:
            'Bindings for a simple 2D math and graphics library.',
      ),
      commentType: const CommentType(CommentStyle.any, CommentLength.full),
    ),
    input: Input(entryPoints: [configDir.resolve('simple.h')]),
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded = true;
        },
        struct: (node) {
          node.isIncluded = true;
          node.dependencies = CompoundDependencies.full;
        },
        union: (node) {
          node.isIncluded = true;
          node.dependencies = CompoundDependencies.full;
        },
        enumClass: (node) {
          node.isIncluded = true;
        },
        global: (node) {
          node.isIncluded = true;
        },
        macroConstant: (node) {
          node.isIncluded = true;
        },
        typealias: (node) {
          node.isIncluded = TypealiasInclude.ifUsed;
        },
      ),
    ],
  ).generate();
}
