// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config/config.dart';
import '../elements/elements.dart';
import '../logging/logging.dart';
import 'visitor.dart';

class _Allowed {
  static const none = 0;
  static const fields = 1 << 0;
  static const methods = 1 << 1;
  static const classes = 1 << 2;
  static const all = fields | methods | classes;
}

enum _ElementKind {
  field,
  method,
  klass;

  bool isAllowed(String identifier) {
    return 1 << index & (_keywords[identifier] ?? _Allowed.all) != 0;
  }
}

const _keywords = {
  'abstract': _Allowed.fields | _Allowed.methods,
  'assert': _Allowed.none,
  'await': _Allowed.none, // Cannot be used in async context
  'break': _Allowed.none,
  'case': _Allowed.none,
  'catch': _Allowed.none,
  'class': _Allowed.none,
  'const': _Allowed.none,
  'continue': _Allowed.none,
  'covariant': _Allowed.fields | _Allowed.methods,
  'default': _Allowed.none,
  'deferred': _Allowed.fields | _Allowed.methods,
  'do': _Allowed.none,
  'dynamic': _Allowed.fields | _Allowed.methods,
  'else': _Allowed.none,
  'enum': _Allowed.none,
  'export': _Allowed.fields | _Allowed.methods,
  'extends': _Allowed.none,
  'extension': _Allowed.fields | _Allowed.methods,
  'external': _Allowed.fields | _Allowed.methods,
  'factory': _Allowed.fields | _Allowed.fields,
  'false': _Allowed.none,
  'final': _Allowed.none,
  'finally': _Allowed.none,
  'for': _Allowed.none,
  'Function': _Allowed.fields | _Allowed.methods,
  'if': _Allowed.none,
  'implements': _Allowed.fields | _Allowed.methods,
  'import': _Allowed.methods,
  'in': _Allowed.none,
  'interface': _Allowed.fields | _Allowed.methods,
  'is': _Allowed.none,
  'late': _Allowed.fields | _Allowed.methods,
  'library': _Allowed.fields | _Allowed.methods,
  'mixin': _Allowed.fields | _Allowed.methods,
  'new': _Allowed.none,
  'null': _Allowed.none,
  'operator': _Allowed.fields | _Allowed.methods,
  'part': _Allowed.fields | _Allowed.methods,
  'required': _Allowed.fields | _Allowed.methods,
  'rethrow': _Allowed.none,
  'return': _Allowed.none,
  'static': _Allowed.fields | _Allowed.methods,
  'super': _Allowed.none,
  'switch': _Allowed.none,
  'this': _Allowed.none,
  'throw': _Allowed.none,
  'true': _Allowed.none,
  'try': _Allowed.none,
  'typedef': _Allowed.fields | _Allowed.methods,
  'var': _Allowed.none,
  'void': _Allowed.none,
  'while': _Allowed.none,
  'with': _Allowed.none,
  'yield': _Allowed.none, // Cannot be used in async context
};

/// Methods & properties already defined by dart JObject base class.
///
/// If a second method or field has the same name, it will be appended by a
/// numeric suffix.
const Map<String, int> _definedSyms = {
  'as': 1,
  'fromReference': 1,
  'toString': 1,
  'hashCode': 1,
  'runtimeType': 1,
  'noSuchMethod': 1,
  'reference': 1,
  'isReleased': 1,
  'isNull': 1,
  'use': 1,
  'release': 1,
  'releasedBy': 1,
  'jClass': 1,
  'type': 1,
};

String _preprocess(String name) {
  // Replaces the `_` prefix with `$_` to prevent hiding public members in Dart.
  // For example `_foo` -> `$_foo`.
  String makePublic(String name) =>
      name.startsWith('_') ? '\$_${name.substring(1)}' : name;

  // Replaces each dollar sign with two dollar signs in [name].
  // For example `$foo$$bar$` -> `$$foo$$$$bar$$`.
  String doubleDollarSigns(String name) => name.replaceAll(r'$', r'$$');

  return makePublic(doubleDollarSigns(name));
}

/// Appends `$` to [name] if [name] is a Dart keyword.
///
/// Examples:
/// * `yield` -> `yield$`
/// * `foo` -> `foo`
String _keywordRename(String name, _ElementKind kind) =>
    kind.isAllowed(name) ? name : '$name\$';

String _renameConflict(
    Map<String, int> counts, String name, _ElementKind kind) {
  if (counts.containsKey(name)) {
    final count = counts[name]!;
    final renamed = '$name\$$count';
    counts[name] = count + 1;
    return renamed;
  }
  counts[name] = 1;
  return _keywordRename(name, kind);
}

class Renamer implements Visitor<Classes, void> {
  final Config config;

  Renamer(this.config);

  @override
  void visit(Classes node) {
    final classRenamer = _ClassRenamer(config);

    for (final classDecl in node.decls.values) {
      classDecl.accept(classRenamer);
    }
  }
}

class _ClassRenamer implements Visitor<ClassDecl, void> {
  final Config config;
  final Set<ClassDecl> renamed;
  final Map<String, int> topLevelNameCounts = {};
  final Map<ClassDecl, Map<String, int>> nameCounts = {};

  _ClassRenamer(
    this.config,
  ) : renamed = {...config.importedClasses.values};

  @override
  void visit(ClassDecl node) {
    if (renamed.contains(node)) return;
    log.finest('Renaming ${node.binaryName}.');
    renamed.add(node);

    nameCounts[node] = {..._definedSyms};
    if (node.declKind == DeclKind.interfaceKind) {
      nameCounts[node]!['implement'] = 1;
      nameCounts[node]!['implementIn'] = 1;
    }
    node.methodNumsAfterRenaming = {};

    final superClass = (node.superclass!.type as DeclaredType).classDecl;
    superClass.accept(this);
    nameCounts[node]!.addAll(nameCounts[superClass] ?? {});

    if (node.outerClass case final outerClass?) {
      outerClass.accept(this);
    }

    final outerClassName =
        node.outerClass == null ? '' : '${node.outerClass!.finalName}\$';
    final className =
        '$outerClassName${_preprocess(node.userDefinedName ?? node.name)}';

    // When generating all the classes in a single file
    // the names need to be unique.
    final uniquifyName =
        config.outputConfig.dartConfig.structure == OutputStructure.singleFile;
    node.finalName = uniquifyName
        ? _renameConflict(topLevelNameCounts, className, _ElementKind.klass)
        : className;
    node.typeClassName = '\$${node.finalName}\$Type';
    node.nullableTypeClassName = '\$${node.finalName}\$NullableType';
    node.userDefinedName == null
        ? log.fine('Class ${node.binaryName} is named ${node.finalName}')
        : log.warning(
            'Class ${node.userDefinedName} is named ${node.finalName}');

    // Rename fields before renaming methods. In case a method and a field have
    // identical names, the field will keep its original name and the
    // method will be renamed.
    final fieldRenamer = _FieldRenamer(
      config,
      uniquifyName && node.isTopLevel ? topLevelNameCounts : nameCounts[node]!,
    );
    for (final field in node.fields) {
      field.accept(fieldRenamer);
    }

    final methodRenamer = _MethodRenamer(
      config,
      uniquifyName && node.isTopLevel ? topLevelNameCounts : nameCounts[node]!,
    );
    for (final method in node.methods) {
      method.accept(methodRenamer);
    }
  }
}

class _MethodRenamer implements Visitor<Method, void> {
  _MethodRenamer(this.config, this.nameCounts);

  final Config config;
  final Map<String, int> nameCounts;

  @override
  void visit(Method node) {
    final name = _preprocess(
        node.isConstructor ? 'new' : node.userDefinedName ?? node.name);
    final sig = node.javaSig;
    // If node is in super class, assign its number, overriding it.
    final superClass =
        (node.classDecl.superclass!.type as DeclaredType).classDecl;
    final superNum = superClass.methodNumsAfterRenaming[sig];
    if (superNum != null) {
      // Don't rename if superNum == 0
      // Unless the node name is a keyword.
      final superNumText = superNum == 0 ? '' : '$superNum';
      final methodName =
          superNum == 0 ? _keywordRename(name, _ElementKind.method) : name;
      node.finalName = '$methodName$superNumText';
      node.classDecl.methodNumsAfterRenaming[sig] = superNum;
    } else {
      node.finalName = _renameConflict(nameCounts, name, _ElementKind.method);
      node.classDecl.methodNumsAfterRenaming[sig] = nameCounts[name]! - 1;
    }
    node.userDefinedName == null
        ? log.fine('Method ${node.classDecl.binaryName}#${node.name}'
            ' is named ${node.finalName}')
        : log.warning('Method ${node.userDefinedName}'
            ' is named ${node.finalName}');

    final paramRenamer = _ParamRenamer(config);
    for (final param in node.params) {
      param.accept(paramRenamer);
    }
  }
}

class _FieldRenamer implements Visitor<Field, void> {
  _FieldRenamer(this.config, this.nameCounts);

  final Config config;
  final Map<String, int> nameCounts;

  @override
  void visit(Field node) {
    final fieldName = _preprocess(node.userDefinedName ?? node.name);
    node.finalName = _renameConflict(nameCounts, fieldName, _ElementKind.field);
    node.userDefinedName == null
        ? log.fine('Field ${node.classDecl.binaryName}#${node.name}'
            ' is named ${node.finalName}')
        : log.warning('Field ${node.userDefinedName}'
            ' is named ${node.finalName}');
  }
}

class _ParamRenamer implements Visitor<Param, void> {
  _ParamRenamer(this.config);

  final Config config;

  @override
  void visit(Param node) {
    node.finalName =
        _keywordRename(node.userDefinedName ?? node.name, _ElementKind.field);
  }
}
