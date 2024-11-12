// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

final class JIteratorNullableType<$E extends JObject?>
    extends JObjType<JIterator<$E>?> {
  @internal
  final JObjType<$E> E;

  @internal
  const JIteratorNullableType(
    this.E,
  );

  @internal
  @override
  String get signature => r'Ljava/util/Iterator;';

  @internal
  @override
  JIterator<$E>? fromReference(JReference reference) =>
      reference.isNull ? null : JIterator<$E>.fromReference(E, reference);

  @internal
  @override
  JObjType get superType => const JObjectNullableType();

  @internal
  @override
  JObjType<JIterator<$E>?> get nullableType => this;

  @internal
  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash(JIteratorNullableType, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JIteratorNullableType<$E>) &&
        other is JIteratorNullableType<$E> &&
        E == other.E;
  }
}

final class JIteratorType<$E extends JObject?> extends JObjType<JIterator<$E>> {
  @internal
  final JObjType<$E> E;

  @internal
  const JIteratorType(
    this.E,
  );

  @internal
  @override
  String get signature => r'Ljava/util/Iterator;';

  @internal
  @override
  JIterator<$E> fromReference(JReference reference) =>
      JIterator<$E>.fromReference(E, reference);

  @internal
  @override
  JObjType get superType => const JObjectType();

  @internal
  @override
  JObjType<JIterator<$E>?> get nullableType => JIteratorNullableType<$E>(E);

  @internal
  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash(JIteratorType, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JIteratorType<$E>) &&
        other is JIteratorType<$E> &&
        E == other.E;
  }
}

class JIterator<$E extends JObject?> extends JObject implements Iterator<$E> {
  @internal
  @override
  // ignore: overridden_fields
  final JObjType<JIterator<$E>> $type;

  @internal
  final JObjType<$E> E;

  JIterator.fromReference(
    this.E,
    JReference reference,
  )   : $type = type<$E>(E),
        super.fromReference(reference);

  static final _class = JClass.forName(r'java/util/Iterator');

  /// The type which includes information such as the signature of this class.
  static JIteratorType<$E> type<$E extends JObject?>(
    JObjType<$E> E,
  ) {
    return JIteratorType<$E>(E);
  }

  /// The type which includes information such as the signature of this class.
  static JIteratorNullableType<$E> nullableType<$E extends JObject?>(
    JObjType<$E> E,
  ) {
    return JIteratorNullableType<$E>(E);
  }

  $E? _current;

  @override
  $E get current => _current as $E;

  static final _hasNextId = _class.instanceMethodId(r'hasNext', r'()Z');
  bool _hasNext() {
    return _hasNextId(this, const jbooleanType(), [])!;
  }

  static final _nextId =
      _class.instanceMethodId(r'next', r'()Ljava/lang/Object;');
  $E _next() {
    return _nextId(this, E, [])!;
  }

  @override
  bool moveNext() {
    if (!_hasNext()) {
      return false;
    }
    _current = _next();
    return true;
  }
}
