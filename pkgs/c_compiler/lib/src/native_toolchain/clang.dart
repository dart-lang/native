// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../tool/tool.dart';
import '../tool/tool_resolver.dart';

final Tool clang = Tool(
  name: 'Clang',
  defaultResolver: CliVersionResolver(
    wrappedResolver: ToolResolvers([
      PathToolResolver(toolName: 'Clang'),
    ]),
  ),
);

final Tool llvmAr = Tool(
  name: 'llvm-ar',
  defaultResolver: CliVersionResolver(
    wrappedResolver: ToolResolvers([
      RelativeToolResolver(
        toolName: 'llvm-ar',
        wrappedResolver: clang.defaultResolver!,
        relativePath: Uri.file('llvm-ar'),
      ),
    ]),
  ),
);

final Tool lld = Tool(
  name: 'ld.lld',
  defaultResolver: CliVersionResolver(
    wrappedResolver: ToolResolvers([
      RelativeToolResolver(
        toolName: 'ld.lld',
        wrappedResolver: clang.defaultResolver!,
        relativePath: Uri.file('ld.lld'),
      ),
    ]),
  ),
);
