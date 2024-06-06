// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/src/api/build_config.dart';
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  late Uri outDirUri;
  late String packageName;
  late Uri packageRootUri;
  late Uri fakeClang;
  late Uri fakeLd;
  late Uri fakeAr;
  late Uri fakeCl;
  late Uri fakeVcVars;
  late Uri buildConfigUri;
  late BuildConfig config1;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outDirUri = tempUri.resolve('out1/');
    await Directory.fromUri(outDirUri).create();
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    await Directory.fromUri(packageRootUri).create();
    fakeClang = tempUri.resolve('fake_clang');
    await File.fromUri(fakeClang).create();
    fakeLd = tempUri.resolve('fake_ld');
    await File.fromUri(fakeLd).create();
    fakeAr = tempUri.resolve('fake_ar');
    await File.fromUri(fakeAr).create();
    fakeCl = tempUri.resolve('cl.exe');
    await File.fromUri(fakeCl).create();
    fakeVcVars = tempUri.resolve('vcvarsall.bat');
    await File.fromUri(fakeVcVars).create();

    config1 = BuildConfig.build(
      outputDirectory: outDirUri,
      packageName: packageName,
      packageRoot: tempUri,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.iOS,
      targetIOSSdk: IOSSdk.iPhoneOS,
      cCompiler: CCompilerConfig(
        compiler: fakeClang,
        linker: fakeLd,
        archiver: fakeAr,
      ),
      buildMode: BuildMode.release,
      linkModePreference: LinkModePreference.preferDynamic,
    );
    final configJson = (config1 as BuildConfigImpl).toJsonString();
    buildConfigUri = tempUri.resolve('build_config.json');
    await File.fromUri(buildConfigUri).writeAsString(configJson);
  });

  test('build method', () async {
    await build(['--config', buildConfigUri.toFilePath()],
        (config, output) async {
      output.addDependency(packageRootUri.resolve('foo'));
    });
    final buildOutputUri =
        outDirUri.resolve((config1 as BuildConfigImpl).outputName);
    expect(File.fromUri(buildOutputUri), exists);
  });
}
