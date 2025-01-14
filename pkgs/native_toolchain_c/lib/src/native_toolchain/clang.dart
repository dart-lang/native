// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets.dart';

import '../tool/tool.dart';
import '../tool/tool_resolver.dart';

/// The Clang compiler.
///
/// https://clang.llvm.org/
final Tool clang = Tool(
  name: 'Clang',
  defaultResolver: CliVersionResolver(
    wrappedResolver: CliFilter(
      cliArguments: ['--version'],
      keepIf: ({required String stdout}) => !stdout.contains('Apple clang'),
      wrappedResolver: ToolResolvers([
        PathToolResolver(
          toolName: 'Clang',
          executableName: OS.current.executableFileName('clang'),
        ),
        InstallLocationResolver(
          toolName: 'Clang',
          paths: [
            'C:/Program Files/LLVM/bin/clang.exe',
          ],
        ),
      ]),
    ),
  ),
);

/// The LLVM archiver.
///
/// https://llvm.org/docs/CommandGuide/llvm-ar.html
final Tool llvmAr = Tool(
  name: 'LLVM archiver',
  defaultResolver: CliVersionResolver(
    wrappedResolver: ToolResolvers([
      RelativeToolResolver(
        toolName: 'LLVM archiver',
        wrappedResolver: clang.defaultResolver!,
        relativePath: Uri.file(OS.current.executableFileName('llvm-ar')),
      ),
    ]),
  ),
);

/// The LLVM Linker.
///
/// https://lld.llvm.org/
final Tool lld = Tool(
  name: 'LLD',
  defaultResolver: CliVersionResolver(
    wrappedResolver: ToolResolvers([
      RelativeToolResolver(
        toolName: 'LLD',
        wrappedResolver: clang.defaultResolver!,
        relativePath: Uri.file(OS.current.executableFileName('ld.lld')),
      ),
    ]),
  ),
);
