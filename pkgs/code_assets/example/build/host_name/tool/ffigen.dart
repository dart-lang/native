// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  const ffiNativeConfig = FfiNativeConfig(
    enabled: true,
    assetId: 'package:host_name/src/host_name.dart',
  );
  final functionDeclarationFilter = DeclarationFilters(
    shouldInclude: (declaration) => declaration.originalName == 'gethostname',
  );
  if (Platform.isWindows) {
    FfiGen().run(
      Config(
        output: packageRoot.resolve('lib/src/third_party/windows.dart'),
        entryPoints: [packageRoot.resolve('src/windows.h')],
        preamble: '''
// This file includes parts which are Copyright (c) 1982-1986 Regents
// of the University of California.  All rights reserved.  The
// Berkeley Software License Agreement specifies the terms and
// conditions for redistribution.
''',
        functionDecl: functionDeclarationFilter,
        ffiNativeConfig: ffiNativeConfig,
      ),
    );
  } else {
    FfiGen().run(
      Config(
        output: packageRoot.resolve('lib/src/third_party/unix.dart'),
        entryPoints: [packageRoot.resolve('src/unix.h')],
        preamble: '''
// Copyright (C) 1991-2022 Free Software Foundation, Inc.
// This file is part of the GNU C Library.
//
// The GNU C Library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// The GNU C Library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with the GNU C Library; if not, see
// <https://www.gnu.org/licenses/>.
''',
        functionDecl: functionDeclarationFilter,
        ffiNativeConfig: ffiNativeConfig,
      ),
    );
  }
}
