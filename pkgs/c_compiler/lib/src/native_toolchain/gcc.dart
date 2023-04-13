// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../tool/tool.dart';
import '../tool/tool_resolver.dart';

final i686LinuxGnuGcc = Tool(
  name: 'i686-linux-gnu-gcc',
  defaultResolver: CliVersionResolver(
    wrappedResolver: PathToolResolver(toolName: 'i686-linux-gnu-gcc'),
  ),
);

final i686LinuxGnuGccAr = _gccArchiver(i686LinuxGnuGcc);

final i686LinuxGnuGccLd = _gccLinker(i686LinuxGnuGcc);

final armLinuxGnueabihfGcc = Tool(
  name: 'arm-linux-gnueabihf-gcc',
  defaultResolver: CliVersionResolver(
    wrappedResolver: PathToolResolver(toolName: 'arm-linux-gnueabihf-gcc'),
  ),
);

final armLinuxGnueabihfGccAr = _gccArchiver(armLinuxGnueabihfGcc);

final armLinuxGnueabihfGccLd = _gccLinker(armLinuxGnueabihfGcc);

final aarch64LinuxGnuGcc = Tool(
  name: 'aarch64-linux-gnu-gcc',
  defaultResolver: CliVersionResolver(
    wrappedResolver: PathToolResolver(toolName: 'aarch64-linux-gnu-gcc'),
  ),
);

final aarch64LinuxGnuGccAr = _gccArchiver(aarch64LinuxGnuGcc);

final aarch64LinuxGnuGccLd = _gccLinker(aarch64LinuxGnuGcc);

/// Finds the `ar` belonging to that GCC.
Tool _gccArchiver(Tool gcc) {
  final arName = gcc.name.replaceAll('-gcc', '-gcc-ar');
  return Tool(
    name: arName,
    defaultResolver: RelativeToolResolver(
      toolName: arName,
      wrappedResolver: gcc.defaultResolver!,
      relativePath: Uri.file(arName),
    ),
  );
}

/// Finds the `ld` belonging to that GCC.
Tool _gccLinker(Tool gcc) {
  final arName = gcc.name.replaceAll('-gcc', '-gcc-ld');
  return Tool(
    name: arName,
    defaultResolver: RelativeToolResolver(
      toolName: arName,
      wrappedResolver: gcc.defaultResolver!,
      relativePath: Uri.file(arName),
    ),
  );
}
