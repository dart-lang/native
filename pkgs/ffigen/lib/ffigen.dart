// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is the Dart API for ffigen. The main entrypoint is the FfiGen class.
///
/// For most use cases the YAML based API is simpler. See
/// https://pub.dev/packages/ffigen for details.
library ffigen;

export 'src/config_provider.dart' show Config, YamlConfig;
export 'src/ffigen.dart' show FfiGen;
export 'src/code_generator/ast.dart';
