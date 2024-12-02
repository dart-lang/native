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

/// Gets the type name from a string type by removing other characters like 
Set<String> _getTypeNames(String type) {
  // Remove optional markers (?) and square brackets ([])
  type = type.replaceAll(RegExp(r'\?|!|[\[\]]'), '');

  // Remove annotations (words starting with @)
  type = type.replaceAll(RegExp(r'@\w+'), '');

  // Extract unique type names using regex
  final matches = RegExp(r'\b\w+\b').allMatches(type);

  // Return unique type names as a set
  return matches.map((match) => match.group(0)!).toSet();
}

// TODO: Type restrictions have not yet been implemented in system
class DependencyVisitor {
  Set<String> visitDeclaration(Declaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // switch between declarations
    if (decl is ClassDeclaration)
      visitClass(decl, cont);
    else if (decl is ProtocolDeclaration)
      visitProtocol(decl, cont);
    else if (decl is StructDeclaration)
      visitStruct(decl, cont);
    else if (decl is FunctionDeclaration)
      visitFunction(decl, cont);
    else if (decl is VariableDeclaration)
      visitVariable(decl, cont);
    else if (decl is EnumDeclaration) visitEnum(decl, cont);

    return cont;
  }

  Set<String> visitEnum(EnumDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // TODO: what of raw values of enums?

    // visit nested declarations
    decl.nestedDeclarations.forEach((n) => visitDeclaration(n, cont));

    // visit protocols
    decl.conformedProtocols.forEach((p) => visitProtocol(p.declaration, cont));

    // ensure generic types do not enter
    cont.removeWhere((t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitStruct(StructDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit variables
    decl.properties.forEach((d) => visitVariable(d, cont));

    // visit methods
    decl.methods.forEach((m) => visitFunction(m, cont));

    // visit initializers
    decl.initializers.forEach((i) => visitInitializer(i, cont));

    // visit nested declarations
    decl.nestedDeclarations.forEach((n) => visitDeclaration(n, cont));

    // visit protocols
    decl.conformedProtocols.forEach((p) => visitProtocol(p.declaration, cont));

    // ensure generic types do not enter
    cont.removeWhere((t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitClass(ClassDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit variables
    decl.properties.forEach((d) => visitVariable(d, cont));

    // visit methods
    decl.methods.forEach((m) => visitFunction(m, cont));

    // visit initializers
    decl.initializers.forEach((i) => visitInitializer(i, cont));

    // visit super if any
    if (decl.superClass != null)
      visitDeclaration(decl.superClass!.declaration, cont);

    // visit nested declarations
    decl.nestedDeclarations.forEach((n) => visitDeclaration(n, cont));

    // visit protocols
    decl.conformedProtocols.forEach((p) => visitProtocol(p.declaration, cont));

    // ensure generic types do not enter
    cont.removeWhere((t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitProtocol(ProtocolDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit variables
    decl.properties.forEach((d) => visitVariable(d, cont));

    // visit methods
    decl.methods.forEach((m) => visitFunction(m, cont));

    // visit initializers
    decl.initializers.forEach((i) => visitInitializer(i, cont));

    // visit nested declarations
    decl.nestedDeclarations.forEach((n) => visitDeclaration(n, cont));

    // visit protocols
    decl.conformedProtocols.forEach((p) => visitProtocol(p.declaration, cont));

    // ensure generic types do not enter
    cont.removeWhere((t) => decl.typeParams.map((type) => type.name).contains(t));

    return cont;
  }

  Set<String> visitInitializer(InitializerDeclaration decl,
      [Set<String>? context]) {
    final cont = context ??= {};

    // similar to `visitMethod`, except no return type
    decl.params.forEach((p) => visitParameter(p, cont));

    return cont;
  }

  Set<String> visitFunction(FunctionDeclaration decl, [Set<String>? context]) {
    final cont = context ??= {};

    // visit parameters
    decl.params.forEach((p) => visitParameter(p, cont));

    // ensure generic types do not enter
    cont.removeWhere((t) => decl.typeParams.map((type) => type.name).contains(t));

    // visit return type
    visitType(decl.returnType, cont);

    // TODO: what of type restrictions (`... where T.Element: CustomStringConvertible`)

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
    // at the moment, we can perform simple regex to clean up text characters

    // since we are making such visitations on normal declarations in a file,
    // we do not need to filter out primitives at the moment
    cont.addAll(_getTypeNames(type.swiftType));

    return cont;
  }
}
