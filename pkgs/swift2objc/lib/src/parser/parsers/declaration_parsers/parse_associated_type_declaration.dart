// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/declarations/compounds/members/associated_type_declaration.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/utils.dart';

AssociatedTypeDeclaration parseAssociatedTypeDeclaration(Json symbolJson, ParsedSymbolgraph symbolGraph) {
  final id = parseSymbolId(symbolJson);
  final name = parseSymbolName(symbolJson);  

  return AssociatedTypeDeclaration(id: id, name: name);
}
