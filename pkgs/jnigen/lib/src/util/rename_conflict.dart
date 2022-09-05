// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

String renameConflict(Map<String, int> counts, String name) {
  if (counts.containsKey(name)) {
    final count = counts[name]!;
    final renamed = '$name$count';
    counts[name] = count + 1;
    return renamed;
  }
  counts[name] = 1;
  return kwRename(name);
}

/// Appends 0 to [name] if [name] is a keyword.
///
/// Examples:
/// * `int` -> `int0`
/// * `i` -> `i`
String kwRename(String name) => _keywords.contains(name) ? '${name}0' : name;

const Set<String> _keywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'with',
  'yield',
};
