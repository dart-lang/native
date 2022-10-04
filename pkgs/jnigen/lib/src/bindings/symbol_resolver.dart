// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Resolves types referred to in method signatures etc.. and provides
/// appropriate imports for them.
abstract class SymbolResolver {
  /// Resolve the binary name to a String which can be used in dart code.
  String? resolve(String binaryName);

  /// Get all imports for types so far resolved through this resolver.
  List<String> getImportStrings();
}
