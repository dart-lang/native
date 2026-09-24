// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unreachable_from_main
// ignore_for_file: unnecessary_lambdas, unused_local_variable

abstract class FooInterface {
  factory FooInterface() => _FooInterface();
  BarDelegate? get delegate;
  set delegate(BarDelegate? value);
  void anotherMethod();
}

class _FooInterface implements FooInterface {
  @override
  BarDelegate? delegate;
  @override
  void anotherMethod() {}
}

abstract class BarDelegate {
  static BarDelegate implement({required void Function() someMethod}) =>
      _BarDelegate(someMethod);
}

class _BarDelegate implements BarDelegate {
  final void Function() someMethod;
  _BarDelegate(this.someMethod);
}

void cycleExample() {
  // snippet-start#cycle
  final foo = FooInterface();
  foo.delegate = BarDelegate.implement(
    someMethod: () {
      foo.anotherMethod();
    },
  );
  // snippet-end#cycle
}

// snippet-start#weak_ref
BarDelegate createBarDelegate(WeakReference<FooInterface> weakFoo) {
  return BarDelegate.implement(
    someMethod: () {
      weakFoo.target?.anotherMethod();
    },
  );
}

void main() {
  final foo = FooInterface();
  foo.delegate = createBarDelegate(WeakReference(foo));
}
// snippet-end#weak_ref
