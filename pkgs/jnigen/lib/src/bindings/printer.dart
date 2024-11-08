import '../elements/elements.dart';
import 'visitor.dart';

class Printer extends Visitor<Classes, void> {
  const Printer();
  @override
  void visit(Classes node) {
    for (final MapEntry(:key, :value) in node.decls.entries) {
      print('<$key>');
      const _ClassPrinter().visit(value);
      print('</$key>');
    }
  }
}

class _ClassPrinter extends Visitor<ClassDecl, void> {
  const _ClassPrinter();
  @override
  void visit(ClassDecl node) {
    print('  <methods>');
    for (final method in node.methods) {
      method.accept(const _MethodPrinter());
    }
    print('  </methods>');

    print('  <fields>');
    for (final field in node.fields) {
      field.accept(const _FieldPrinter());
    }
    print('  </fields>');
  }
}

class _MethodPrinter extends Visitor<Method, void> {
  const _MethodPrinter();
  @override
  void visit(Method node) {
    print('    <${node.finalName}>');
    print('      <return>');
    node.returnType.accept(_TypePrinter(8));
    print('      </return>');
    print('      <params>');
    for (final param in node.params) {
      param.accept(const _ParamPrinter());
    }
    print('      </params>');
    print('    </${node.finalName}>');
  }
}

class _FieldPrinter extends Visitor<Field, void> {
  const _FieldPrinter();
  @override
  void visit(Field node) {
    print('    <${node.finalName}>');
    node.type.accept(_TypePrinter(6));
    print('    </${node.finalName}>');
  }
}

class _ParamPrinter extends Visitor<Param, void> {
  const _ParamPrinter();

  @override
  void visit(Param node) {
    print('        <${node.finalName}>');
    node.type.type.accept(_TypePrinter(10));
    print('        </${node.finalName}>');
  }
}

class _TypePrinter extends TypeVisitor<void> {
  int depth;
  _TypePrinter(this.depth);

  void printAnnotation(ReferredType node) {
    if (node.annotations != null) {
      print('${' ' * depth}<annotations>');
      depth += 2;
      for (final annotation in node.annotations!) {
        annotation.accept(_AnnotationPrinter(depth));
      }
      depth -= 2;
      print('${' ' * depth}</annotations>');
    }
  }

  @override
  void visitArrayType(ArrayType node) {
    print('${' ' * depth}<array>');
    depth += 2;
    node.elementType.accept(this);

    printAnnotation(node);

    depth -= 2;
    print('${' ' * depth}</array>');
  }

  @override
  void visitDeclaredType(DeclaredType node) {
    print('${' ' * depth}<${node.classDecl.binaryName}>');
    depth += 2;
    printAnnotation(node);
    for (final param in node.params) {
      param.accept(this);
    }
    depth -= 2;
    print('${' ' * depth}</${node.classDecl.binaryName}>');
  }

  @override
  void visitTypeVar(TypeVar node) {
    print('${' ' * depth}<${node.name}>');
    printAnnotation(node);
    print('${' ' * depth}</${node.name}>');
  }

  @override
  void visitPrimitiveType(PrimitiveType node) {
    print('${' ' * depth}<${node.name}>');
    printAnnotation(node);
    print('${' ' * depth}</${node.name}>');
  }

  @override
  void visitWildcard(Wildcard node) {
    print('${' ' * depth}<*>');
    printAnnotation(node);
    print('${' ' * depth}</*>');
  }

  @override
  void visitNonPrimitiveType(ReferredType node) {}
}

class _AnnotationPrinter extends Visitor<Annotation, void> {
  int depth;

  _AnnotationPrinter(this.depth);

  @override
  void visit(Annotation node) {
    print('${' ' * depth}</${node.binaryName}>');
  }
}
