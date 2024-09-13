// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../tool/tool.dart';
import 'apple_clang.dart';
import 'clang.dart';
import 'gcc.dart';

extension ToolLikeness on Tool {
  bool get isClangLike => this == appleClang || this == clang || this == gcc;

  bool get isLdLike => this == appleLd || this == gnuLinker || this == lld;
}
