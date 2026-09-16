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
        path: configDir.resolve('comprehensive_c_native_bindings.dart'),
      ),
      style: const NativeExternalBindings(
        assetId: 'package:ffigen/c_native_test',
      ),
      commentType: const CommentType.none(),
    ),
    input: Input(
      entryPoints: [configDir.resolve('comprehensive_c_native.h')],
      compilerOptions: [
        '-I${configDir.resolve('.').toFilePath()}',
        if (Platform.isMacOS) ...['-isysroot', macSdkPath],
      ],
    ),
    visitors: [
      Visitor(
        func: (node) {
          node.isIncluded = node.originalName == 'add';
          node.isLeaf = true;
        },
      ),
    ],
  ).generate();
}
