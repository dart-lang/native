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
  final Set<ClassDecl> linked;

  /// Keeps track of the [TypeParam]s that introduced each type variable.
  final typeVarOrigin = <String, TypeParam>{};

  _ClassLinker(
    this.config,
    this.resolve,
  ) : linked = {...config.importedClasses.values};

  @override
  void visit(ClassDecl node) {
    if (linked.contains(node)) return;
    log.finest('Linking ${node.binaryName}.');
    linked.add(node);

    node.outerClass = node.outerClassBinaryName == null
        ? null
        : resolve(node.outerClassBinaryName);
    node.outerClass?.accept(this);

    // Add type params of outer classes to the nested classes.
    final allTypeParams = <TypeParam>[];
    if (!node.isStatic) {
      allTypeParams.addAll(node.outerClass?.allTypeParams ?? []);
    }
    allTypeParams.addAll(node.typeParams);
    node.allTypeParams = allTypeParams;
    for (final typeParam in node.allTypeParams) {
      typeVarOrigin[typeParam.name] = typeParam;
    }
    final typeLinker = _TypeLinker(resolve, typeVarOrigin);

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
    final methodLinker = _MethodLinker(config, resolve, {...typeVarOrigin});
    for (final method in node.methods) {
      method.classDecl = node;
      method.accept(methodLinker);
    }
    for (final interface in node.interfaces) {
      interface.accept(typeLinker);
    }
    for (final typeParam in node.typeParams) {
      typeParam.accept(_TypeParamLinker(typeLinker));
      typeParam.parent = node;
    }
  }
}

class _MethodLinker extends Visitor<Method, void> {
  _MethodLinker(this.config, this.resolve, this.typeVarOrigin)
      : typeLinker = _TypeLinker(resolve, typeVarOrigin);

  final Config config;
  final _Resolver resolve;
  final Map<String, TypeParam> typeVarOrigin;
  final _TypeLinker typeLinker;

  @override
  void visit(Method node) {
    final hasOuterClassArg = !node.classDecl.isStatic &&
        node.classDecl.isNested &&
        (node.isConstructor || node.isStatic);
    if (hasOuterClassArg) {
      final outerClassTypeParamCount = node.classDecl.allTypeParams.length -
          node.classDecl.typeParams.length;
      final outerClassTypeParams = [
        for (final typeParam
            in node.classDecl.allTypeParams.take(outerClassTypeParamCount)) ...[
          TypeUsage(
              shorthand: typeParam.name, kind: Kind.typeVariable, typeJson: {})
            ..type = (TypeVar(name: typeParam.name)
              ..annotations = [if (typeParam.hasNonNull) Annotation.nonNull]),
        ]
      ];
      final outerClassType = DeclaredType(
        binaryName: node.classDecl.outerClass!.binaryName,
        params: outerClassTypeParams,
        // `$outerClass` parameter must not be null.
        annotations: [Annotation.nonNull],
      );
      final outerClassTypeUsage = TypeUsage(
        shorthand: outerClassType.binaryName,
        kind: Kind.declared,
        typeJson: {},
      )..type = outerClassType;
      final param = Param(name: '\$outerClass', type: outerClassTypeUsage);
      final usedDoclet = node.descriptor == null;
      // For now the nullity of [node.descriptor] identifies if the doclet
      // backend was used and the method would potentially need "unnesting".
      // Static methods and constructors of non-static nested classes take an
      // instance of their outer class as the first parameter.
      //
      // This is not accounted for by the **doclet** summarizer, so we
      // manually add it as the first parameter.
      if (usedDoclet) {
        // Make the list modifiable.
        if (node.params.isEmpty) node.params = [];
        node.params.insert(0, param);
      } else {
        node.params.first = param;
      }
    }
    for (final typeParam in node.typeParams) {
      typeVarOrigin[typeParam.name] = typeParam;
    }
    node.returnType.accept(typeLinker);
    final typeParamLinker = _TypeParamLinker(typeLinker);
    final paramLinker = _ParamLinker(typeLinker);
    for (final typeParam in node.typeParams) {
      typeParam.accept(typeParamLinker);
      typeParam.parent = node;
    }
    for (final param in node.params) {
      param.accept(paramLinker);
      param.method = node;
    }
    node.asyncReturnType?.accept(typeLinker);
  }
}

class _TypeLinker extends TypeVisitor<void> {
  const _TypeLinker(this.resolve, this.typeVarOrigin);

  final _Resolver resolve;
  final Map<String, TypeParam> typeVarOrigin;

  @override
  void visitDeclaredType(DeclaredType node) {
    for (final param in node.params) {
      param.accept(this);
    }
    node.classDecl = resolve(node.binaryName);
  }

  @override
  void visitWildcard(Wildcard node) {
    node.superBound?.type.accept(this);
    node.extendsBound?.type.accept(this);
  }

  @override
  void visitArrayType(ArrayType node) {
    node.elementType.accept(this);
  }

  @override
  void visitTypeVar(TypeVar node) {
    node.origin = typeVarOrigin[node.name]!;
  }

  @override
  void visitPrimitiveType(PrimitiveType node) {
    // Do nothing.
  }

  @override
  void visitNonPrimitiveType(ReferredType node) {
    // Do nothing.
  }
}

class _FieldLinker extends Visitor<Field, void> {
  _FieldLinker(this.typeLinker);

  final _TypeLinker typeLinker;

  @override
  void visit(Field node) {
    node.type.accept(typeLinker);
  }
}

class _TypeParamLinker extends Visitor<TypeParam, void> {
  _TypeParamLinker(this.typeLinker);

  final _TypeLinker typeLinker;

  @override
  void visit(TypeParam node) {
    for (final bound in node.bounds) {
      bound.accept(typeLinker);
    }
  }
}

class _ParamLinker extends Visitor<Param, void> {
  _ParamLinker(this.typeLinker);

  final _TypeLinker typeLinker;

  @override
  void visit(Param node) {
    node.type.accept(typeLinker);
  }
}
