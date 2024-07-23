import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import '../helpers.dart';

Future<Uri> buildTestArchive(Uri tempUri) async {
  final test1Uri = packageUri.resolve('test/clinker/testfiles/linker/test1.c');
  final test2Uri = packageUri.resolve('test/clinker/testfiles/linker/test2.c');
  if (!await File.fromUri(test1Uri).exists() ||
      !await File.fromUri(test2Uri).exists()) {
    throw Exception('Run the test from the root directory.');
  }
  const name = 'static_test';

  final logMessages = <String>[];
  final logger = createCapturingLogger(logMessages);

  final buildConfig = BuildConfig.build(
    outputDirectory: tempUri,
    packageName: name,
    packageRoot: tempUri,
    targetArchitecture: Architecture.current,
    targetOS: OS.current,
    buildMode: BuildMode.release,
    linkModePreference: LinkModePreference.dynamic,
    cCompiler: CCompilerConfig(
      compiler: cc,
      envScript: envScript,
      envScriptArgs: envScriptArgs,
    ),
    linkingEnabled: false,
  );
  final buildOutput = BuildOutput();
  final cbuilder = CBuilder.library(
    name: name,
    assetName: 'somename',
    sources: [test1Uri.toFilePath(), test2Uri.toFilePath()],
    linkModePreference: LinkModePreference.static,
  );
  await cbuilder.run(
    config: buildConfig,
    output: buildOutput,
    logger: logger,
  );

  return buildOutput.assets.first.file!;
}
