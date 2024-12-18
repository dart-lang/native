// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../_core/interfaces/can_async.dart';
import '../../../_core/interfaces/can_throw.dart';
import '../../../_core/interfaces/declaration.dart';
import '../../../_core/interfaces/executable.dart';
import '../../../_core/interfaces/objc_annotatable.dart';
import '../../../_core/interfaces/overridable.dart';
import '../../../_core/interfaces/parameterizable.dart';
import '../../../_core/shared/parameter.dart';

/// Describes an initializer for a Swift compound entity (e.g, class, structs)
class InitializerDeclaration
    implements
        Declaration,
        Executable,
        Parameterizable,
        ObjCAnnotatable,
        Overridable,
        CanThrow,
        CanAsync {
  @override
  String id;

  @override
  String get name => 'init';

  @override
  bool hasObjCAnnotation;

  @override
  bool isOverriding;

  @override
  bool throws;

  @override
  bool async;

  bool isFailable;

  @override
  List<Parameter> params;

  @override
  List<String> statements;

  String get fullName => [
        name,
        for (final p in params) p.name,
      ].join(':');

  InitializerDeclaration({
    required this.id,
    required this.params,
    this.statements = const [],
    required this.hasObjCAnnotation,
    required this.isOverriding,
    required this.throws,
    required this.async,
    required this.isFailable,
  });
}
