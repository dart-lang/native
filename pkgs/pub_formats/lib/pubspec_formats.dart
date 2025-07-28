// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An internal library containing file formats for the pub client. This library
/// is not meant to have a stable API and might break at any point when
/// `package:json_syntax_generator` is updated. This API is used in the Dart
/// SDK, so when doing breaking changes please roll ASAP to the Dart SDK.
library;

export 'src/package_config_syntax.g.dart' hide JsonObjectSyntax;
export 'src/package_graph_syntax.g.dart' hide JsonObjectSyntax;
export 'src/pubspec_lock_syntax.g.dart' hide JsonObjectSyntax;
export 'src/pubspec_syntax.g.dart' hide JsonObjectSyntax;
