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
    ));
