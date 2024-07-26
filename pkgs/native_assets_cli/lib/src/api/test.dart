import 'dart:io';

import 'package:meta/meta.dart' show isTest;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'architecture.dart';
import 'build_config.dart';
import 'build_mode.dart';
import 'build_output.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'os.dart';

@isTest
Future<void> testBuild({
  required String description,
  // ignore: inference_failure_on_function_return_type
  required Function(List<String> arguments) mainMethod,
  required void Function(BuildOutput output) check,
  BuildMode? buildMode,
  Architecture? targetArchitecture,
  OS? targetOS,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  CCompilerConfig? cCompiler,
  LinkModePreference? linkModePreference,
  Iterable<String>? supportedAssetTypes,
  bool? linkingEnabled,
}) async {
  test(
    description,
    () async {
      final tempDir = await _tempDirForTest();

      final outputDirectory = tempDir.resolve('output/');
      await Directory.fromUri(outputDirectory).create();

      final buildConfig = BuildConfig.build(
        outputDirectory: outputDirectory,
        packageName: await _packageName(),
        packageRoot: Directory.current.uri,
        buildMode: buildMode ?? BuildMode.release,
        targetArchitecture: targetArchitecture ?? Architecture.current,
        targetOS: targetOS ?? OS.current,
        linkModePreference: linkModePreference ?? LinkModePreference.dynamic,
        linkingEnabled: linkingEnabled ?? true,
        cCompiler: cCompiler,
        supportedAssetTypes: supportedAssetTypes,
        targetAndroidNdkApi: targetAndroidNdkApi,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
      ) as BuildConfigImpl;
      final buildConfigUri = tempDir.resolve('build_config.json');

      await _writeBuildConfig(buildConfigUri, buildConfig);

      await mainMethod(['--config=${buildConfigUri.toFilePath()}']);

      final hookOutput = await _readOutput(buildConfig);

      check(hookOutput);
    },
  );
}

Future<void> _writeBuildConfig(
  Uri buildConfigUri,
  BuildConfigImpl buildConfig,
) async {
  final file = File.fromUri(buildConfigUri);
  await file.create();
  file.writeAsStringSync(buildConfig.toJsonString());
}

Future<HookOutputImpl> _readOutput(BuildConfigImpl buildConfig) async {
  final hookOutput = HookOutputImpl.fromJsonString(
      await File.fromUri(buildConfig.outputFile).readAsString());
  return hookOutput;
}

Future<String> _packageName() async {
  final uri = Directory.current.uri.resolve('pubspec.yaml');
  final readAsString = await File.fromUri(uri).readAsString();
  final yaml = loadYaml(readAsString) as YamlMap;
  return yaml['name'] as String;
}

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<Uri> _tempDirForTest({String? prefix, bool keepTemp = false}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  // Deal with Windows temp folder aliases.
  final tempUri =
      Directory(await tempDir.resolveSymbolicLinks()).uri.normalizePath();
  if ((!Platform.environment.containsKey(keepTempKey) ||
          Platform.environment[keepTempKey]!.isEmpty) &&
      !keepTemp) {
    addTearDown(() => tempDir.delete(recursive: true));
  }
  return tempUri;
}
