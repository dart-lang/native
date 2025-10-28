// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import 'clang.dart';

final androidNdk = Tool(
  name: 'Android NDK',
  defaultResolver: _AndroidNdkResolver(),
);

/// [clang] with [Tool.defaultResolver] for the [OS.android] NDK.
final androidNdkClang = Tool(
  name: clang.name,
  defaultResolver: _AndroidNdkResolver(),
);

/// [llvmAr] with [Tool.defaultResolver] for the [OS.android] NDK.
final androidNdkLlvmAr = Tool(
  name: llvmAr.name,
  defaultResolver: _AndroidNdkResolver(),
);

/// [lld] with [Tool.defaultResolver] for the [OS.android] NDK.
final androidNdkLld = Tool(
  name: lld.name,
  defaultResolver: _AndroidNdkResolver(),
);

class _AndroidNdkResolver implements ToolResolver {
  ToolResolver installLocationResolver(ToolResolvingContext context) =>
      PathVersionResolver(
        wrappedResolver: ToolResolvers([
          RelativeToolResolver(
            toolName: 'Android NDK',
            wrappedResolver: PathToolResolver(
              toolName: 'ndk-build',
              executableName: Platform.isWindows
                  ? 'ndk-build.cmd'
                  : 'ndk-build',
            ),
            relativePath: Uri(path: ''),
          ),
          InstallLocationResolver(
            toolName: 'Android NDK',
            paths: [
              if (context.environment['ANDROID_HOME'] case final androidHome?)
                p.join(androidHome, 'ndk/*/'),
              for (final ndkHomeKey in _ndkHomeEnvironmentVariables)
                if (context.environment[ndkHomeKey] case final home?) home,

              if (Platform.isLinux) ...[
                '\$HOME/.androidsdkroot/ndk/*/', // Firebase Studio
                '\$HOME/Android/Sdk/ndk/*/',
                '\$HOME/Android/Sdk/ndk-bundle/',
              ],
              if (Platform.isMacOS) ...['\$HOME/Library/Android/sdk/ndk/*/'],
              if (Platform.isWindows) ...[
                '\$HOME/AppData/Local/Android/Sdk/ndk/*/',
              ],
            ],
          ),
        ]),
      );

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final ndkInstances = await installLocationResolver(
      context,
    ).resolve(context);

    return [
      for (final ndkInstance in ndkInstances) ...[
        ndkInstance,
        ...await tryResolveClang(ndkInstance, logger: context.logger),
      ],
    ];
  }

  Future<List<ToolInstance>> tryResolveClang(
    ToolInstance androidNdkInstance, {
    required Logger? logger,
  }) async {
    final result = <ToolInstance>[];
    final prebuiltUri = androidNdkInstance.uri.resolve(
      'toolchains/llvm/prebuilt/',
    );
    final prebuiltDir = Directory.fromUri(prebuiltUri);
    if (!prebuiltDir.existsSync()) {
      return [];
    }
    final hostArchDirs = (await prebuiltDir.list().toList())
        .whereType<Directory>()
        .toList();
    for (final hostArchDir in hostArchDirs) {
      final clangUri = hostArchDir.uri
          .resolve('bin/')
          .resolve(OS.current.executableFileName('clang'));
      if (await File.fromUri(clangUri).exists()) {
        result.add(
          await CliVersionResolver.lookupVersion(
            ToolInstance(tool: androidNdkClang, uri: clangUri),
            logger: logger,
          ),
        );
      }
      final arUri = hostArchDir.uri
          .resolve('bin/')
          .resolve(OS.current.executableFileName('llvm-ar'));
      if (await File.fromUri(arUri).exists()) {
        result.add(
          await CliVersionResolver.lookupVersion(
            ToolInstance(tool: androidNdkLlvmAr, uri: arUri),
            logger: logger,
          ),
        );
      }
      final ldUri = hostArchDir.uri
          .resolve('bin/')
          .resolve(OS.current.executableFileName('ld.lld'));
      if (await File.fromUri(arUri).exists()) {
        result.add(
          await CliVersionResolver.lookupVersion(
            ToolInstance(tool: androidNdkLld, uri: ldUri),
            logger: logger,
          ),
        );
      }
    }
    return result;
  }

  static const _ndkHomeEnvironmentVariables = [
    // https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md#environment-variables-2
    'ANDROID_NDK',
    'ANDROID_NDK_HOME',
    'ANDROID_NDK_LATEST_HOME',
    'ANDROID_NDK_ROOT',
  ];
}
