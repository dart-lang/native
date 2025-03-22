// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/declarations/compounds/protocol_declaration.dart';
import '../../parser/_core/utils.dart';
import '../_core/unique_namer.dart';
import '../transform.dart';

// TODO(https://github.com/dart-lang/native/pull/2056): Update TransformationMap to make referencing types easy.
//  Would want to just add wrapper suffix but due to unique naming,
//  can't take chances
ProtocolDeclaration transformProtocol(ProtocolDeclaration originalProtocol,
    UniqueNamer parentNamer, TransformationMap transformationMap) {
  final compoundNamer = UniqueNamer.inCompound(originalProtocol);

  if (originalProtocol.associatedTypes.isNotEmpty) {
    throw Exception('Associated types are not exportable to Objective-C');
  }

  final transformedProtocol = ProtocolDeclaration(
      id: originalProtocol.id.addIdSuffix('wrapper'),
      name: parentNamer.makeUnique('${originalProtocol.name}Wrapper'),
      properties: originalProtocol.properties,
      methods: originalProtocol.methods,
      initializers: originalProtocol.initializers,
      conformedProtocols: [],
      hasObjCAnnotation: true,
      nestingParent: originalProtocol.nestingParent);

  transformedProtocol.conformedProtocols.addAll(
    originalProtocol.conformedProtocols.map((p) {
     return (
      transformDeclaration(p.declaration, compoundNamer, transformationMap) 
        as ProtocolDeclaration
      )
        .asDeclaredType;
    })
  );

  transformationMap[originalProtocol] = transformedProtocol;

  return transformedProtocol;
}
