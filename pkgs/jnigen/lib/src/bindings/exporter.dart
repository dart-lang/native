// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../config/config.dart';
import '../elements/elements.dart';
import '../elements/stability_models.dart';
import '../logging/logging.dart';
import 'visitor.dart';

final _version = Version(1, 0, 0);

extension<T extends Element<T>> on Iterable<T> {
  Map<String, E> acceptAndMap<E>(ElementVisitor<T, E> visitor,
      {required String Function(T) key}) {
    final map = <String, E>{};
    for (final element in this) {
      map[key(element)] = element.accept(visitor);
    }
    return map;
  }
}

/// Generates the JSON used for API stability and importing.
class Exporter extends ElementVisitor<Classes, Future<void>>
    with TopLevelVisitor {
  @override
  final stage = GenerationStage.exporter;

  final Config config;

  Exporter(this.config);

  @override
  Future<void> visit(Classes node) async {
    final exportFileUri = config.outputConfig.symbolsConfig?.path ??
        Uri.file('jnigen_symbols.json');

    // FIXME: add package name
    final apiStabilityInfo = StabilityInfo(
      formatVersion: _version,
      packageName: 'tbd',
      files: node.files.values
          .acceptAndMap(_fileExporter, key: (file) => file.path),
    );

    final exportFile = File.fromUri(exportFileUri);
    final sink = exportFile.openWrite();
    await sink.addStream(
        Stream.value(apiStabilityInfo).transform(JsonUtf8Encoder('  ').cast()));
    await sink.close();
  }
}

const _fileExporter = _FileExporter();

class _FileExporter extends ElementVisitor<DartFile, StabilityFile> {
  const _FileExporter();

  @override
  StabilityFile visit(DartFile node) {
    return StabilityFile(
      classes: node.classes.values
          .acceptAndMap(_classExporter, key: (cls) => cls.binaryName),
    );
  }
}

const _classExporter = _ClassExporter();

class _ClassExporter extends ElementVisitor<ClassDecl, StabilityClass> {
  const _ClassExporter();

  @override
  StabilityClass visit(ClassDecl node) {
    return StabilityClass(
      name: node.finalName!,
      superClass: node.superclass!.accept(_typeExporter),
      superInterfaces: node.interfaces.accept(_typeExporter).toList(),
      fields:
          node.fields.acceptAndMap(_fieldExporter, key: (field) => field.name),
      methods: node.methods
          .acceptAndMap(_methodExporter, key: (method) => method.javaSig),
      typeParameters: node.allTypeParams.accept(_typeParamExporter).toList(),
    );
  }
}

const _fieldExporter = _FieldExporter();

class _FieldExporter extends ElementVisitor<Field, StabilityField> {
  const _FieldExporter();

  @override
  StabilityField visit(Field node) {
    return StabilityField(
      name: node.finalName!,
      type: node.type.accept(_typeExporter),
    );
  }
}

const _methodExporter = _MethodExporter();

class _MethodExporter extends ElementVisitor<Method, StabilityMethod> {
  const _MethodExporter();

  @override
  StabilityMethod visit(Method node) {
    if (node.finalName == null) {
      log.warning(
          '${node.classDecl.binaryName}#${node.javaSig} has a null finalName');
    }
    return StabilityMethod(
      name: node.finalName ?? 'NULL',
      typeParameters: node.typeParams.accept(_typeParamExporter).toList(),
      methodParameters: node.params.accept(_paramExporter).toList(),
      returnType: node.returnType.accept(_typeExporter),
    );
  }
}

const _paramExporter = _ParamExporter();

class _ParamExporter extends ElementVisitor<Param, StabilityMethodParameter> {
  const _ParamExporter();

  @override
  StabilityMethodParameter visit(Param node) {
    return StabilityMethodParameter(
      name: node.finalName!,
      type: node.type.accept(_typeExporter),
    );
  }
}

const _typeParamExporter = _TypeParamExporter();

class _TypeParamExporter
    extends ElementVisitor<TypeParam, StabilityTypeParameter> {
  const _TypeParamExporter();

  @override
  StabilityTypeParameter visit(TypeParam node) {
    return StabilityTypeParameter(
      name: node.name,
      bounds: node.bounds.accept(_typeExporter).toList(),
    );
  }
}

const _typeExporter = _TypeExporter();

class _TypeExporter extends TypeVisitor<StabilityType> {
  const _TypeExporter();

  Nullability nullabilityFromType(ReferredType type) {
    // TODO(https://github.com/dart-lang/native/issues/2356): Also refactor this
    // in the internal representation.
    if (type.hasNullable) return Nullability.nullable;
    if (type.hasNonNull) return Nullability.nonNullable;
    return Nullability.platform;
  }

  @override
  StabilityType visitArrayType(ArrayType node) {
    return StabilityArrayType(
      elementType: node.elementType.accept(_typeExporter),
      nullability: nullabilityFromType(node),
    );
  }

  @override
  StabilityType visitPrimitiveType(PrimitiveType node) {
    return StabilityPrimitiveType(name: node.name);
  }

  @override
  StabilityType visitDeclaredType(DeclaredType node) {
    return StabilityDeclaredType(
      binaryName: node.binaryName,
      typeArguments:
          node.params.map((param) => param.accept(_typeExporter)).toList(),
      nullability: nullabilityFromType(node),
    );
  }

  @override
  StabilityType visitTypeVar(TypeVar node) {
    return StabilityTypeVariable(
      name: node.name,
      nullability: nullabilityFromType(node),
    );
  }

  @override
  StabilityType visitWildcard(Wildcard node) {
    return StabilityWildcard(
      extendsBound: node.extendsBound?.accept(_typeExporter),
      superBound: node.superBound?.accept(_typeExporter),
      nullability: nullabilityFromType(node),
    );
  }
}
