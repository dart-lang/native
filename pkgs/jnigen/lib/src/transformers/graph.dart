// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:meta/meta.dart' as meta show internal;

import '../elements/elements.dart' as internal;

const _disallowedAsClassName = {
  'abstract',
  'covariant',
  'deferred',
  'dynamic',
  'export',
  'extension',
  'external',
  'factory',
  'Function',
  'implements',
  'interface',
  'late',
  'library',
  'mixin',
  'operator',
  'part',
  'required',
  'static',
  'typedef',
};

const _keywords = {
  'assert',
  'await', // Cannot be used in async context.
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'import',
  'in',
  'is',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'while',
  'with',
  'yield', // Cannot be used in async context.
};

const _disallowedInInterface = {
  'implement',
  'implementIn',
};

final _validDartIdentifier = RegExp(r'^[a-zA-Z_$][a-zA-Z0-9_$]*$');

abstract class Visitor {
  void visit(Bindings bindings) {
    bindings.visitChildren(this);
  }

  void visitClass(Class cls) {
    cls.visitChildren(this);
  }

  void visitProperty(Property property) {}

  void visitMethod(Method method) {
    method.visitChildren(this);
  }

  void visitMethodParameter(MethodParameter methodParameter) {}
}

abstract final class _Node<T extends internal.Element<T>> {
  final T _internalNode;

  _Node(this._internalNode);
}

base mixin _Visitable {
  void accept(Visitor visitor);
}

base mixin _HasVisitableChildren {
  void visitChildren(Visitor visitor);
}

base mixin _HasModifiers<T extends internal.HasModifiers<T>> on _Node<T> {
  bool get isAbstract => _internalNode.isAbstract;
  bool get isStatic => _internalNode.isStatic;
  bool get isFinal => _internalNode.isFinal;
  bool get isPublic => _internalNode.isPublic;
  bool get isProtected => _internalNode.isProtected;
  bool get isSynthetic => _internalNode.isSynthetic;
  bool get isBridge => _internalNode.isBridge;
}

base mixin _Renamable<T extends internal.Renamable<T>> on _Node<T> {
  /// The name that will uniquely identify this element between in the context
  /// of its parent node.
  String get identifier;

  /// The original name of the element in the source language.
  String get originalName => _internalNode.originalName;

  /// The name loaded from the API stability file.
  ///
  /// This will be `null` if the element was not found in the API stability
  /// file, for example, when running for the first time or after a new element
  /// is added.
  String? get stableName => _internalNode.stableName;

  /// The current name of the element. This will be used in the generated
  /// bindings.
  ///
  /// Setting is subject to validation.
  String? get name => _internalNode.finalName;

  set name(String? newName) {
    _internalNode.finalName = newName;
  }

  /// Whether the given name is allowed for this element.
  ///
  /// Returns `false` if the name is a Dart keyword or cannot be syntactically
  /// the name of this element due to name collision.
  bool isNameAllowed(String name);
}

base mixin _Excludable<T extends internal.Excludable<T>> on _Node<T> {
  /// Whether this element is excluded from the generated bindings.
  bool get isExcluded => _internalNode.isExcluded;

  set isExcluded(bool isExcluded) {
    _internalNode.isExcluded = isExcluded;
  }
}

/// This class represents the entire set of generated code for a single
/// JNIgen run. It's the main entry point for any user-defined transformations.
final class Bindings extends _Node<internal.Classes>
    with _Visitable, _HasVisitableChildren {
  @meta.internal
  Bindings(super._internalNode, this._classes, this._files);

  /// Stored in topological order of the classes.
  final Map<String, Class> _classes;
  final Map<String, DartFile> _files;

  Iterable<Class> get classes => _classes.values;
  Iterable<DartFile> get files => _files.values;

  @override
  void accept(Visitor visitor) {
    visitor.visit(this);
  }

  @override
  void visitChildren(Visitor visitor) {
    for (final cls in classes) {
      cls.accept(visitor);
    }
  }
}

/// Represents a Dart file.
final class DartFile extends _Node<internal.DartFile>
    with _HasVisitableChildren {
  final Map<String, Class> _classes;

  @meta.internal
  DartFile(super._internalNode, this._classes) {
    for (final cls in classes) {
      cls.enclosingFile = this;
    }
  }

  String get path => _internalNode.path;

  Iterable<Class> get classes => _classes.values;

  @override
  void visitChildren(Visitor visitor) {
    for (final cls in classes) {
      cls.accept(visitor);
    }
  }
}

enum Language {
  java,
  kotlin,
}

enum DeclKind {
  /// Declared as a normal class.
  classKind,

  /// Declared as an interface.
  interfaceKind,

  /// Declared as an enum.
  enumKind,

  /// Declared as a collection of top-level methods and properties.
  packageKind,
}

/// Represents a Dart class or a collection of top-level methods and properties.
final class Class extends _Node<internal.ClassDecl>
    with
        _Visitable,
        _HasVisitableChildren,
        _Renamable,
        _Excludable,
        _HasModifiers {
  @meta.internal
  Class(super._internalNode, this._properties, this._methods) {
    for (final property in _properties.values) {
      property.enclosingClass = this;
    }
    for (final method in _methods.values) {
      method.enclosingClass = this;
    }
  }

  /// The [DartFile] that this class is a part of.
  late final DartFile enclosingFile;

  /// The outer class of this class or `null` if this class is not nested.
  late final Class? enclosingClass;

  /// Map from name to field.
  ///
  /// The entries are ordered the same way as [internal.ClassDecl.fields].
  final Map<String, Property> _properties;

  /// Map from (name + signature) to method.
  ///
  /// The entries are ordered the same way as [internal.ClassDecl.methods].
  final Map<String, Method> _methods;

  Iterable<Property> get properties => _properties.values;
  Iterable<Method> get methods => _methods.values;

  /// The programming language of origin.
  Language get language {
    return _internalNode.kotlinClass != null ||
            _internalNode.kotlinPackage != null
        ? Language.kotlin
        : Language.java;
  }

  /// The original declaration type of this class.
  DeclKind get kind {
    if (_internalNode.kotlinPackage != null) return DeclKind.packageKind;
    return switch (_internalNode.declKind) {
      internal.DeclKind.classKind => DeclKind.classKind,
      internal.DeclKind.interfaceKind => DeclKind.interfaceKind,
      internal.DeclKind.enumKind => DeclKind.enumKind,
    };
  }

  /// Whether the class is actually only a number of top-level functions
  /// and properties.
  bool get isTopLevel => _internalNode.isTopLevel;

  set isTopLevel(bool isTopLevel) {
    _internalNode.isTopLevel = isTopLevel;
  }

  @override
  void accept(Visitor visitor) {
    visitor.visitClass(this);
  }

  @override
  void visitChildren(Visitor visitor) {
    for (final method in methods) {
      method.accept(visitor);
    }
    for (final property in properties) {
      property.accept(visitor);
    }
  }

  @override
  bool isNameAllowed(String name) {
    return _validDartIdentifier.hasMatch(name) &&
        !_disallowedAsClassName.contains(name) &&
        !_keywords.contains(name);
  }

  @override
  String get identifier => _internalNode.binaryName;

  @override
  String toString() => identifier;
}

/// Represents a logical property, which may have a getter, a setter, or both.
final class Property extends _Node<internal.Field>
    with _Visitable, _Renamable, _Excludable, _HasModifiers {
  @meta.internal
  Property(super._internalNode);

  late final Class enclosingClass;

  @override
  void accept(Visitor visitor) {
    visitor.visitProperty(this);
  }

  @override
  bool isNameAllowed(String name) {
    if (enclosingClass.kind == DeclKind.interfaceKind &&
        _disallowedInInterface.contains(name)) {
      return false;
    }
    return _validDartIdentifier.hasMatch(name) && !_keywords.contains(name);
  }

  @override
  String get identifier => originalName;

  @override
  String toString() => identifier;
}

/// Represents a Dart method.
final class Method extends _Node<internal.Method>
    with
        _Visitable,
        _HasVisitableChildren,
        _Renamable,
        _Excludable,
        _HasModifiers {
  @meta.internal
  Method(super._internalNode, this.parameters) {
    for (final param in parameters) {
      param.enclosingMethod = this;
    }
  }

  late final Class enclosingClass;
  final UnmodifiableListView<MethodParameter> parameters;

  @override
  void accept(Visitor visitor) {
    visitor.visitMethod(this);
  }

  @override
  void visitChildren(Visitor visitor) {
    for (final parameter in parameters) {
      parameter.accept(visitor);
    }
  }

  @override
  bool isNameAllowed(String name) {
    if (enclosingClass.kind == DeclKind.interfaceKind &&
        _disallowedInInterface.contains(name)) {
      return false;
    }
    return _validDartIdentifier.hasMatch(name) && !_keywords.contains(name);
  }

  @override
  String get identifier => _internalNode.javaSig;

  @override
  String toString() => identifier;
}

/// Represents a parameter of a [Method].
final class MethodParameter extends _Node<internal.Param>
    with _Visitable, _Renamable {
  @meta.internal
  MethodParameter(super._internalNode);

  late final Method enclosingMethod;

  @override
  void accept(Visitor visitor) {
    visitor.visitMethodParameter(this);
  }

  @override
  bool isNameAllowed(String name) {
    return _validDartIdentifier.hasMatch(name) && !_keywords.contains(name);
  }

  @override
  String get identifier =>
      _internalNode.method.params.indexOf(_internalNode).toString();
}
