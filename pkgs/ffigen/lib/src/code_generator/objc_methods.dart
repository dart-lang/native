// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

import 'binding_string.dart';
import 'utils.dart';
import 'writer.dart';

final _logger = Logger('ffigen.code_generator.objc_methods');

mixin ObjCMethods {
  final _methods = <String, ObjCMethod>{};

  Iterable<ObjCMethod> get methods => _methods.values;
  ObjCMethod? getMethod(String name) => _methods[name];

  String get originalName;

  void addMethod(ObjCMethod method) {
    _methods[method.originalName] =
        _maybeReplaceMethod(getMethod(method.originalName), method);
  }

  void addMethodDependencies(
    Set<Binding> dependencies,
    ObjCBuiltInFunctions builtInFunctions, {
    bool needMsgSend = false,
    bool needBlock = false,
  }) {
    for (final m in methods) {
      m.addDependencies(dependencies, builtInFunctions,
          needMsgSend: needMsgSend, needBlock: needBlock);
    }
  }

  ObjCMethod _maybeReplaceMethod(
      ObjCMethod? oldMethod, ObjCMethod newMethod) {
    if (oldMethod == null) return newMethod;

    // Typically we ignore duplicate methods. However, property setters and
    // getters are duplicated in the AST. One copy is marked with
    // ObjCMethodKind.propertyGetter/Setter. The other copy is missing
    // important information, and is a plain old instanceMethod. So if the
    // existing method is an instanceMethod, and the new one is a property,
    // override it.
    if (newMethod.isProperty && !oldMethod.isProperty) {
      return newMethod;
    } else if (!newMethod.isProperty && oldMethod.isProperty) {
      // Don't override, but also skip the same method check below.
      return oldMethod;
    }

    // Check the duplicate is the same method.
    if (!newMethod.sameAs(oldMethod)) {
      _logger.severe('Duplicate methods with different signatures: '
          '$originalName.${newMethod.originalName}');
      return newMethod;
    }

    // There's a bug in some Apple APIs where an init method that should return
    // instancetype has a duplicate definition that instead returns id. In that
    // case, use the one that returns instancetype. Note that since instancetype
    // is an alias of id, the sameAs check above passes.
    if (ObjCBuiltInFunctions.isInstanceType(newMethod.returnType) &&
        !ObjCBuiltInFunctions.isInstanceType(oldMethod.returnType)) {
      return newMethod;
    } else if (!ObjCBuiltInFunctions.isInstanceType(newMethod.returnType) &&
        ObjCBuiltInFunctions.isInstanceType(oldMethod.returnType)) {
      return oldMethod;
    }

    return newMethod;
  }
}

enum ObjCMethodKind {
  method,
  propertyGetter,
  propertySetter,
}

class ObjCProperty {
  final String originalName;
  String? dartName;

  ObjCProperty(this.originalName);
}

class ObjCMethod {
  final String? dartDoc;
  final String originalName;
  final ObjCProperty? property;
  Type returnType;
  final List<ObjCMethodParam> params;
  final ObjCMethodKind kind;
  final bool isClass;
  final bool isOptional;
  bool returnsRetained = false;
  ObjCInternalGlobal? selObject;
  ObjCMsgSendFunc? msgSend;
  ObjCBlock? block;

  ObjCMethod({
    required this.originalName,
    this.property,
    this.dartDoc,
    required this.kind,
    required this.isClass,
    required this.isOptional,
    required this.returnType,
    List<ObjCMethodParam>? params_,
  }) : params = params_ ?? [];

  bool get isProperty =>
      kind == ObjCMethodKind.propertyGetter ||
      kind == ObjCMethodKind.propertySetter;
  bool get isRequired => !isOptional;
  bool get isInstance => !isClass;

  void addDependencies(
    Set<Binding> dependencies,
    ObjCBuiltInFunctions builtInFunctions, {
    bool needMsgSend = false,
    bool needBlock = false,
  }) {
    returnType.addDependencies(dependencies);
    for (final p in params) {
      p.type.addDependencies(dependencies);
    }
    selObject ??= builtInFunctions.getSelObject(originalName)
      ..addDependencies(dependencies);
    if (needMsgSend) {
      msgSend ??= builtInFunctions.getMsgSendFunc(returnType, params)
        ..addDependencies(dependencies);
    }
    if (needBlock) {
      block = ObjCBlock(
        returnType: returnType,
        argTypes: params.map((p) => p.type).toList(),
      )..addDependencies(dependencies);
    }
  }

  String getDartMethodName(UniqueNamer uniqueNamer) {
    if (property != null) {
      // A getter and a setter are allowed to have the same name, so we can't
      // just run the name through uniqueNamer. Instead they need to share
      // the dartName, which is run through uniqueNamer.
      if (property!.dartName == null) {
        property!.dartName = uniqueNamer.makeUnique(property!.originalName);
      }
      return property!.dartName!;
    }
    // Objective C methods can look like:
    // foo
    // foo:
    // foo:someArgName:
    // So replace all ':' with '_'.
    return uniqueNamer.makeUnique(originalName.replaceAll(":", "_"));
  }

  bool sameAs(ObjCMethod other) {
    if (originalName != other.originalName) return false;
    if (kind != other.kind) return false;
    if (isClass != other.isClass) return false;
    if (isOptional != other.isOptional) return false;
    // msgSend is deduped by signature, so this check covers the signature.
    return msgSend == other.msgSend;
  }

  static final _copyRegExp = RegExp('[cC]opy');
  bool get isOwnedReturn =>
      returnsRetained ||
      originalName.startsWith('new') ||
      originalName.startsWith('alloc') ||
      originalName.contains(_copyRegExp);

  @override
  String toString() =>
      '${isOptional ? "@optional " : ""}$returnType $originalName(${params.join(', ')})';
}

class ObjCMethodParam {
  Type type;
  final String name;
  ObjCMethodParam(this.type, this.name);

  @override
  String toString() => '$type $name';
}
