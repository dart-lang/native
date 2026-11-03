// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:file/local.dart';
import 'package:hooks/hooks.dart';
import 'package:hooks_runner/hooks_runner.dart';
import 'package:package_config/package_config.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test(
    'doctor hook runs across dependency graph, is not cached, and reports '
    'crashes',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final doctorAppUri = tempUri.resolve('doctor_app/');
        final counterFile = File.fromUri(
          tempUri.resolve('doctor_counter/counter.txt'),
        );

        await runPubGet(workingDirectory: doctorAppUri, logger: logger);

        // With includeDevDependencies: true (default), doctor_app runs:
        // - doctor_counter (dependency, success)
        // - doctor_app (root, partial)
        // - fail_build (dev_dependency, throws uncaught exception -> crash)
        final packageLayout = await PackageLayout.forDoctorFromWorkingDirectory(
          const LocalFileSystem(),
          doctorAppUri,
        );
        final runner = NativeAssetsBuildRunner.doctor(
          logger: logger,
          dartExecutable: dartExecutable,
          fileSystem: const LocalFileSystem(),
          packageLayout: packageLayout,
        );

        final packages = await runner.packagesWithDoctorHooks();
        expect(
          packages,
          unorderedEquals(['doctor_counter', 'doctor_app', 'fail_build']),
        );

        // First run.
        final result1 = (await runner.doctor()).success;
        expect(result1.validations.length, 3);
        expect(
          result1.packageValidations.keys,
          unorderedEquals(['doctor_counter', 'doctor_app', 'fail_build']),
        );
        final counterResult1 = result1.validations.firstWhere(
          (r) => r.title == 'Counter Tool',
        );
        expect(counterResult1.type, DoctorValidationType.success);
        expect(counterResult1.statusInfo, 'Run 1');
        expect(counterResult1.messages.single.message, 'Counter tool found');

        final appResult1 = result1.validations.firstWhere(
          (r) => r.title == 'App Tool',
        );
        expect(appResult1.type, DoctorValidationType.partial);

        final crashResult1 = result1.packageValidations['fail_build']!.single;
        expect(crashResult1.title, 'package:fail_build');
        expect(crashResult1.type, DoctorValidationType.crash);
        expect(
          crashResult1.messages.map((m) => m.message).join('\n'),
          contains('Unhandled exception in doctor hook'),
        );

        // Second run: doctor hooks must not be cached and should execute again.
        final result2 = (await runner.doctor()).success;
        final counterResult2 = result2.validations.firstWhere(
          (r) => r.title == 'Counter Tool',
        );
        expect(counterResult2.statusInfo, 'Run 2');
        expect(counterFile.readAsStringSync(), '2');
      });
    },
  );

  test(
    'doctor hook across pub workspace without runPackageName',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(
          targetUri: tempUri,
          addDependencyOverrides: false,
        );
        final packages = [
          'no_hook',
          'doctor_app',
          'doctor_counter',
          'fail_build',
        ];
        for (final package in packages) {
          final pubspecUri = tempUri.resolve('$package/pubspec.yaml');
          final pubspec = await File.fromUri(pubspecUri).readAsString();
          await File.fromUri(
            pubspecUri,
          ).writeAsString('$pubspec\nresolution: workspace\n');
        }

        final workspacePubspecUri = tempUri.resolve('pubspec.yaml');
        var workspacePubspec = '''
name: dart_lang_native_workspace

environment:
  sdk: '>=3.10.0 <4.0.0'

workspace:
  - no_hook/
  - doctor_app/
  - doctor_counter/
  - fail_build/

dependency_overrides:
''';
        for (final pkg in [
          'code_assets',
          'data_assets',
          'hooks',
          'native_toolchain_c',
          'record_use',
        ]) {
          workspacePubspec +=
              '''
  $pkg:
    path: ${pkgNativeAssetsBuilderUri.resolve('../$pkg/').toFilePath()}
''';
        }
        await File.fromUri(workspacePubspecUri).writeAsString(workspacePubspec);

        await runPubGet(workingDirectory: tempUri, logger: logger);

        final packageConfigUri = tempUri.resolve(
          '.dart_tool/package_config.json',
        );
        final packageConfig = await loadPackageConfigUri(packageConfigUri);
        final packageLayout = PackageLayout.forDoctorFromPackageConfig(
          const LocalFileSystem(),
          packageConfig,
          packageConfigUri,
          includeDevDependencies: false,
        );
        final runner = NativeAssetsBuildRunner.doctor(
          logger: logger,
          dartExecutable: dartExecutable,
          fileSystem: const LocalFileSystem(),
          packageLayout: packageLayout,
        );

        expect(
          await runner.packagesWithDoctorHooks(),
          unorderedEquals([
            'native_toolchain_c',
            'doctor_counter',
            'doctor_app',
            'fail_build',
          ]),
        );
        final result = (await runner.doctor()).success;
        expect(
          result.packageValidations.keys,
          unorderedEquals([
            'native_toolchain_c',
            'doctor_counter',
            'doctor_app',
            'fail_build',
          ]),
        );
      });
    },
  );

  test(
    'doctor hook with malformed output, schema error, or compile error '
    'converts to crash validation result',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('wrong_build_output/');
        final hookFile = File.fromUri(packageUri.resolve('hook/doctor.dart'));

        await runPubGet(workingDirectory: packageUri, logger: logger);

        final packageLayout = await PackageLayout.forDoctorFromWorkingDirectory(
          const LocalFileSystem(),
          packageUri,
        );
        final runner = NativeAssetsBuildRunner.doctor(
          logger: logger,
          dartExecutable: dartExecutable,
          fileSystem: const LocalFileSystem(),
          packageLayout: packageLayout,
        );

        // 1. Malformed JSON output -> _readDoctorOutputFromUri failure.
        final result1 = (await runner.doctor()).success;
        final validation1 =
            result1.packageValidations['wrong_build_output']!.single;
        expect(validation1.title, 'package:wrong_build_output');
        expect(validation1.type, DoctorValidationType.crash);
        expect(
          validation1.statusInfo,
          'the doctor check produced invalid output',
        );

        // 2. Valid JSON with invalid DoctorOutput schema ->
        // ProtocolBase.validateDoctorOutput failure.
        final hookContents = await hookFile.readAsString();
        await hookFile.writeAsString(
          hookContents.replaceAll(
            '{not valid json',
            '{"validations": "not a list"}',
          ),
        );
        final result2 = (await runner.doctor()).success;
        final validation2 =
            result2.packageValidations['wrong_build_output']!.single;
        expect(validation2.title, 'package:wrong_build_output');
        expect(validation2.type, DoctorValidationType.crash);
        expect(
          validation2.statusInfo,
          'the doctor check produced invalid output',
        );
        expect(
          validation2.messages.map((m) => m.message).join('\n'),
          contains('Expected a List<Object?>?'),
        );

        // 3. Compile error in hook/doctor.dart -> _compileHookForPackageCached
        // failure.
        await hookFile.writeAsString('void main() { invalid dart syntax }');
        final result3 = (await runner.doctor()).success;
        final validation3 =
            result3.packageValidations['wrong_build_output']!.single;
        expect(validation3.title, 'package:wrong_build_output');
        expect(validation3.type, DoctorValidationType.crash);
        expect(validation3.statusInfo, 'hook/doctor.dart failed to compile');

        // 4. Deleting hook/doctor.dart -> empty doctorPlan returns empty
        // DoctorResult.
        await hookFile.delete();
        final runnerEmpty = NativeAssetsBuildRunner.doctor(
          logger: logger,
          dartExecutable: dartExecutable,
          fileSystem: const LocalFileSystem(),
          packageLayout: packageLayout,
        );
        final result4 = (await runnerEmpty.doctor()).success;
        expect(result4.validations, isEmpty);
        expect(result4.packageValidations, isEmpty);
      });
    },
  );

  test(
    'doctor hook runs native_toolchain_c transitively for native_add',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final nativeAddUri = tempUri.resolve('native_add/');

        await runPubGet(workingDirectory: nativeAddUri, logger: logger);

        final packageLayout = await PackageLayout.forDoctorFromWorkingDirectory(
          const LocalFileSystem(),
          nativeAddUri,
          includeDevDependencies: false,
        );
        final runner = NativeAssetsBuildRunner.doctor(
          logger: logger,
          dartExecutable: dartExecutable,
          fileSystem: const LocalFileSystem(),
          packageLayout: packageLayout,
        );

        expect(await runner.packagesWithDoctorHooks(), ['native_toolchain_c']);

        final result = (await runner.doctor()).success;
        expect(result.packageValidations.keys, ['native_toolchain_c']);
        final validations = result.packageValidations['native_toolchain_c']!;
        expect(validations, hasLength(2));
        expect(validations.first.title, startsWith('C Toolchain'));
        expect(
          validations.first.type,
          isIn([DoctorValidationType.success, DoctorValidationType.partial]),
        );
        expect(validations.last.title, 'Android NDK C Toolchain');
      });
    },
  );
}
