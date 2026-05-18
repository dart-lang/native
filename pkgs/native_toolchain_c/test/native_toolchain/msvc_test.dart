// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('windows')
@OnPlatform({'windows': Timeout.factor(10)})
library;

import 'dart:convert';
import 'dart:io';

import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/utils/env_from_bat.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isWindows) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  test('vswhere', () async {
    final instances = await vswhere.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('visualStudio', () async {
    final instances = await visualStudio.defaultResolver!.resolve(
      systemContext,
    );
    expect(instances.isNotEmpty, true);
  });

  test('msvc', () async {
    final instances = await msvc.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('parseVswhere handles mixed installations', () async {
    final tempUri = await tempDirForTest();
    final ssmsDir = Directory.fromUri(
      tempUri.resolve('Microsoft SQL Server Management Studio 22/Release'),
    );
    final visualStudioDir = Directory.fromUri(
      tempUri.resolve('Microsoft Visual Studio/18/Community'),
    );
    await ssmsDir.create(recursive: true);
    await visualStudioDir.create(recursive: true);

    final instances = VisualStudioResolver().parseVswhere(
      jsonEncode([
        {
          'installationName': 'SSMS/22.5.0+11709.299',
          'installationPath': ssmsDir.path,
          'installationVersion': '22.5.11709.299',
          'productId': 'Microsoft.VisualStudio.Product.Ssms',
          'displayName': 'SQL Server Management Studio 22',
        },
        {
          'installationName': 'VisualStudio/18.5.1+11716.220',
          'installationPath': visualStudioDir.path,
          'installationVersion': '18.5.11716.220',
          'productId': 'Microsoft.VisualStudio.Product.Community',
          'displayName': 'Visual Studio Community 2026',
        },
        {
          'installationName': 'Incomplete entry',
          'productId': 'Microsoft.VisualStudio.Product.Incomplete',
        },
      ]),
    );

    expect(instances, hasLength(2));
    expect(instances.first.uri, ssmsDir.uri);
    expect(instances.last.uri, visualStudioDir.uri);
    expect(instances.map((instance) => instance.version!.major), [22, 18]);
  });

  test('lib', () async {
    final instances = await lib.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('libIA32', () async {
    final instances = await libIA32.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('libArm64', () async {
    final instances = await libArm64.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('link', () async {
    final instances = await msvcLink.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('linkIA32', () async {
    final instances = await linkIA32.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('linkArm64', () async {
    final instances = await linkArm64.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('dumpbin', () async {
    final instances = await dumpbin.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
  });

  test('vcvars32 from cl.exe', () async {
    final clInstances = await clIA32.defaultResolver!.resolve(systemContext);
    expect(clInstances.isNotEmpty, true);

    final instances = await vcvars(
      clInstances.first,
    ).defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    expect(instance.tool, vcvars32);
    final env = await environmentFromBatchFile(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvars64 from cl.exe', () async {
    final clInstances = await cl.defaultResolver!.resolve(systemContext);
    expect(clInstances.isNotEmpty, true);

    final instances = await vcvars(
      clInstances.first,
    ).defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    expect(instance.tool, vcvars64);
    final env = await environmentFromBatchFile(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvarsarm64 from cl.exe', () async {
    final clInstances = await clArm64.defaultResolver!.resolve(systemContext);
    expect(clInstances.isNotEmpty, true);

    final instances = await vcvars(
      clInstances.first,
    ).defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    expect(instance.tool, vcvarsarm64);
    final env = await environmentFromBatchFile(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvars32', () async {
    final instances = await vcvars32.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await environmentFromBatchFile(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvars64', () async {
    final instances = await vcvars64.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await environmentFromBatchFile(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvarsarm64', () async {
    final instances = await vcvarsarm64.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await environmentFromBatchFile(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vcvarsall', () async {
    final instances = await vcvarsall.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await environmentFromBatchFile(
      instance.uri,
      arguments: ['x64', 'uwp', '10.0'],
    );
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });

  test('vsDevCmd', () async {
    final instances = await vsDevCmd.defaultResolver!.resolve(systemContext);
    expect(instances.isNotEmpty, true);
    final instance = instances.first;
    final env = await environmentFromBatchFile(instance.uri);
    expect(env['INCLUDE'] != null, true);
    expect(env['WindowsSdkDir'] != null, true); // stdio.h
  });
}
