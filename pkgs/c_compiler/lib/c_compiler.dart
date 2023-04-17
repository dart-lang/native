// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library to invoke the native C compiler installed on the host machine.
library;

export 'src/cbuilder/cbuilder.dart';
export 'src/native_toolchain/android_ndk.dart';
export 'src/native_toolchain/apple_clang.dart';
export 'src/native_toolchain/clang.dart';
export 'src/native_toolchain/gcc.dart';
export 'src/tool/tool.dart';
export 'src/tool/tool_instance.dart';
export 'src/tool/tool_requirement.dart';
export 'src/tool/tool_resolver.dart';
