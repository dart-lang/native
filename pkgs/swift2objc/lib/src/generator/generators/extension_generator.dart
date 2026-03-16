// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/declarations/compounds/extension_declaration.dart';
import '../_core/utils.dart';
import 'class_generator.dart';

List<String> generateExtension(ExtensionDeclaration declaration) {
  return [
    ...generateAvailability(declaration),
    '@objc extension ${declaration.extendedType.declaration.name} {',
    ...[
      for (final method in declaration.methods) ...generateClassMethod(method),
      for (final property in declaration.properties)
        ...generateClassProperty(property),
      for (final init in declaration.initializers)
        ...generateInitializer(init, isPublic: true, isConvenience: true),
    ].indent(),
    '}\n',
  ];
}
