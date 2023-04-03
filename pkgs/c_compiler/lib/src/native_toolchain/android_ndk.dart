// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';

final androidNdk = Tool(
  name: 'Android NDK',
  defaultResolver: AndroidNdkResolver(),
);

/// A clang that knows how to target Android.
final androidNdkClang = Tool(
  name: 'Android NDK Clang',
  defaultResolver: AndroidNdkResolver(),
);

class AndroidNdkResolver implements ToolResolver {
  final installLocationResolver = PathVersionResolver(
    wrappedResolver: ToolResolvers([
      RelativeToolResolver(
        toolName: 'Android NDK',
        wrappedResolver: PathToolResolver(toolName: 'ndk-build'),
        relativePath: Uri(path: '.'),
      ),
      InstallLocationResolver(
        toolName: 'Android NDK',
        paths: [
          if (Platform.isLinux) ...[
            '\$HOME/Android/Sdk/ndk/*/',
            '\$HOME/Android/Sdk/ndk-bundle/',
          ],
        ],
      ),
    ]),
  );

  @override
  Future<List<ToolInstance>> resolve() async {
    final ndkInstances = await installLocationResolver.resolve();

    return [
      for (final ndkInstance in ndkInstances) ...[
        ndkInstance,
        ...await tryResolveClang(ndkInstance)
      ]
    ];
  }

  Future<List<ToolInstance>> tryResolveClang(
      ToolInstance androidNdkInstance) async {
    final result = <ToolInstance>[];
    final prebuiltUri =
        androidNdkInstance.uri.resolve('toolchains/llvm/prebuilt/');
    final prebuiltDir = Directory.fromUri(prebuiltUri);
    final hostArchDirs =
        (await prebuiltDir.list().toList()).whereType<Directory>().toList();
    for (final hostArchDir in hostArchDirs) {
      final clangUri = hostArchDir.uri.resolve('bin/clang');
      if (await File.fromUri(clangUri).exists()) {
        result.add(await CliVersionResolver.lookupVersion(ToolInstance(
          tool: androidNdkClang,
          uri: clangUri,
        )));
      }
    }
    return result;
  }
}
