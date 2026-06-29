// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';

import '../tool/tool.dart';
import '../tool/tool_resolver.dart';
import 'wsl.dart';

/// The GNU Compiler Collection for [Architecture.current].
///
/// https://gcc.gnu.org/
final gcc = Tool(
  name: 'GCC',
  defaultResolver: CliVersionResolver(
    wrappedResolver: PathToolResolver(toolName: 'GCC', executableName: 'gcc'),
  ),
);

/// The GNU GCC archiver for [Architecture.current].
final gnuArchiver = Tool(name: 'GNU archiver');

/// The GNU linker for [Architecture.current].
///
/// https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/ld.html
final gnuLinker = Tool(name: 'GNU linker');

/// [gcc] accessed through WSL when cross-compiling from Windows to Linux.
///
/// A separate [Tool] from [gcc] so it doesn't mix with a host gcc: it is only
/// ever resolved (inside WSL via [WslToolResolver]), never recognized from a
/// host path.
final gccWsl = Tool(name: 'GCC (WSL)');

/// [gnuArchiver] accessed through WSL when cross-compiling from Windows to
/// Linux. See [gccWsl].
final gnuArchiverWsl = Tool(name: 'GNU archiver (WSL)');

/// [gcc] with [Tool.defaultResolver] for [Architecture.ia32].
final i686LinuxGnuGcc = _gcc('i686-linux-gnu');

/// [gnuArchiver] with [Tool.defaultResolver] for [Architecture.ia32].
final i686LinuxGnuGccAr = _gnuArchiver('i686-linux-gnu');

/// [gnuLinker] with [Tool.defaultResolver] for [Architecture.ia32].
final i686LinuxGnuLd = _gnuLinker('i686-linux-gnu');

/// [gcc] with [Tool.defaultResolver] for [Architecture.x64].
final x86_64LinuxGnuGcc = _gcc('x86_64-linux-gnu');

/// [gnuArchiver] with [Tool.defaultResolver] for [Architecture.x64].
final x86_64LinuxGnuGccAr = _gnuArchiver('x86_64-linux-gnu');

/// [gnuLinker] with [Tool.defaultResolver] for [Architecture.x64].
final x86_64LinuxGnuLd = _gnuLinker('x86_64-linux-gnu');

/// [gcc] with [Tool.defaultResolver] for [Architecture.arm].
final armLinuxGnueabihfGcc = _gcc('arm-linux-gnueabihf');

/// [gnuArchiver] with [Tool.defaultResolver] for [Architecture.arm].
final armLinuxGnueabihfGccAr = _gnuArchiver('arm-linux-gnueabihf');

/// [gnuLinker] with [Tool.defaultResolver] for [Architecture.arm].
final armLinuxGnueabihfLd = _gnuLinker('arm-linux-gnueabihf');

/// [gcc] with [Tool.defaultResolver] for [Architecture.arm64].
final aarch64LinuxGnuGcc = _gcc('aarch64-linux-gnu');

/// [gnuArchiver] with [Tool.defaultResolver] for [Architecture.arm64].
final aarch64LinuxGnuGccAr = _gnuArchiver('aarch64-linux-gnu');

/// [gnuLinker] with [Tool.defaultResolver] for [Architecture.arm64].
final aarch64LinuxGnuLd = _gnuLinker('aarch64-linux-gnu');

/// [gcc] with [Tool.defaultResolver] for [Architecture.riscv64].
final riscv64LinuxGnuGcc = _gcc('riscv64-linux-gnu');

/// [gnuArchiver] with [Tool.defaultResolver] for [Architecture.riscv64].
final riscv64LinuxGnuGccAr = _gnuArchiver('riscv64-linux-gnu');

/// [gnuLinker] with [Tool.defaultResolver] for [Architecture.riscv64].
final riscv64LinuxGnuLd = _gnuLinker('riscv64-linux-gnu');

/// [gccWsl] with [Tool.defaultResolver] for [Architecture.ia32].
final i686LinuxGnuGccWsl = _gccWsl('i686-linux-gnu');

/// [gnuArchiverWsl] with [Tool.defaultResolver] for [Architecture.ia32].
final i686LinuxGnuGccArWsl = _gnuArchiverWsl('i686-linux-gnu');

/// [gccWsl] with [Tool.defaultResolver] for [Architecture.x64].
final x86_64LinuxGnuGccWsl = _gccWsl('x86_64-linux-gnu');

/// [gnuArchiverWsl] with [Tool.defaultResolver] for [Architecture.x64].
final x86_64LinuxGnuGccArWsl = _gnuArchiverWsl('x86_64-linux-gnu');

/// [gccWsl] with [Tool.defaultResolver] for [Architecture.arm].
final armLinuxGnueabihfGccWsl = _gccWsl('arm-linux-gnueabihf');

/// [gnuArchiverWsl] with [Tool.defaultResolver] for [Architecture.arm].
final armLinuxGnueabihfGccArWsl = _gnuArchiverWsl('arm-linux-gnueabihf');

/// [gccWsl] with [Tool.defaultResolver] for [Architecture.arm64].
final aarch64LinuxGnuGccWsl = _gccWsl('aarch64-linux-gnu');

/// [gnuArchiverWsl] with [Tool.defaultResolver] for [Architecture.arm64].
final aarch64LinuxGnuGccArWsl = _gnuArchiverWsl('aarch64-linux-gnu');

/// [gccWsl] with [Tool.defaultResolver] for [Architecture.riscv64].
final riscv64LinuxGnuGccWsl = _gccWsl('riscv64-linux-gnu');

/// [gnuArchiverWsl] with [Tool.defaultResolver] for [Architecture.riscv64].
final riscv64LinuxGnuGccArWsl = _gnuArchiverWsl('riscv64-linux-gnu');

Tool _gcc(String prefix) => Tool(
  name: gcc.name,
  defaultResolver: CliVersionResolver(
    wrappedResolver: ToolResolvers([
      PathToolResolver(toolName: gcc.name, executableName: '$prefix-gcc'),
      InstallLocationResolver(
        toolName: gcc.name,
        paths: [
          '/opt/homebrew/bin/$prefix-gcc',
          '/usr/local/bin/$prefix-gcc',
        ],
      ),
    ]),
  ),
);

/// [gccWsl] resolved inside WSL via `wsl which <prefix>-gcc`.
Tool _gccWsl(String prefix) => Tool(
  name: gccWsl.name,
  defaultResolver: CliVersionResolver(
    wrappedResolver: WslToolResolver(
      toolName: gccWsl.name,
      executableName: '$prefix-gcc',
    ),
  ),
);

Tool _gnuArchiver(String prefix) {
  final gcc = _gcc(prefix);
  return Tool(
    name: gnuArchiver.name,
    defaultResolver: RelativeToolResolver(
      toolName: gnuArchiver.name,
      wrappedResolver: gcc.defaultResolver!,
      relativePath: Uri.file('$prefix-gcc-ar'),
    ),
  );
}

/// [gnuArchiverWsl] resolved inside WSL via `wsl which <prefix>-gcc-ar`.
Tool _gnuArchiverWsl(String prefix) => Tool(
  name: gnuArchiverWsl.name,
  defaultResolver: WslToolResolver(
    toolName: gnuArchiverWsl.name,
    executableName: '$prefix-gcc-ar',
  ),
);

Tool _gnuLinker(String prefix) {
  final gcc = _gcc(prefix);
  return Tool(
    name: gnuLinker.name,
    defaultResolver: RelativeToolResolver(
      toolName: gnuLinker.name,
      wrappedResolver: gcc.defaultResolver!,
      relativePath: Uri.file('$prefix-ld'),
    ),
  );
}
