// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import '../jobject.dart';
import '../jreference.dart';
import '../types.dart';

@internal
final class $JIterator$Type$ extends JType<JIterator> {
  const $JIterator$Type$();

  @override
  String get signature => r'Ljava/util/Iterator;';
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
  static const JType<JIterator> type = JType(r'Ljava/util/Iterator;');

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
