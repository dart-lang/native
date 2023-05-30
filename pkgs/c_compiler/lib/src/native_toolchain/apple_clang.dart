// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../tool/tool.dart';
import '../tool/tool_resolver.dart';

/// The Clang variant inside XCode.
///
/// https://developer.apple.com/xcode/
final Tool appleClang = Tool(
  name: 'Apple Clang',
  defaultResolver: CliVersionResolver(
    wrappedResolver: CliFilter(
      cliArguments: ['--version'],
      keepIf: ({required String stdout}) => stdout.contains('Apple clang'),
      wrappedResolver: PathToolResolver(
        toolName: 'Apple Clang',
        executableName: 'clang',
      ),
    ),
  ),
);

/// The archiver belonging to [appleClang].
final Tool appleAr = Tool(
  name: 'Apple archiver',
  defaultResolver: ToolResolvers([
    RelativeToolResolver(
      toolName: 'Apple archiver',
      wrappedResolver: appleClang.defaultResolver!,
      relativePath: Uri.file('ar'),
    ),
  ]),
);

/// The linker belonging to [appleClang].
final Tool appleLd = Tool(
  name: 'Apple linker',
  defaultResolver: ToolResolvers([
    RelativeToolResolver(
      toolName: 'Apple linker',
      wrappedResolver: appleClang.defaultResolver!,
      relativePath: Uri.file('ld'),
    ),
  ]),
);

/// The Mach-O dumping tool.
///
/// https://llvm.org/docs/CommandGuide/llvm-otool.html
final Tool otool = Tool(
  name: 'otool',
  defaultResolver: CliVersionResolver(
    wrappedResolver: PathToolResolver(
      toolName: 'otool',
      executableName: 'otool',
    ),
  ),
);
