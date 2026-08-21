// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../code_generator.dart';
import '../config_provider/config.dart' show FfiGenerator;
import '../config_provider/config_types.dart' show VarArgFunction;
import '../config_provider/spec_utils.dart';
import '../strings.dart' as strings;
import 'ast.dart';

final _logger = Logger('ffigen.visitor.expand_varargs');

/// Expands variadic functions into specialized [Func] instances based on their
/// [VarArgFunction] configurations.
class ExpandVarargsVisitation extends Visitation {
  final FfiGenerator config;
  final Set<Binding> bindings;

  ExpandVarargsVisitation(this.config, Set<Binding> initialBindings)
    : bindings = initialBindings.toSet();

  @override
  void visitFunc(Func node) {
    if (node.varArgs.isEmpty) return;
    if (node.isVariadic) {
      bindings.remove(node);
      for (final vaFunc in node.varArgs) {
        final types = [
          for (final t in vaFunc.types)
            makeTypeFromRawVarArgType(t, config.importType),
        ];
        var postfix = vaFunc.postfix;
        if (postfix.isEmpty) {
          if (node.varArgs.length == 1) {
            postfix = '';
          } else {
            postfix = makePostfixFromRawVarArgType(vaFunc.types);
          }
        }
        final usr = '${node.usr}${strings.synthUsrChar} vaFunc: $postfix';
        final name = '${node.symbol.oldName}$postfix';
        final varArgParameters = [
          for (final t in types)
            Parameter(type: t, name: 'va', objCConsumed: false),
        ];
        bindings.add(node.cloneForVarArgs(usr, name, varArgParameters));
      }
    } else {
      _logger.warning(
        'Skipping variadic-argument config for function '
        "'${node.originalName}' since its not variadic.",
      );
    }
  }
}
