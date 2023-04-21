// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../tool/tool.dart';
import '../tool/tool_resolver.dart';

/// The Visual Studio Locator.
///
/// https://github.com/microsoft/vswhere
final Tool vswhere = Tool(
  name: 'Visual Studio Locator',
  defaultResolver: CliVersionResolver(
    arguments: [],
    wrappedResolver: ToolResolvers(
      [
        PathToolResolver(
          toolName: 'Visual Studio Locator',
          executableName: 'vswhere.exe',
        ),
        InstallLocationResolver(
          toolName: 'Visual Studio Locator',
          paths: [
            'C:/Program Files \\(x86\\)/Microsoft Visual Studio/Installer/vswhere.exe',
            'C:/Program Files/Microsoft Visual Studio/Installer/vswhere.exe',
          ],
        ),
      ],
    ),
  ),
);

/// Visual Studio.
///
/// https://visualstudio.microsoft.com/
final Tool msvc = Tool(
  name: 'Visual Studio',
  defaultResolver: InstallLocationResolver(
    toolName: 'Visual Studio',
    paths: [
      for (final edition in _visualStudioEditions) ...[
        'C:/Program Files \\(x86\\)/Microsoft Visual Studio/*/$edition',
        'C:/Program Files/Microsoft Visual Studio/*/$edition',
      ],
    ],
  ),
);

final _visualStudioEditions = [
  'Professional',
  'Community',
];
