import '../elements/elements.dart';
import '../logging/logging.dart';
import 'visitor.dart';

/// Adds the type and method descriptor to all methods in all of the classes.
///
/// ASM already fills the descriptor field for methods but doclet does not.
class Descriptor extends Visitor<Classes, void> {
  const Descriptor();

  @override
  void visit(Classes node) {
    for (final classDecl in node.decls.values) {
      classDecl.accept(const _ClassDescriptor());
    }
  }
}

class _ClassDescriptor extends Visitor<ClassDecl, void> {
  const _ClassDescriptor();

  @override
  void visit(ClassDecl node) {
    final methodDescriptor = MethodDescriptor(node.allTypeParams);
    for (final method in node.methods) {
      method.descriptor ??= method.accept(methodDescriptor);
    }
    final typeDescriptor = TypeDescriptor(node.allTypeParams);
    for (final field in node.fields) {
      field.type.descriptor = field.type.accept(typeDescriptor);
    }
    for (final interface in node.interfaces) {
      interface.descriptor = interface.accept(typeDescriptor);
    }
  }
}

/// Generates JNI Method descriptor.
///
/// https://docs.oracle.com/en/java/javase/18/docs/specs/jni/types.html#type-signatures
/// Also see: [TypeDescriptor]
class MethodDescriptor extends Visitor<Method, String> {
  final List<TypeParam> typeParams;

  MethodDescriptor(this.typeParams);

  @override
  String visit(Method node) {
    final s = StringBuffer();
    final typeParamsIncludingThis = [...typeParams, ...node.typeParams];
    final typeDescriptor = TypeDescriptor(typeParamsIncludingThis);
    s.write('(');
    for (final param in node.params) {
      final desc = param.type.accept(typeDescriptor);
      param.type.descriptor = desc;
      s.write(desc);
    }
    s.write(')');
    final returnTypeDesc =
        node.returnType.accept(TypeDescriptor(typeParamsIncludingThis));
    node.returnType.descriptor = returnTypeDesc;
    s.write(returnTypeDesc);
    return s.toString();
  }
}

/// JVM representation of type signatures.
///
/// https://docs.oracle.com/en/java/javase/18/docs/specs/jni/types.html#type-signatures
class TypeDescriptor extends TypeVisitor<String> {
  final List<TypeParam> typeParams;

  TypeDescriptor(this.typeParams);

  @override
  String visitArrayType(ArrayType node) {
    final inner = node.type.accept(this);
    return '[$inner';
  }

  @override
  String visitDeclaredType(DeclaredType node) {
    final internalName = node.binaryName.replaceAll('.', '/');
    return 'L$internalName;';
  }

  @override
  String visitPrimitiveType(PrimitiveType node) {
    return node.signature;
  }

  @override
  String visitTypeVar(TypeVar node) {
    final typeParam = typeParams.lastWhere(
      (typeParam) => typeParam.name == node.name,
      orElse: () {
        log.fatal('${node.name} was not found!');
      },
    );
    return typeParam.bounds.isEmpty
        ? super.visitTypeVar(node)
        : typeParam.bounds.first.accept(this);
  }

  @override
  String visitWildcard(Wildcard node) {
    final extendsBound = node.extendsBound?.accept(this);
    return extendsBound ?? super.visitWildcard(node);
  }

  @override
  String visitNonPrimitiveType(ReferredType node) {
    return 'Ljava/lang/Object;';
  }
}
