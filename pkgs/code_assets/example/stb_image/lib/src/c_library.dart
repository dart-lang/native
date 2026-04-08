// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_toolchain_c/native_toolchain_c.dart';

/// The C build specification for the stb_image library.
///
/// It is used by the build and link hooks in the `hook/` directory.
final cLibrary = CLibrary(
  name: 'stb_image',
  assetName: 'src/third_party/stb_image.g.dart',
  sources: ['third_party/stb_image.c'],
);
