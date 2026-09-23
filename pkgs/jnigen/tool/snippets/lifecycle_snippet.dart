// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_dynamic_calls, avoid_print
// ignore_for_file: non_constant_identifier_names, omit_local_variable_types
// ignore_for_file: unused_local_variable

import 'package:jni/jni.dart';

dynamic JList;

class Foo {
  Bar? bar;

  JString someJString() => throw UnimplementedError();

  JObject someJNumber() => throw UnimplementedError();

  void release() {}
}

class Bar {
  Bar._();

  factory Bar.implement($Bar impl) => Bar._();
}

abstract base mixin class $Bar {
  factory $Bar({required Foo Function() f}) = _BarImpl;

  Foo f();
}

final class _BarImpl with $Bar {
  final Foo Function() _f;

  _BarImpl({required Foo Function() f}) : _f = f;

  @override
  Foo f() => _f();
}

void releaseManualExample() {
  // snippet-start#release_manual
  // Construct the object.
  final hello = 'Hello'.toJString();
  // Use it.
  print(hello);
  // Eagerly release it!
  hello.release();
  // snippet-end#release_manual
}

void arenaUsingExample() {
  // snippet-start#arena_using
  using((arena) {
    final hello = 'Hello'.toJString()..releasedBy(arena);
    final world = 'World'.toJString()..releasedBy(arena);
    print(hello);
    print(world);
  });
  // Both `hello` and `world` are now released.
  // snippet-end#arena_using
}

void javaCollectionsExample() {
  // snippet-start#java_collections
  // GOOD:
  final jstrings = JList(JString.type);
  using((arena) {
    final hello = 'Hello'.toJString()..releasedBy(arena);
    final world = 'World'.toJString()..releasedBy(arena);
    jstrings.add(hello); // Add to Java collection
    jstrings.add(world); // Add to Java collection
  });
  print(jstrings.length); // prints 2.
  // snippet-end#java_collections
}

void releaseOriginalExample() {
  // snippet-start#release_original
  final foo = Foo();
  final String string = foo.someJString().toDartString(releaseOriginal: true);
  final JInteger jint =
      foo.someJNumber().as(JInteger.type, releaseOriginal: true);
  final int dartInt = jint.toDartInt(releaseOriginal: true);
  foo.release();
  // All references are removed.
  // snippet-end#release_original
}

void cycleExample() {
  // snippet-start#cycle
  final foo = Foo();
  foo.bar = Bar.implement($Bar(
    f: () {
      return foo;
    },
  ));
  // snippet-end#cycle
}

void cycleBreakerExample() {
  final foo = Foo();
  // snippet-start#cycle_breaker
  final weakFoo = WeakReference(foo);
  foo.bar = Bar.implement($Bar(
    f: () {
      final foo = weakFoo.target;
      if (foo == null) {
        throw StateError('Foo was collected');
      }
      return foo;
    },
  ));
  // snippet-end#cycle_breaker
}

// snippet-start#cycle_breaker_class
final class BarImpl with $Bar {
  final WeakReference<Foo> weakFoo;

  BarImpl(this.weakFoo);

  @override
  Foo f() {
    final foo = weakFoo.target;
    if (foo == null) {
      throw StateError('Foo was collected');
    }
    return foo;
  }
}

void cycleBreakerClassMain(Foo foo) {
  final weakFoo = WeakReference(foo);
  foo.bar = Bar.implement(BarImpl(weakFoo));
  // ...
}
// snippet-end#cycle_breaker_class
