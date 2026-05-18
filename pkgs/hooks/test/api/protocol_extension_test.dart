// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

/// A concrete subclass of [ProtocolExtension] that intentionally implements
/// nothing.
///
/// **CRITICAL**: Do NOT add any method or member implementations/overrides to
/// this class.
///
/// [ProtocolExtension] is an abstract base class (not an interface) to prevent
/// breaking changes across the ecosystem when new methods are added. All new
/// methods added to [ProtocolExtension] MUST have a default implementation.
///
/// If this class fails to compile with a "missing concrete implementation"
/// error, it means an abstract member was added to [ProtocolExtension]. To fix
/// it, add a default implementation to the member in [ProtocolExtension]
/// instead of implementing it here.
final class ConcreteProtocolExtension extends ProtocolExtension {}

void main() {
  test(
    'ProtocolExtension can be fully subclassed without overriding methods',
    () {
      final extension = ConcreteProtocolExtension();

      // Verify default implementations return expected empty collections.
      expect(extension.validateApplicationAssets([]), completion(isEmpty));
      expect(extension.outputFiles([]), isEmpty);
    },
  );
}
