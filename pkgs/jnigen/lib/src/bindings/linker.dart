// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../config/config.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import 'visitor.dart';

typedef _Resolver = ClassDecl Function(String? binaryName);

/// An [ElementVisitor] that adds the correct [ClassDecl] references from the
/// string binary names.
///
/// It adds the following references:
/// * Links [ClassDecl] objects from imported dependencies.
/// * Adds references from child elements back to their parent elements.
/// * Resolves Kotlin specific `asyncReturnType` for methods.
class Linker extends ElementVisitor<Classes, Future<void>>
    with TopLevelVisitor {
  @override
  final GenerationStage stage = GenerationStage.linker;

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
      final file = node.files[path] ??= DartFile(path, {...node.decls});
      for (final decl in node.decls.values) {
        decl.file = file;
      }
    } else {
      for (final decl in node.decls.values) {
        final dollarSign = decl.binaryName.indexOf('\$');
        final className = dollarSign != -1
            ? decl.binaryName.substring(0, dollarSign)
            : decl.binaryName;
        final path = root
            .resolve(
              '${className.replaceAll('.', Platform.pathSeparator)}.dart',
            )
            .toFilePath();
        final file = node.files[path] ??= DartFile(path, {});
        decl.file = file;
        file.classes[decl.binaryName] = decl;
        // Create a `_package.dart` file in each package that exports all of the
        // classes within that package.
        final packagePath = root
            .resolve(decl.packageName.replaceAll('.', Platform.pathSeparator))
            .resolve('_package.dart')
            .toFilePath();
        final packageFile = node.files[packagePath] ??= DartFile(
          packagePath,
          {},
        );
        packageFile.exports.add(file);
      }
    }

    ClassDecl resolve(String? binaryName) {
      return node.importedClasses[binaryName] ??
          node.decls[binaryName] ??
          resolve(DeclaredType.object.name);
    }

    DeclaredType.object.classDecl = resolve(DeclaredType.object.name);
    final classLinker = _ClassLinker(config, resolve);
    for (final classDecl in node.decls.values) {
      classDecl.accept(classLinker);
    }
  }
}

class _ClassLinker extends ElementVisitor<ClassDecl, void> {
  final Config config;
  final _Resolver resolve;
  final Set<ClassDecl> linked;

  _ClassLinker(this.config, this.resolve) : linked = {};

  @override
  void visit(ClassDecl node) {
    if (linked.contains(node) || node.isImported) return;
    log.finest('Linking ${node.binaryName}.');
    linked.add(node);

    node.outerClass = node.outerClassBinaryName == null
        ? null
        : resolve(node.outerClassBinaryName);
    node.outerClass?.accept(this);

    // Add type params of outer classes to the nested classes.
    node.allTypeParams = [];
    if (!node.isStatic) {
      node.allTypeParams.addAll(
        node.outerClass?.allTypeParams.map(
              (typeParam) => typeParam.clone(until: GenerationStage.linker),
            ) ??
            [],
      );
    }
    node.allTypeParams.addAll(node.typeParams);

    /// Keeps track of the [TypeParam]s that introduced each type variable.
    final typeVarOrigin = <String, TypeParam>{};
    for (final typeParam in node.allTypeParams) {
      typeVarOrigin[typeParam.name] = typeParam;
    }

    final typeLinker = _TypeLinker(resolve, typeVarOrigin);

    for (final typeParam in node.typeParams) {
      typeParam.accept(_TypeParamLinker(typeLinker));
      typeParam.parent = node;
    }

    node.superclass ??= DeclaredType.object;
    node.superclass!.accept(typeLinker);
    final superclass = (node.superclass! as DeclaredType).classDecl;
    superclass.accept(this);

    final signatureToMethod = <String, Method>{};
    for (final method in node.methods) {
      method.classDecl = node;
      method.accept(_MethodLinker(config, resolve, {...typeVarOrigin}));
      signatureToMethod[method.javaSig] = method;
    }
    // Add all methods from the superinterfaces and the superclass.
    if (node.methods.isEmpty) {
      // Make the list modifiable.
      node.methods = [];
    }

    node.superCount = superclass.superCount + 1;

    final fieldLinker = _FieldLinker(typeLinker);
    for (final field in node.fields) {
      field.classDecl = node;
      field.accept(fieldLinker);
    }
    final debug = node.binaryName ==
        'com.github.dart_lang.jnigen.inheritance.DerivedInterface';
    if (debug) log.warning('signatures: $signatureToMethod');
    void moveMethod(Method method, DeclaredType fromType) {
      if (signatureToMethod.containsKey(method.javaSig)) {
        if (debug)
          log.warning(
              'signatures contain ${method.javaSig} from ${method.classDecl.binaryName}');
        // If this method also exists in a super interface, the methods
        // should share their sharedState.
        final thisMethod = signatureToMethod[method.javaSig]!;
        thisMethod.sharedState = method.sharedState;
      } else {
        if (debug)
          log.warning(
              'signatures do not contain ${method.javaSig} from ${method.classDecl.binaryName}');
        final clonedMethod = method.clone(until: GenerationStage.linker);
        clonedMethod.accept(_MethodMover(fromType: fromType, toClass: node));
        clonedMethod.accept(_MethodLinker(config, resolve, {...typeVarOrigin}));
        signatureToMethod[clonedMethod.javaSig] = clonedMethod;
        node.methods.add(clonedMethod);
      }
    }

    for (final interface in node.interfaces) {
      interface.accept(typeLinker);
      if (interface case final DeclaredType interfaceType) {
        interfaceType.classDecl.accept(this);
        for (final interfaceMethod in interfaceType.classDecl.methods) {
          moveMethod(interfaceMethod, interfaceType);
        }
      }
    }

    void moveField(Field field) {
      // FIXME
    }

    if (node.superclass case final DeclaredType superType?) {
      for (final method in superclass.methods) {
        if (!method.isStatic && !method.isConstructor) {
          moveMethod(method, superType);
        }
      }
      for (final field in superclass.fields) {
        if (!field.isStatic) {
          moveField(field);
        }
      }
    }
  }
}

class _MethodLinker extends ElementVisitor<Method, void> {
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
        for (final typeParam in node.classDecl.allTypeParams.take(
          outerClassTypeParamCount,
        )) ...[
          TypeVar(name: typeParam.name)
            ..annotations = [if (typeParam.hasNonNull) Annotation.nonNull],
        ],
      ];
      final outerClassType = DeclaredType(
        binaryName: node.classDecl.outerClass!.binaryName,
        params: outerClassTypeParams,
        // `$outerClass` parameter must not be null.
        annotations: [Annotation.nonNull],
      );
      final param = Param(name: '\$outerClass', type: outerClassType);
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
    final typeParamLinker = _TypeParamLinker(typeLinker);
    for (final typeParam in node.typeParams) {
      typeParam.accept(typeParamLinker);
      typeParam.parent = node;
    }
    node.descriptor = node.accept(_MethodDescriptor(typeVarOrigin));
    node.returnType.accept(typeLinker);

    // If the type itself does not have nullability annotations, use the
    // parent's nullability annotations. Some annotations such as
    // `androidx.annotation.NonNull` only get applied to elements but not types.
    if (!node.returnType.hasNullabilityAnnotations &&
        node.hasNullabilityAnnotations) {
      node.returnType.annotations = [
        ...?node.returnType.annotations,
        ...?node.annotations,
      ];
    }
    final paramLinker = _ParamLinker(typeLinker);
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
      final returnType = node.returnType;
      final parameterType = node.params.single.type;
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
    node.superBound?.accept(this);
    node.extendsBound?.accept(this);
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
}

class _FieldLinker extends ElementVisitor<Field, void> {
  _FieldLinker(this.typeLinker);

  final _TypeLinker typeLinker;

  @override
  void visit(Field node) {
    // If the type itself does not have nullability annotations, use the
    // parent's nullability annotations. Some annotations such as
    // `androidx.annotation.NonNull` only get applied to elements but not types.
    if (!node.type.hasNullabilityAnnotations &&
        node.hasNullabilityAnnotations) {
      node.type.annotations = [...?node.type.annotations, ...?node.annotations];
    }
    node.type.accept(typeLinker);
    node.descriptor ??= node.type.descriptor;
    node.type.descriptor = node.type.accept(
      _TypeDescriptor(typeLinker.typeVarOrigin),
    );
  }
}

class _TypeParamLinker extends ElementVisitor<TypeParam, void> {
  _TypeParamLinker(this.typeLinker);

  final _TypeLinker typeLinker;

  @override
  void visit(TypeParam node) {
    for (final bound in node.bounds) {
      bound.accept(typeLinker);
    }
  }
}

class _ParamLinker extends ElementVisitor<Param, void> {
  _ParamLinker(this.typeLinker);

  final _TypeLinker typeLinker;

  @override
  void visit(Param node) {
    // If the type itself does not have nullability annotations, use the
    // parent's nullability annotations. Some annotations such as
    // `androidx.annotation.NonNull` only get applied to elements but not types.
    if (!node.type.hasNullabilityAnnotations &&
        node.hasNullabilityAnnotations) {
      node.type.annotations = [...?node.type.annotations, ...?node.annotations];
    }
    node.type.accept(typeLinker);
  }
}

/// Once a [Method] is cloned and added to another [ClassDecl], the original
/// type parameters can be replaced with other ones and its `classDecl` will be
/// different. This visitor fixes these issues after the cloning is done.
class _MethodMover extends ElementVisitor<Method, void> {
  final DeclaredType fromType;
  final ClassDecl toClass;

  _MethodMover({required this.fromType, required this.toClass});

  @override
  void visit(Method node) {
    final b = node.javaSig == 'push(Ljava/lang/Object;)V';
    if (b) log.warning('moving ${node.javaSig}...');
    node.classDecl = toClass;
    final typeMover = _TypeMover(fromType: fromType);
    if (node.returnType is TypeVar) {
      node.returnType = typeMover.replaceTypeVar(node.returnType as TypeVar);
    } else {
      node.returnType.accept(typeMover);
    }
    for (final param in node.params) {
      if (param.type is TypeVar) {
        if (b) log.warning('param ${param.name} is a type var');
        if (b) log.warning('origin: ${(param.type as TypeVar).origin.parent}');
        param.type = typeMover.replaceTypeVar(param.type as TypeVar);
        if (b) log.warning('now it became: ${param.type.name}');
      } else {
        param.type.accept(typeMover);
      }
    }
    for (final typeParam in node.typeParams) {
      for (final (i, bound) in typeParam.bounds.indexed) {
        if (bound is TypeVar) {
          typeParam.bounds[i] = typeMover.replaceTypeVar(bound);
        } else {
          bound.accept(typeMover);
        }
      }
    }
  }
}

class _TypeMover extends TypeVisitor<void> with DefaultNonPrimitive {
  final DeclaredType fromType;

  _TypeMover({required this.fromType});

  @override
  void visitNonPrimitiveType(ReferredType node) {
    // Do nothing.
  }

  ReferredType replaceTypeVar(TypeVar typeVar) {
    if (typeVar.origin.parent == fromType.classDecl) {
      final index = fromType.classDecl.allTypeParams.indexWhere(
        (typeParam) => typeParam.name == typeVar.name,
      );
      if (index != -1) {
        if (index >= fromType.params.length) {
          return DeclaredType.object.clone();
        }
        return fromType.params[index].clone(until: GenerationStage.linker);
      }
    }
    return typeVar;
  }

  @override
  void visitDeclaredType(DeclaredType node) {
    for (final (i, typeParam) in node.params.indexed) {
      if (typeParam is TypeVar) {
        node.params[i] = replaceTypeVar(typeParam);
      } else {
        typeParam.accept(this);
      }
    }
  }

  @override
  void visitArrayType(ArrayType node) {
    if (node.elementType is TypeVar) {
      node.elementType = replaceTypeVar(node.elementType as TypeVar);
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
class _MethodDescriptor extends ElementVisitor<Method, String> {
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
    final returnTypeDesc = node.returnType.accept(
      _TypeDescriptor(typeVarOrigin),
    );
    node.returnType.descriptor = returnTypeDesc;
    s.write(returnTypeDesc);
    return s.toString();
  }
}

/// JVM representation of type signatures.
///
/// https://docs.oracle.com/en/java/javase/18/docs/specs/jni/types.html#type-signatures
class _TypeDescriptor extends TypeVisitor<String> with DefaultNonPrimitive {
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
