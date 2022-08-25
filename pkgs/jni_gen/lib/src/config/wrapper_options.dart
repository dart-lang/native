// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/src/elements/elements.dart';

/// A filter which tells if bindings for given [ClassDecl] are generated.
abstract class ClassFilter {
  bool included(ClassDecl decl);
}

/// This filter includes the declarations for which [predicate] returns true.
class CustomClassFilter implements ClassFilter {
  CustomClassFilter(this.predicate);
  final bool Function(ClassDecl) predicate;
  @override
  bool included(ClassDecl decl) {
    return predicate(decl);
  }
}

bool _matchesCompletely(String string, Pattern pattern) {
  final match = pattern.matchAsPrefix(string);
  return match != null && match.group(0) == string;
}

/// Filter to include / exclude classes by matching on the binary name.
/// A binary name is like qualified name but with a `$` used to indicate nested
/// class instead of `.`, guaranteeing a unique name.
class ClassNameFilter implements ClassFilter {
  ClassNameFilter.include(this.pattern) : onMatch = true;
  ClassNameFilter.exclude(this.pattern) : onMatch = false;
  final bool onMatch;
  final Pattern pattern;
  @override
  bool included(ClassDecl decl) {
    if (_matchesCompletely(decl.binaryName, pattern)) {
      return onMatch;
    }
    return !onMatch;
  }
}

abstract class MemberFilter<T extends ClassMember> {
  bool included(ClassDecl classDecl, T member);
}

class MemberNameFilter<T extends ClassMember> implements MemberFilter<T> {
  MemberNameFilter.include(this.classPattern, this.namePattern)
      : onMatch = true;
  MemberNameFilter.exclude(this.classPattern, this.namePattern)
      : onMatch = false;
  final bool onMatch;
  final Pattern classPattern, namePattern;
  @override
  bool included(ClassDecl classDecl, T member) {
    final matches = _matchesCompletely(classDecl.binaryName, classPattern) &&
        _matchesCompletely(member.name, namePattern);
    return matches ? onMatch : !onMatch;
  }
}

class CustomMemberFilter<T extends ClassMember> implements MemberFilter<T> {
  CustomMemberFilter(this.predicate);
  bool Function(ClassDecl, T) predicate;
  @override
  bool included(ClassDecl classDecl, T member) => predicate(classDecl, member);
}

class CombinedClassFilter implements ClassFilter {
  CombinedClassFilter.all(this.filters);
  final List<ClassFilter> filters;
  @override
  bool included(ClassDecl decl) => filters.every((f) => f.included(decl));
}

class CombinedMemberFilter<T extends ClassMember> implements MemberFilter<T> {
  CombinedMemberFilter(this.filters);

  final List<MemberFilter<T>> filters;

  @override
  bool included(ClassDecl decl, T member) {
    return filters.every((f) => f.included(decl, member));
  }
}

typedef FieldFilter = MemberFilter<Field>;
typedef MethodFilter = MemberFilter<Method>;

/// Filter using binary name of the class and name of the field.
typedef FieldNameFilter = MemberNameFilter<Field>;

/// Filter using binary name of the class and name of the method.
typedef MethodNameFilter = MemberNameFilter<Method>;

/// Predicate based filter for field, which can access class declaration
/// and the field.
typedef CustomFieldFilter = CustomMemberFilter<Field>;

/// Predicate based filter for method, which can access class declaration
/// and the method.
typedef CustomMethodFilter = CustomMemberFilter<Method>;

/// This filter excludes fields if any one of sub-filters returns false.
typedef CombinedFieldFilter = CombinedMemberFilter<Field>;

/// This filter excludes methods if any one of sub-filters returns false.
typedef CombinedMethodFilter = CombinedMemberFilter<Method>;

MemberFilter<T> excludeAll<T extends ClassMember>(List<List<Pattern>> names) {
  return CombinedMemberFilter<T>(
      names.map((p) => MemberNameFilter<T>.exclude(p[0], p[1])).toList());
}

/// Options that affect the semantics of the generated code.
class WrapperOptions {
  const WrapperOptions({
    this.classFilter,
    this.fieldFilter,
    this.methodFilter,
    this.classTransformer,
    this.methodTransformer,
    this.fieldTransformer,
    this.importPaths = const {},
  });

  /// Mapping from java package names to dart packages.
  /// A mapping `a.b` -> `package:a_b/' means that
  /// any import `a.b.C` will be resolved as `package:a_b/a/b.dart` in dart.
  /// Note that dart bindings use the same hierarchy as the java packages.
  final Map<String, String> importPaths;

  /// [ClassFilter] to decide if bindings for a class should be generated.
  final ClassFilter? classFilter;

  /// [FieldFilter] to decide if bindings for a field should be generated.
  final FieldFilter? fieldFilter;

  /// [MethodFilter] to decide if bindings for a method should be generated.
  final MethodFilter? methodFilter;

  // TODO(#26): This allows us to implement flexible renaming and more customization
  // via the dart API.
  final ClassDecl? Function(ClassDecl decl)? classTransformer;
  final Method? Function(Method method)? methodTransformer;
  final Field? Function(Field field)? fieldTransformer;
}
