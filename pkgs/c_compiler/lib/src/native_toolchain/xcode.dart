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

/// The iPhoneOS SDK.
final Tool iPhoneOSSdk = Tool(
  name: 'iPhoneOS SDK',
  defaultResolver: _XCodeSdkResolver(),
);

/// The iPhoneOS SDK.
final Tool iPhoneSimulatorSdk = Tool(
  name: 'iPhoneSimulator SDK',
  defaultResolver: _XCodeSdkResolver(),
);

class _XCodeSdkResolver implements ToolResolver {
  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    final xcrunInstances = await xcrun.defaultResolver!.resolve(logger: logger);

    return [
      for (final xcrunInstance in xcrunInstances) ...[
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
    ];
  }

  Future<List<ToolInstance>> tryResolveSdk({
    required ToolInstance xcrunInstance,
    required String sdk,
    required Tool tool,
    Logger? logger,
  }) async {
    final result = await runProcess(
      executable: xcrunInstance.uri,
      arguments: ['--sdk', sdk, '--show-sdk-path'],
    );
    final uri = Uri.directory(result.stdout.trim());
    assert(await Directory.fromUri(uri).exists());
    logger?.fine('Found $sdk at ${uri.toFilePath()}}');
    return [ToolInstance(tool: tool, uri: uri)];
  }
}
