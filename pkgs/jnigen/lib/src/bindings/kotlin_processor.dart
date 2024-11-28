// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../elements/elements.dart';
import 'visitor.dart';

String _toJavaBinaryName(String kotlinBinaryName) {
  final binaryName = kotlinBinaryName.replaceAll('/', '.');
  return const {
        'kotlin.Any': 'java.lang.Object',
        'kotlin.Byte': 'java.lang.Byte',
        'kotlin.Short': 'java.lang.Short',
        'kotlin.Int': 'java.lang.Integer',
        'kotlin.Long': 'java.lang.Long',
        'kotlin.Char': 'java.lang.Character',
        'kotlin.Float': 'java.lang.Float',
        'kotlin.Double': 'java.lang.Double',
        'kotlin.Boolean': 'java.lang.Boolean',
        'kotlin.Cloneable': 'java.lang.Cloneable',
        'kotlin.Comparable': 'java.lang.Comparable',
        'kotlin.Enum': 'java.lang.Enum',
        'kotlin.Annotation': 'java.lang.annotation.Annotation',
        'kotlin.CharSequence': 'java.lang.CharSequence',
        'kotlin.String': 'java.lang.String',
        'kotlin.Number': 'java.lang.Number',
        'kotlin.Throwable': 'java.lang.Throwable',
      }[binaryName] ??
      binaryName;
}

/// A [Visitor] that adds the the information from Kotlin's metadata to the Java
/// classes and methods.
class KotlinProcessor extends Visitor<Classes, void> {
  @override
  void visit(Classes node) {
    final classProcessor = _KotlinClassProcessor();
    for (final classDecl in node.decls.values) {
      classDecl.accept(classProcessor);
    }
  }
}

class _KotlinClassProcessor extends Visitor<ClassDecl, void> {
  @override
  void visit(ClassDecl node) {
    if (node.kotlinClass == null && node.kotlinPackage == null) {
      return;
    }
    // This [ClassDecl] is actually a Kotlin class.
    if (node.kotlinClass != null) {
      for (var i = 0; i < node.kotlinClass!.typeParameters.length; ++i) {
        node.typeParams[i].accept(
            _KotlinTypeParamProcessor(node.kotlinClass!.typeParameters[i]));
      }
      node.superclass?.accept(_KotlinTypeProcessor(
        node.kotlinClass!.superTypes.firstWhere((superType) =>
            _toJavaBinaryName(superType.name ?? '') == node.superclass!.name),
      ));
    }

    // Matching fields and properties from the metadata.
    final properties = <String, KotlinProperty>{};
    final getters = <String, KotlinProperty>{};
    final setters = <String, KotlinProperty>{};
    final kotlinProperties =
        (node.kotlinClass?.properties ?? node.kotlinPackage?.properties)!;
    for (final property in kotlinProperties) {
      if (property.fieldName case final fieldName?) {
        properties[fieldName] = property;
      }
      if (property.getterName case final getterName?) {
        final getterSignature = getterName + property.getterDescriptor!;
        getters[getterSignature] = property;
      }
      if (property.setterName case final setterName?) {
        final setterSignature = setterName + property.setterDescriptor!;
        setters[setterSignature] = property;
      }
    }
    for (final field in node.fields) {
      if (properties[field.name] case final property?) {
        field.accept(_KotlinPropertyProcessor(property));
      }
    }
    // Matching methods and functions from the metadata.
    final functions = <String, KotlinFunction>{};
    final kotlinFunctions =
        (node.kotlinClass?.functions ?? node.kotlinPackage?.functions)!;
    for (final function in kotlinFunctions) {
      final signature = function.name + function.descriptor;
      functions[signature] = function;
    }
    final constructors = <String, KotlinConstructor>{};
    final kotlinConstructors = node.kotlinClass?.constructors ?? [];
    for (final constructor in kotlinConstructors) {
      final signature = constructor.name + constructor.descriptor;
      constructors[signature] = constructor;
    }
    for (final method in node.methods) {
      final signature = method.name + method.descriptor!;
      if (functions[signature] case final function?) {
        method.accept(_KotlinMethodProcessor(function));
      } else if (constructors[signature] case final constructor?) {
        method.accept(_KotlinConstructorProcessor(constructor));
      } else if (getters[signature] case final getter?) {
        method.accept(_KotlinGetterProcessor(getter));
      } else if (setters[signature] case final setter?) {
        method.accept(_KotlinSetterProcessor(setter));
      }
    }
  }
}

void _processParams(
    List<Param> params, List<KotlinValueParameter> kotlinParams) {
  if (params.length != kotlinParams.length) {
    return;
  }
  for (var i = 0; i < params.length; ++i) {
    params[i].accept(_KotlinParamProcessor(kotlinParams[i]));
  }
}

class _KotlinMethodProcessor extends Visitor<Method, void> {
  final KotlinFunction function;

  _KotlinMethodProcessor(this.function);

  @override
  void visit(Method node) {
    node.returnType.accept(_KotlinTypeProcessor(function.returnType));
    _processParams(node.params, function.valueParameters);
    for (var i = 0; i < node.typeParams.length; ++i) {
      node.typeParams[i]
          .accept(_KotlinTypeParamProcessor(function.typeParameters[i]));
    }
    if (function.isSuspend) {
      const kotlinContinutationType = 'kotlin.coroutines.Continuation';
      assert(node.params.isNotEmpty &&
          node.params.last.type.kind == Kind.declared &&
          node.params.last.type.name == kotlinContinutationType);
      var continuationType =
          (node.params.last.type.type as DeclaredType).params.firstOrNull;
      if (continuationType != null &&
          continuationType.kind == Kind.wildcard &&
          (continuationType.type as Wildcard).superBound != null) {
        continuationType = (continuationType.type as Wildcard).superBound!;
      }
      node.asyncReturnType = continuationType == null
          ? TypeUsage.object
          : continuationType.clone();
    }
  }
}

class _KotlinConstructorProcessor extends Visitor<Method, void> {
  final KotlinConstructor constructor;

  _KotlinConstructorProcessor(this.constructor);

  @override
  void visit(Method node) {
    _processParams(node.params, constructor.valueParameters);
  }
}

class _KotlinGetterProcessor extends Visitor<Method, void> {
  final KotlinProperty getter;

  _KotlinGetterProcessor(this.getter);

  @override
  void visit(Method node) {
    node.returnType.accept(_KotlinTypeProcessor(getter.returnType));
  }
}

class _KotlinSetterProcessor extends Visitor<Method, void> {
  final KotlinProperty setter;

  _KotlinSetterProcessor(this.setter);

  @override
  void visit(Method node) {
    if (setter.setterParameter case final setterParam?) {
      node.params.single.type.accept(_KotlinTypeProcessor(setterParam.type));
    }
    node.params.single.type.accept(_KotlinTypeProcessor(setter.returnType));
  }
}

class _KotlinPropertyProcessor extends Visitor<Field, void> {
  final KotlinProperty property;

  _KotlinPropertyProcessor(this.property);

  @override
  void visit(Field node) {
    node.type.accept(_KotlinTypeProcessor(property.returnType));
  }
}

class _KotlinParamProcessor extends Visitor<Param, void> {
  final KotlinValueParameter kotlinParam;

  _KotlinParamProcessor(this.kotlinParam);

  @override
  void visit(Param node) {
    node.type.accept(_KotlinTypeProcessor(kotlinParam.type));
  }
}

class _KotlinTypeParamProcessor extends Visitor<TypeParam, void> {
  final KotlinTypeParameter kotlinTypeParam;

  _KotlinTypeParamProcessor(this.kotlinTypeParam);

  @override
  void visit(TypeParam node) {
    final kotlinBounds = kotlinTypeParam.upperBounds;
    final bounds = <String, KotlinType>{};
    for (final bound in kotlinBounds) {
      if (bound.name case final boundName?) {
        bounds[_toJavaBinaryName(boundName)] = bound;
      }
    }
    for (final bound in node.bounds) {
      if (bounds[bound.name] case final kotlinBound?) {
        bound.accept(_KotlinTypeProcessor(kotlinBound));
      }
    }
  }
}

class _KotlinTypeProcessor extends TypeVisitor<void> {
  final KotlinType kotlinType;

  _KotlinTypeProcessor(this.kotlinType);

  @override
  void visitDeclaredType(DeclaredType node) {
    for (var i = 0; i < node.params.length; ++i) {
      node.params[i].accept(_KotlinTypeProcessor(kotlinType.arguments[i].type));
    }
    super.visitDeclaredType(node);
  }

  @override
  void visitArrayType(ArrayType node) {
    node.elementType
        .accept(_KotlinTypeProcessor(kotlinType.arguments.first.type));
  }

  @override
  void visitNonPrimitiveType(ReferredType node) {
    node.annotations ??= [];
    node.annotations!
        .add(kotlinType.isNullable ? Annotation.nullable : Annotation.nonNull);
  }

  @override
  void visitPrimitiveType(PrimitiveType node) {
    // Do nothing.
  }
}
