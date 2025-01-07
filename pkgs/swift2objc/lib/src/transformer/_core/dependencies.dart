import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/interfaces/enum_declaration.dart';
import '../../ast/_core/interfaces/function_declaration.dart';
import '../../ast/_core/interfaces/variable_declaration.dart';
import '../../ast/_core/shared/parameter.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/compounds/class_declaration.dart';
import '../../ast/declarations/compounds/members/initializer_declaration.dart';
import '../../ast/declarations/compounds/protocol_declaration.dart';
import '../../ast/declarations/compounds/struct_declaration.dart';

// TODO(https://github.com/dart-lang/native/issues/1814): Type restrictions have not yet been implemented in system
class DependencyVisitor {
  final Iterable<Declaration> declarations;
  Set<Declaration> visitedDeclarations = {};

  DependencyVisitor(this.declarations);

  Set<Declaration> visit(Declaration dec) {
    final dependencies = <Declaration>{};

    Iterable<Declaration> d = [dec];

    while (true) {
      final deps = d.fold<Set<String>>(
          {}, (previous, element) => previous.union(visitDeclaration(element)));
      final depDecls = declarations.where((d) => deps.contains(d.id));
      if (depDecls.isEmpty ||
          (dependencies.union(depDecls.toSet()).length) ==
              dependencies.length) {
        break;
      } else {
        dependencies.addAll(depDecls);
        d = depDecls;
      }
    }

    visitedDeclarations.addAll(dependencies);

    return dependencies;
  }

  Set<String> visitDeclaration(Declaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // switch between declarations
    if (decl is ClassDeclaration) {
      visitClass(decl, cont);
    } else if (decl is ProtocolDeclaration) {
      visitProtocol(decl, cont);
    } else if (decl is StructDeclaration) {
      visitStruct(decl, cont);
    } else if (decl is FunctionDeclaration) {
      visitFunction(decl, cont);
    } else if (decl is VariableDeclaration) {
      visitVariable(decl, cont);
    } else if (decl is EnumDeclaration) {
      visitEnum(decl, cont);
    }

    return cont;
  }

  Set<String> visitEnum(EnumDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit nested declarations
    for (var n in decl.nestedDeclarations) {
      visitDeclaration(n, cont);
    }

    // visit protocols
    for (var p in decl.conformedProtocols) {
      visitProtocol(p.declaration, cont);
    }

    // ensure generic types do not enter
    cont.removeWhere(
        (t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitStruct(StructDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit variables
    for (var d in decl.properties) {
      visitVariable(d, cont);
    }

    // visit methods
    for (var m in decl.methods) {
      visitFunction(m, cont);
    }

    // visit initializers
    for (var i in decl.initializers) {
      visitInitializer(i, cont);
    }

    // visit nested declarations
    for (var n in decl.nestedDeclarations) {
      visitDeclaration(n, cont);
    }

    // visit protocols
    for (var p in decl.conformedProtocols) {
      visitProtocol(p.declaration, cont);
    }

    // ensure generic types do not enter
    cont.removeWhere(
        (t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitClass(ClassDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit variables
    for (var d in decl.properties) {
      visitVariable(d, cont);
    }

    // visit methods
    for (var m in decl.methods) {
      visitFunction(m, cont);
    }

    // visit initializers
    for (var i in decl.initializers) {
      visitInitializer(i, cont);
    }

    // visit super if any
    if (decl.superClass != null) {
      visitDeclaration(decl.superClass!.declaration, cont);
    }

    // visit nested declarations
    for (var n in decl.nestedDeclarations) {
      visitDeclaration(n, cont);
    }

    // visit protocols
    for (var p in decl.conformedProtocols) {
      visitProtocol(p.declaration, cont);
    }

    // ensure generic types do not enter
    cont.removeWhere(
        (t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitProtocol(ProtocolDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit variables
    for (var d in decl.properties) {
      visitVariable(d, cont);
    }

    // visit methods
    for (var m in decl.methods) {
      visitFunction(m, cont);
    }

    // visit initializers
    for (var i in decl.initializers) {
      visitInitializer(i, cont);
    }

    // visit nested declarations
    for (var n in decl.nestedDeclarations) {
      visitDeclaration(n, cont);
    }

    // visit protocols
    for (var p in decl.conformedProtocols) {
      visitProtocol(p.declaration, cont);
    }

    // ensure generic types do not enter
    cont.removeWhere(
        (t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitInitializer(InitializerDeclaration decl,
      [Set<String>? context]) {
    final cont = context ??= {};

    // similar to `visitMethod`, except no return type
    for (var p in decl.params) {
      visitParameter(p, cont);
    }

    return cont;
  }

  Set<String> visitFunction(FunctionDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit parameters
    for (var p in decl.params) {
      visitParameter(p, cont);
    }

    // ensure generic types do not enter
    cont.removeWhere(
        (t) => decl.typeParams.map((type) => type.name).contains(t));

    // visit return type
    visitType(decl.returnType, cont);

    return cont;
  }

  Set<String> visitParameter(Parameter decl, [Set<String>? context]) {
    final cont = context ??= {};

    // just visit type of parameter
    visitType(decl.type, cont);

    return cont;
  }

  Set<String> visitVariable(VariableDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // just return property type
    visitType(decl.type, cont);

    return cont;
  }

  Set<String> visitType(ReferredType type, [Set<String>? context]) {
    final cont = context ??= {};

    // we need to confirm the types located
    // check what kind of type [type] is
    switch (type) {
      case DeclaredType():
        cont.add(type.id);
        break;
      case GenericType():
        // do nothing
        break;
      case OptionalType():
        visitType(type.child, cont);
    }
    return cont;
  }
}
