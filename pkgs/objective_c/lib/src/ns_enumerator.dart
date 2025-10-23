// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'internal.dart';
import 'objective_c_bindings_generated.dart';

class _NSEnumeratorAdapter implements Iterator<ObjCObjectBase> {
  final NSEnumerator enumerator;
  ObjCObjectBase? _current;

  _NSEnumeratorAdapter(this.enumerator);

  @override
  ObjCObjectBase get current => _current!;

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() {
    _current = enumerator.nextObject();
    return _current != null;
  }
}

extension NSEnumeratorToAdapter on NSEnumerator {
  /// Wraps this [NSEnumerator] in an adapter that implements [Iterator].
  Iterator<ObjCObjectBase> toDart() => _NSEnumeratorAdapter(this);
}
