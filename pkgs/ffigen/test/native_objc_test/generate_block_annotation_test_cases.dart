// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

enum Type {
  object('Object', 'EmptyObject', 'EmptyObject.alloc().init()', 'objectRetainCount'),
  block('Block', 'DartEmptyBlock', 'ObjCBlock_ffiVoid.fromFunction(() {})', 'blockRetainCount');

  final String name;
  final String dartType;
  final String dartCtor;
  final String getRetainCount;

  const Type(this.name, this.dartType, this.dartCtor, this.getRetainCount);
 }

enum Definition { objC, fromFunction, listener }

enum Invocation { dart, objCSync, objCAsync }

abstract class Block {
  Type get type;
  String get name;
  String get dartType;
  String dartCtor(Definition definition);
  String invoke(Invocation invocation);
}

class Producer implements Block {
  @override
  final Type type;
  final bool retained;
  Producer(this.type, this.retained);

  @override
  String get name => '${retained ? 'Retained' : ''}${type.name}Producer';

  String get utilName => 'ObjCBlock_Empty${type.name}_ffiVoid${retained ? '1' : ''}';

  @override
  String get dartType {
    final rawRet = type.dartType;
    final ret = retained ? 'Retained<$rawRet>' : rawRet;
    return 'ObjCBlock<$ret Function(Pointer<Void>)>';
  }

  @override
  String dartCtor(Definition definition) {
    switch (definition) {
      case Definition.objC:
        var ctor = 'BlockAnnotationTest.new${name}()';
        if (retained) {
          ctor = '$dartType($ctor.pointer, retain: true, release: true)';
        }
        return ctor;
      case Definition.fromFunction:
        return '$utilName.fromFunction((Pointer<Void> _) => ${type.dartCtor})';
      default:
        throw UnsupportedError("Producers can't be listeners");
    }
  }

  @override
  String invoke(Invocation invocation) {
    switch (invocation) {
      case Invocation.dart:
        return '${type.dartType}? obj = blk(nullptr);';
      case Invocation.objCSync:
        var blk = 'blk';
        if (retained) {
          blk = '${Producer(type, false).dartType}($blk.pointer, retain: true, release: true)';
        }
        return '${type.dartType}? obj = BlockAnnotationTest.invoke${name}_($blk);';
      default:
        throw UnsupportedError("Producers can't be invoked asynchronously");
    }
  }
}

class Consumer implements Block {
  @override
  final Type type;
  bool consumed;
  Consumer(this.type, this.consumed);

  @override
  String get name => '${consumed ? 'Consumed' : ''}${type.name}Consumer';

  @override
  String get dartType {
    final rawArg = type.dartType;
    final arg = consumed ? 'Consumed<$rawArg>' : rawArg;
    return 'ObjCBlock<void Function($arg)>';
  }

  @override
  String dartCtor(Definition definition) {
    return "TODO";
  }

  @override
  String invoke(Invocation invocation) {
    return "TODO";
  }
}

final producers = [
  for (final type in Type.values)
    for (final retained in [false, true]) Producer(type, retained),
];

final consumers = [
  for (final type in Type.values)
    for (final consumed in [false, true]) Consumer(type, consumed),
];

final blocks = [...producers, ...consumers];

bool _isValidTest(Block blk, Definition def, Invocation inv) {
  if (blk is Producer && def == Definition.listener) return false;
  if (def != Definition.listener && inv == Invocation.objCAsync) return false;

  // TODO: Remove
  if (blk is Consumer) return false;

  return true;
}

final testCases = [
  for (final blk in blocks)
    for (final def in Definition.values)
      for (final inv in Invocation.values)
        if (_isValidTest(blk, def, inv)) TestCase(blk, def, inv),
];

class TestCase {
  Block block;
  Definition definition;
  Invocation invocation;
  TestCase(this.block, this.definition, this.invocation);

  String get name => '${block.name}, defined $definition, invoked $invocation';

  String generate() {
    return '''
    test('$name', () {
      final pool = lib.objc_autoreleasePoolPush();
      ${block.dartType} blk = ${block.dartCtor(definition)};
      ${block.invoke(invocation)}
      final ptr = obj.pointer;
      lib.objc_autoreleasePoolPop(pool);
      doGC();
      expect(${block.type.getRetainCount}(ptr), 1);
      expect(obj, isNotNull);
      obj = null;
      doGC();
      expect(${block.type.getRetainCount}(ptr), 0);
    });
''';
  }
}

String generate() {
  return '''
// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:objective_c/src/internal.dart' as internal_for_testing
    show blockHasRegisteredClosure;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'block_annotation_bindings.dart';
import 'util.dart';

void main() {
  late final BlockAnnotationTestLibrary lib;

  group('Block annotations', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/block_annotation_test.dylib');
      verifySetupFile(dylib);
      lib = BlockAnnotationTestLibrary(DynamicLibrary.open(dylib.absolute.path));

      generateBindingsForCoverage('block_annotation');
    });

${testCases.map((t) => t.generate()).join('\n\n')}
  });
}
''';
}

void main() {
  Directory.current = Platform.script.resolve('.').path;
  File('block_annotation_test.dart').writeAsStringSync(generate());
  Process.runSync('dart', ['format', 'block_annotation_test.dart']);
}
