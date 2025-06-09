// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Wraps the [input] in curly braces if it's not empty.
String wrapBracesIfNotEmpty(String input) => input.isEmpty ? input : '{$input}';

/// Wraps the [input] in curly braces or adds a semicolon if it's empty.
String wrapInBracesOrSemicolon(String input) =>
    input.isEmpty ? ';' : '{ $input }';
