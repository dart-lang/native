// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/declarations/built_in/built_in_declaration.dart';
import '../../_core/json.dart';
import '../../_core/utils.dart';

BuiltInDeclaration? tryParseBuiltInDeclaration(Json symbolJson) {
  final id = parseSymbolId(symbolJson);
  if (!id.startsWith('c:objc(cs)')) return null;
  return BuiltInDeclaration(id: id, name: parseSymbolName(symbolJson));
}
