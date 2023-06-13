// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config/config.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import 'visitor.dart';

typedef _Resolver = ClassDecl Function(String? binaryName);

/// A [Visitor] that adds the correct [ClassDecl] references from the
/// string binary names.
///
/// It adds the following references:
/// * Links [ClassDecl] objects from imported dependencies.
/// * Adds references from child elements back to their parent elements.
/// * Resolves Kotlin specific `asyncReturnType` for methods.
class Linker extends Visitor<Classes, Future<void>> {
  Linker(this.config);

  final Config config;

  @override
  Future<void> visit(Classes node) async {
    // Specify paths for this package's classes.
    final root = config.outputConfig.dartConfig.path;
    if (config.outputConfig.dartConfig.structure ==
        OutputStructure.singleFile) {
      // Connect all to the root if the output is in single file mode.
      final path = root.toFilePath();
      for (final decl in node.decls.values) {
        decl.path = path;
      }
    } else {
      for (final decl in node.decls.values) {
        final dollarSign = decl.binaryName.indexOf('\$');
        final className = dollarSign != -1
            ? decl.binaryName.substring(0, dollarSign)
            : decl.binaryName;
        final path = className.replaceAll('.', '/');
        decl.path = root.resolve(path).toFilePath();
      }
    }

    // Find all the imported classes.
    await config.importClasses();

    if (config.importedClasses.keys
        .toSet()
        .intersection(node.decls.keys.toSet())
        .isNotEmpty) {
      log.fatal(
        'Trying to re-import the generated classes.\n'
        'Try hiding the class(es) in import.',
      );
    }

    for (final className in config.importedClasses.keys) {
      log.finest('Imported $className successfully.');
    }

    ClassDecl resolve(String? binaryName) {
      return config.importedClasses[binaryName] ??
          node.decls[binaryName] ??
          resolve(TypeUsage.object.name);
    }

    final classLinker = _ClassLinker(
      config,
      resolve,
    );
    for (final classDecl in node.decls.values) {
      classDecl.accept(classLinker);
    }
  }
}

class _ClassLinker extends Visitor<ClassDecl, void> {
  final Config config;
  final _Resolver resolve;
  final Set<ClassDecl> _linked;

  _ClassLinker(
    this.config,
    this.resolve,
  ) : _linked = {...config.importedClasses.values};

  @override
  void visit(ClassDecl node) {
    if (_linked.contains(node)) return;
    log.finest('Linking ${node.binaryName}.');
    _linked.add(node);

    node.parent = node.parentName == null ? null : resolve(node.parentName);

    final typeLinker = _TypeLinker(resolve);
    node.superclass ??= TypeUsage.object;
    node.superclass!.type.accept(typeLinker);
    final superclass = (node.superclass!.type as DeclaredType).classDecl;
    superclass.accept(this);

    node.superCount = superclass.superCount + 1;

    final fieldLinker = _FieldLinker(typeLinker);
    for (final field in node.fields) {
      field.classDecl = node;
      field.accept(fieldLinker);
    }
    final methodLinker = _MethodLinker(config, typeLinker);
    for (final method in node.methods) {
      method.classDecl = node;
      method.accept(methodLinker);
    }
    node.interfaces.accept(typeLinker).toList();
    node.typeParams.accept(_TypeParamLinker(typeLinker)).toList();
  }
}

class _MethodLinker extends Visitor<Method, void> {
  _MethodLinker(this.config, this.typeVisitor);

  final Config config;
  final TypeVisitor<void> typeVisitor;

  @override
  void visit(Method node) {
    node.returnType.accept(typeVisitor);
    final typeParamLinker = _TypeParamLinker(typeVisitor);
    final paramLinker = _ParamLinker(typeVisitor);
    node.typeParams.accept(typeParamLinker).toList();
    node.params.accept(paramLinker).toList();
    // Kotlin specific
    const kotlinContinutationType = 'kotlin.coroutines.Continuation';
    if (config.suspendFunToAsync &&
        node.params.isNotEmpty &&
        node.params.last.type.kind == Kind.declared &&
        node.params.last.type.name == kotlinContinutationType) {
      final continuationType = node.params.last.type.type as DeclaredType;
      node.asyncReturnType = continuationType.params.isEmpty
          ? TypeUsage.object
          : continuationType.params.first;
    } else {
      node.asyncReturnType = null;
    }
    node.asyncReturnType?.accept(typeVisitor);
  }
}

class _TypeLinker extends TypeVisitor<void> {
  const _TypeLinker(this.resolve);

  final _Resolver resolve;

  @override
  void visitDeclaredType(DeclaredType node) {
    node.params.accept(this).toList();
    node.classDecl = resolve(node.binaryName);
  }

  @override
  void visitWildcard(Wildcard node) {
    node.superBound?.type.accept(this);
    node.extendsBound?.type.accept(this);
  }

  @override
  void visitArrayType(ArrayType node) {
    node.type.accept(this);
  }

  @override
  void visitPrimitiveType(PrimitiveType node) {
    // Do nothing
  }

  @override
  void visitNonPrimitiveType(ReferredType node) {
    // Do nothing
  }
}

class _FieldLinker extends Visitor<Field, void> {
  _FieldLinker(this.typeVisitor);

  final TypeVisitor<void> typeVisitor;

  @override
  void visit(Field node) {
    node.type.accept(typeVisitor);
  }
}

class _TypeParamLinker extends Visitor<TypeParam, void> {
  _TypeParamLinker(this.typeVisitor);

  final TypeVisitor<void> typeVisitor;

  @override
  void visit(TypeParam node) {
    for (final bound in node.bounds) {
      bound.accept(typeVisitor);
    }
  }
}

class _ParamLinker extends Visitor<Param, void> {
  _ParamLinker(this.typeVisitor);

  final TypeVisitor<void> typeVisitor;

  @override
  void visit(Param node) {
    node.type.accept(typeVisitor);
  }
}
