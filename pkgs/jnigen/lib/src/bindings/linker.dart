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

    (TypeUsage.object.type as DeclaredType).classDecl =
        resolve(TypeUsage.object.name);
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

    final methodSignatures = <String>{};
    final methodLinker = _MethodLinker(config, resolve, {...typeVarOrigin});
    for (final method in node.methods) {
      method.classDecl = node;
      method.accept(methodLinker);
      methodSignatures.add(method.javaSig);
    }
    // Add all methods from the superinterfaces of this class.
    if (node.methods.isEmpty) {
      // Make the list modifiable.
      node.methods = [];
    }
    for (final interface in node.interfaces) {
      interface.accept(typeLinker);
      if (interface.type case final DeclaredType interfaceType) {
        interfaceType.classDecl.accept(this);
        for (final interfaceMethod in interfaceType.classDecl.methods) {
          final clonedMethod =
              interfaceMethod.clone(until: GenerationStage.linker);
          clonedMethod.accept(_MethodMover(
            typeVarOrigin: {...typeVarOrigin},
            fromType: interfaceType,
            toClass: node,
          ));
          if (!methodSignatures.contains(clonedMethod.javaSig)) {
            clonedMethod.accept(methodLinker);
            methodSignatures.add(clonedMethod.javaSig);
            node.methods.add(clonedMethod);
          }
        }
      }
    }

    node.superCount = superclass.superCount + 1;

    final fieldLinker = _FieldLinker(typeLinker);
    for (final field in node.fields) {
      field.classDecl = node;
      field.accept(fieldLinker);
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
    node.descriptor = node.accept(_MethodDescriptor(typeVarOrigin));
    node.returnType.accept(typeLinker);

    // If the type itself does not have nullability annotations, use the
    // parent's nullability annotations. Some annotations such as
    // `androidx.annotation.NonNull` only get applied to elements but not types.
    if (!node.returnType.type.hasNullabilityAnnotations &&
        node.hasNullabilityAnnotations) {
      node.returnType.type.annotations = [
        ...?node.returnType.type.annotations,
        ...?node.annotations,
      ];
    }
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
    // Fill out operator overloadings.
    if (node.kotlinFunction?.isOperator ?? false) {
      if (Operator.values.asNameMap()[node.kotlinFunction!.name]
          case final operatorKind? when operatorKind.isCompatibleWith(node)) {
        node.classDecl.operators[operatorKind] ??= node;
      }
    }
    // Fill out compareTo method of the class used for comparison operators.
    if (node.name == 'compareTo' && node.params.length == 1) {
      final returnType = node.returnType.type;
      final parameterType = node.params.single.type.type;
      if (parameterType is DeclaredType &&
          parameterType.binaryName == node.classDecl.binaryName &&
          returnType is PrimitiveType &&
          returnType.dartType == 'int') {
        node.classDecl.compareTo = node;
      }
    }
  }
}

class _TypeLinker extends TypeVisitor<void> {
  const _TypeLinker(this.resolve, this.typeVarOrigin);

  final _Resolver resolve;
  final Map<String, TypeParam> typeVarOrigin;

  @override
  void visitDeclaredType(DeclaredType node) {
    node.classDecl = resolve(node.binaryName);
    for (final param in node.params) {
      param.accept(this);
    }
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
    // If the type itself does not have nullability annotations, use the
    // parent's nullability annotations. Some annotations such as
    // `androidx.annotation.NonNull` only get applied to elements but not types.
    if (!node.type.type.hasNullabilityAnnotations &&
        node.hasNullabilityAnnotations) {
      node.type.type.annotations = [
        ...?node.type.type.annotations,
        ...?node.annotations,
      ];
    }
    node.type.accept(typeLinker);
    node.type.descriptor =
        node.type.accept(_TypeDescriptor(typeLinker.typeVarOrigin));
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
    // If the type itself does not have nullability annotations, use the
    // parent's nullability annotations. Some annotations such as
    // `androidx.annotation.NonNull` only get applied to elements but not types.
    if (!node.type.type.hasNullabilityAnnotations &&
        node.hasNullabilityAnnotations) {
      node.type.type.annotations = [
        ...?node.type.type.annotations,
        ...?node.annotations,
      ];
    }
    node.type.accept(typeLinker);
  }
}

/// Once a [Method] is cloned and added to another [ClassDecl], the original
/// type parameters can be replaced with other ones and its `classDecl` will be
/// different. This visitor fixes these issues after the cloning is done.
class _MethodMover extends Visitor<Method, void> {
  final Map<String, TypeParam> typeVarOrigin;
  final DeclaredType fromType;
  final ClassDecl toClass;

  _MethodMover({
    required this.typeVarOrigin,
    required this.fromType,
    required this.toClass,
  });

  @override
  void visit(Method node) {
    node.classDecl = toClass;
    final typeMover = _TypeMover(fromType: fromType);
    if (node.returnType.kind == Kind.typeVariable) {
      node.returnType = typeMover.replaceTypeVar(node.returnType);
    } else {
      node.returnType.accept(typeMover);
    }
    for (final param in node.params) {
      if (param.type.kind == Kind.typeVariable) {
        param.type = typeMover.replaceTypeVar(param.type);
      } else {
        param.type.accept(typeMover);
      }
    }
    for (final typeParam in node.typeParams) {
      for (final (i, bound) in typeParam.bounds.indexed) {
        if (bound.kind == Kind.typeVariable) {
          typeParam.bounds[i] = typeMover.replaceTypeVar(bound);
        } else {
          bound.accept(typeMover);
        }
      }
    }
    // Since the types can be changed, the descriptor can be changed as well.
    for (final typeParam in node.typeParams) {
      typeVarOrigin[typeParam.name] = typeParam;
    }
    node.descriptor = node.accept(_MethodDescriptor(typeVarOrigin));
  }
}

class _TypeMover extends TypeVisitor<void> {
  final DeclaredType fromType;

  _TypeMover({required this.fromType});

  @override
  void visitNonPrimitiveType(ReferredType node) {
    // Do nothing.
  }

  TypeUsage replaceTypeVar(TypeUsage typeUsage) {
    final typeVar = typeUsage.type as TypeVar;
    if (typeVar.origin.parent == fromType.classDecl) {
      final index = fromType.classDecl.allTypeParams
          .indexWhere((typeParam) => typeParam.name == typeVar.name);
      if (index != -1) {
        return fromType.params[index].clone(until: GenerationStage.linker);
      }
    }
    return typeUsage;
  }

  @override
  void visitDeclaredType(DeclaredType node) {
    for (final (i, typeParam) in node.params.indexed) {
      if (typeParam.type is TypeVar) {
        node.params[i] = replaceTypeVar(typeParam);
      } else {
        typeParam.type.accept(this);
      }
    }
  }

  @override
  void visitArrayType(ArrayType node) {
    if (node.elementType.type is TypeVar) {
      node.elementType = replaceTypeVar(node.elementType);
    } else {
      node.elementType.accept(this);
    }
  }

  @override
  void visitPrimitiveType(PrimitiveType node) {
    // Do nothing.
  }
}

/// Generates JNI Method descriptor.
///
/// https://docs.oracle.com/en/java/javase/18/docs/specs/jni/types.html#type-signatures
/// Also see: [_TypeDescriptor]
class _MethodDescriptor extends Visitor<Method, String> {
  final Map<String, TypeParam> typeVarOrigin;

  _MethodDescriptor(this.typeVarOrigin);

  @override
  String visit(Method node) {
    final s = StringBuffer();
    final typeDescriptor = _TypeDescriptor(typeVarOrigin);
    s.write('(');
    for (final param in node.params) {
      final desc = param.type.accept(typeDescriptor);
      param.type.descriptor = desc;
      s.write(desc);
    }
    s.write(')');
    final returnTypeDesc =
        node.returnType.accept(_TypeDescriptor(typeVarOrigin));
    node.returnType.descriptor = returnTypeDesc;
    s.write(returnTypeDesc);
    return s.toString();
  }
}

/// JVM representation of type signatures.
///
/// https://docs.oracle.com/en/java/javase/18/docs/specs/jni/types.html#type-signatures
class _TypeDescriptor extends TypeVisitor<String> {
  final Map<String, TypeParam> typeVarOrigin;

  _TypeDescriptor(this.typeVarOrigin);

  @override
  String visitArrayType(ArrayType node) {
    final inner = node.elementType.accept(this);
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
    final typeParam = typeVarOrigin[node.name]!;
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
