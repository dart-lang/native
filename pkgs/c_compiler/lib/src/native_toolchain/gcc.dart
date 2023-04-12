// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../tool/tool.dart';
import '../tool/tool_resolver.dart';

final i686LinuxGnuGcc = Tool(
  name: 'i686-linux-gnu-gcc',
  defaultResolver: PathToolResolver(toolName: 'i686-linux-gnu-gcc'),
);

final armLinuxGnueabihfGcc = Tool(
  name: 'arm-linux-gnueabihf-gcc',
  defaultResolver: PathToolResolver(toolName: 'arm-linux-gnueabihf-gcc'),
);

final aarch64LinuxGnuGcc = Tool(
  name: 'aarch64-linux-gnu-gcc',
  defaultResolver: PathToolResolver(toolName: 'aarch64-linux-gnu-gcc'),
);
