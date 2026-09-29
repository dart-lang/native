// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:code_assets/code_assets.dart';
import 'package:file/file.dart';

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import 'clang.dart';

/// The LLVM Linker (`lld`) bundled with the Dart SDK.
final Tool sdkLld = Tool(
  name: lld.name,
  defaultResolver: CliVersionResolver(
    arguments: const ['-flavor', 'gnu', '--version'],
    wrappedResolver: const SdkLldResolver(),
  ),
);

/// Resolves the minimal `lld` binary bundled inside the running Dart SDK.
final class SdkLldResolver implements ToolResolver {
  /// Creates a resolver for the Dart SDK's bundled `lld` executable.
  const SdkLldResolver();

  @override
  Future<List<ToolInstance>> resolve(ToolResolvingContext context) async {
    final logger = context.logger;
    final lldExe = OS.current.executableFileName('lld');
    final executableUri = Uri.file(Platform.resolvedExecutable);
    final candidateUris = <Uri>[
      // Packaged Dart SDK layout: <sdk>/bin/dart -> <sdk>/bin/utils/lld
      executableUri.resolve('utils/$lldExe'),
      // Internal SDK layout: <sdk>/bin/dart -> <sdk>/lib/_internal/lld/lld
      executableUri.resolve('../lib/_internal/lld/$lldExe'),
      // Build root layout: out/<Config>/dart -> out/<Config>/dart-sdk/bin/utils/lld
      executableUri.resolve('dart-sdk/bin/utils/$lldExe'),
      // Build root layout: out/<Config>/dart -> out/<Config>/lld
      executableUri.resolve(lldExe),
      // Stripped exe in build root: out/<Config>/exe.stripped/dart -> out/<Config>/lld
      executableUri.resolve('../$lldExe'),
      // Checked-in prebuilt SDK in repo: tools/sdks/dart-sdk/bin/dart -> out/ReleaseX64/...
      executableUri.resolve(
        '../../../../out/ReleaseX64/dart-sdk/bin/utils/$lldExe',
      ),
      executableUri.resolve('../../../../out/ReleaseX64/$lldExe'),
    ];

    final seenPaths = <String>{};
    final instances = <ToolInstance>[];
    for (final uri in candidateUris) {
      final file = context.fileSystem.file(uri);
      final normalizedPath = file.path;
      if (!seenPaths.add(normalizedPath)) {
        continue;
      }
      if (await file.exists()) {
        final resolvedUri = Uri.file(await file.resolveSymbolicLinks());
        logger?.fine('Found Dart SDK bundled LLD at $resolvedUri.');
        instances.add(ToolInstance(tool: lld, uri: resolvedUri));
        break;
      }
    }
    if (instances.isEmpty) {
      logger?.finer(
        'Did not find bundled LLD in Dart SDK relative to $executableUri.',
      );
    }
    return instances;
  }
}

/// Resolves the platform linker stubs directory bundled in the Dart SDK for
/// [targetOS] and [targetArchitecture].
///
/// For [OS.iOS], [iOSTargetSdk] selects between device (`ios/<arch>`) and
/// simulator (`ios/<arch>-sim`) stubs when available.
///
/// Returns `null` if no matching linker stubs directory exists.
Directory? resolveLinkerStubsDir(
  OS targetOS,
  Architecture targetArchitecture, {
  required FileSystem fileSystem,
  IOSSdk? iOSTargetSdk,
}) {
  final executableUri = Uri.file(Platform.resolvedExecutable);
  final candidateBaseUris = <Uri>[
    // Packaged Dart SDK layout: <sdk>/bin/dart -> <sdk>/lib/_internal/linker_stubs/
    executableUri.resolve('../lib/_internal/linker_stubs/'),
    // Build root layout: out/<Config>/dart -> out/<Config>/dart-sdk/lib/_internal/linker_stubs/
    executableUri.resolve('dart-sdk/lib/_internal/linker_stubs/'),
    // Build root layout: out/<Config>/dart -> out/<Config>/linker_stubs/
    executableUri.resolve('linker_stubs/'),
    // Build root gen layout: out/<Config>/dart -> out/<Config>/gen/linker_stubs/
    executableUri.resolve('gen/linker_stubs/'),
    // Stripped exe in build root: out/<Config>/exe.stripped/dart -> out/<Config>/linker_stubs/
    executableUri.resolve('../linker_stubs/'),
    // Checked-in prebuilt SDK in repo: tools/sdks/dart-sdk/bin/dart -> out/ReleaseX64/...
    executableUri.resolve(
      '../../../../out/ReleaseX64/dart-sdk/lib/_internal/linker_stubs/',
    ),
    executableUri.resolve('../../../../out/ReleaseX64/linker_stubs/'),
  ];

  final osDirName = targetOS.name.toLowerCase();
  final archDirNames = <String>[
    if (targetOS == .iOS && iOSTargetSdk == .iPhoneSimulator) ...[
      '${targetArchitecture.name}-sim',
      if (targetArchitecture == .arm64e) 'arm64-sim',
    ],
    targetArchitecture.name,
    if (targetArchitecture == .arm64e) 'arm64',
    if (targetOS == .android && targetArchitecture == .ia32) 'x86',
  ];

  for (final baseUri in candidateBaseUris) {
    for (final archDirName in archDirNames) {
      final candidateDir = fileSystem.directory(
        baseUri.resolve('$osDirName/$archDirName/'),
      );
      if (candidateDir.existsSync()) {
        return candidateDir;
      }
    }
  }
  return null;
}
