// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

@internal
final class $JIterator$NullableType$<$E extends JObject?>
    extends JType<JIterator<$E>?> {
  final JType<$E> E;

  const $JIterator$NullableType$(
    this.E,
  );

  @override
  String get signature => r'Ljava/util/Iterator;';

  @override
  JIterator<$E>? fromReference(JReference reference) =>
      reference.isNull ? null : JIterator<$E>.fromReference(E, reference);

  @override
  JType get superType => const $JObject$NullableType$();

  @override
  JType<JIterator<$E>?> get nullableType => this;

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash($JIterator$NullableType$, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JIterator$NullableType$<$E>) &&
        other is $JIterator$NullableType$<$E> &&
        E == other.E;
  }
}

@internal
final class $JIterator$Type$<$E extends JObject?> extends JType<JIterator<$E>> {
  final JType<$E> E;

  const $JIterator$Type$(
    this.E,
  );

  @override
  String get signature => r'Ljava/util/Iterator;';

  @override
  JIterator<$E> fromReference(JReference reference) =>
      JIterator<$E>.fromReference(E, reference);

  @override
  JType get superType => const $JObject$Type$();

  @override
  JType<JIterator<$E>?> get nullableType => $JIterator$NullableType$<$E>(E);

  @override
  final superCount = 1;

  @override
  int get hashCode => Object.hash($JIterator$Type$, E);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($JIterator$Type$<$E>) &&
        other is $JIterator$Type$<$E> &&
        E == other.E;
  }
}

class JIterator<$E extends JObject?> extends JObject implements Iterator<$E> {
  @internal
  @override
  // ignore: overridden_fields
  final JType<JIterator<$E>> $type;

  @internal
  final JType<$E> E;

  JIterator.fromReference(
    this.E,
    JReference reference,
  )   : $type = type<$E>(E),
        super.fromReference(reference);

  static final _class = JClass.forName(r'java/util/Iterator');

  /// The type which includes information such as the signature of this class.
  static JType<JIterator<$E>> type<$E extends JObject?>(
    JType<$E> E,
  ) {
    return $JIterator$Type$<$E>(E);
  }

  /// The type which includes information such as the signature of this class.
  static JType<JIterator<$E>?> nullableType<$E extends JObject?>(
    JType<$E> E,
  ) {
    return $JIterator$NullableType$<$E>(E);
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
