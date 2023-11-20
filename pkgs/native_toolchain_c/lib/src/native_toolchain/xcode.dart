// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import '../utils/run_process.dart';

/// The xcrun from XCode.
///
/// https://developer.apple.com/xcode/
final Tool xcrun = Tool(
  name: 'xcrun',
  defaultResolver: CliVersionResolver(
    wrappedResolver: PathToolResolver(
      toolName: 'xcrun',
      executableName: 'xcrun',
    ),
  ),
);

/// The MacOSX SDK.
final Tool macosxSdk = Tool(
  name: 'MacOSX SDK',
  defaultResolver: XCodeSdkResolver(),
);

/// The iPhoneOS SDK.
final Tool iPhoneOSSdk = Tool(
  name: 'iPhoneOS SDK',
  defaultResolver: XCodeSdkResolver(),
);

/// The iPhoneSimulator SDK.
final Tool iPhoneSimulatorSdk = Tool(
  name: 'iPhoneSimulator SDK',
  defaultResolver: XCodeSdkResolver(),
);

class XCodeSdkResolver implements ToolResolver {
  @override
  Future<List<ToolInstance>> resolve({required Logger? logger}) async {
    final xcrunInstances = await xcrun.defaultResolver!.resolve(logger: logger);

    return [
      for (final xcrunInstance in xcrunInstances) ...[
        ...await tryResolveSdk(
          xcrunInstance: xcrunInstance,
          sdk: 'macosx',
          tool: macosxSdk,
          logger: logger,
        ),
        ...await tryResolveSdk(
          xcrunInstance: xcrunInstance,
          sdk: 'iphoneos',
          tool: iPhoneOSSdk,
          logger: logger,
        ),
        ...await tryResolveSdk(
          xcrunInstance: xcrunInstance,
          sdk: 'iphonesimulator',
          tool: iPhoneSimulatorSdk,
          logger: logger,
        ),
      ],
      // xcrun --sdk macosx --show-sdk-path)
    ];
  }

  static Future<List<ToolInstance>> tryResolveSdk({
    required ToolInstance xcrunInstance,
    required String sdk,
    required Tool tool,
    required Logger? logger,
  }) async {
    final result = await runProcess(
      executable: xcrunInstance.uri,
      arguments: ['--sdk', sdk, '--show-sdk-path'],
      logger: logger,
    );
    if (result.exitCode == 1) {
      assert(result.stderr.contains('cannot be located'));
      logger?.warning('SDK $sdk not installed.');
      return [];
    }
    assert(result.exitCode == 0);
    final uriSymbolic = Uri.directory(result.stdout.trim());
    logger?.fine('Found $sdk at ${uriSymbolic.toFilePath()}');
    final uri = Uri.directory(
        await Directory.fromUri(uriSymbolic).resolveSymbolicLinks());
    if (uriSymbolic != uri) {
      logger?.fine('Found $sdk at ${uri.toFilePath()}');
    }
    assert(await Directory.fromUri(uri).exists());
    return [ToolInstance(tool: tool, uri: uri)];
  }
}
