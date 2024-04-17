// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'cbuilder.dart';

/// A programming language that can be selected for compilation of source files.
///
/// See [CBuilder.language] for more information.
class Language {
  /// The name of the language.
  final String name;
  const Language._(this.name);

  static const Language c = Language._('c');
  static const Language cpp = Language._('c++');

  /// Known values for [Language].
  static const List<Language> values = [c, cpp];

  @override
  String toString() => name;
}
