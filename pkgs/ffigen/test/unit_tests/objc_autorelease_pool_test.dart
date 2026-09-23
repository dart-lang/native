// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/header_parser/parser.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('ObjectiveC autorelease pool code generation', () {
    final availability = ApiAvailability(
      externalVersions: const ExternalVersions(),
    );
    final intType = NativeType(SupportedNativeType.int32);
    final instanceType = Typealias(
      name: 'instancetype',
      type: ObjCObjectPointer(),
    );

    String generateBindings() {
      final config = FfiGenerator(
        output: Output(
          dart: DartOutput(path: Uri.file('unused.dart')),
          style: const DynamicLibraryBindings(wrapperName: 'TestBindings'),
        ),
        objectiveC: const ObjectiveC(),
      );
      final context = testContext(config);

      final itf = ObjCInterface(
        context: context,
        usr: 'TestClass',
        originalName: 'TestClass',
        apiAvailability: availability,
      )..isIncluded = true;

      // Instance method returning int
      itf.addMethod(
        ObjCMethod(
          context: context,
          originalName: 'addNumber:',
          name: 'addNumber',
          kind: ObjCMethodKind.method,
          isClassMethod: false,
          isOptional: false,
          returnType: intType,
          family: null,
          apiAvailability: availability,
          params: [Parameter(name: 'num', type: intType, objCConsumed: false)],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        ),
      );

      // Void instance method
      itf.addMethod(
        ObjCMethod(
          context: context,
          originalName: 'reset',
          name: 'reset',
          kind: ObjCMethodKind.method,
          isClassMethod: false,
          isOptional: false,
          returnType: voidType,
          family: null,
          apiAvailability: availability,
          params: [],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        ),
      );

      // Class method returning an object
      itf.addMethod(
        ObjCMethod(
          context: context,
          originalName: 'createObject',
          name: 'createObject',
          kind: ObjCMethodKind.method,
          isClassMethod: true,
          isOptional: false,
          returnType: instanceType,
          family: null,
          apiAvailability: availability,
          params: [],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        ),
      );

      // Property getter and setter
      final propGetter = ObjCMethod(
        context: context,
        originalName: 'count',
        name: 'count',
        kind: ObjCMethodKind.propertyGetter,
        isClassMethod: false,
        isOptional: false,
        returnType: intType,
        family: null,
        apiAvailability: availability,
        params: [],
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      final propSetter = ObjCMethod.withSymbol(
        context: context,
        originalName: 'setCount:',
        symbol: propGetter.symbol,
        protocolMethodName: 'setCount:',
        kind: ObjCMethodKind.propertySetter,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        params: [Parameter(name: 'value', type: intType, objCConsumed: false)],
        family: null,
        apiAvailability: availability,
        ownershipAttribute: null,
        consumesSelfAttribute: false,
      );
      propGetter.setter = propSetter;
      itf.addMethod(propGetter);
      itf.addMethod(propSetter);

      // Struct return method (stret)
      final testStruct = Struct(
        context: context,
        name: 'TestStruct',
        members: [CompoundMember(name: 'a', type: intType)],
      );
      itf.addMethod(
        ObjCMethod(
          context: context,
          originalName: 'getStruct',
          name: 'getStruct',
          kind: ObjCMethodKind.method,
          isClassMethod: false,
          isOptional: false,
          returnType: testStruct,
          family: null,
          apiAvailability: availability,
          params: [],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        ),
      );

      // Method throwing NSError by out-parameter
      final nsErrorItf = ObjCInterface(
        context: context,
        usr: 'NSError',
        originalName: 'NSError',
        apiAvailability: availability,
      );
      itf.addMethod(
        ObjCMethod(
          context: context,
          originalName: 'doActionWithError:',
          name: 'doActionWithError',
          kind: ObjCMethodKind.method,
          isClassMethod: false,
          isOptional: false,
          returnType: BooleanType(),
          family: null,
          apiAvailability: availability,
          params: [
            Parameter(
              name: 'error',
              originalName: 'error',
              type: PointerType(nsErrorItf),
              objCConsumed: false,
            ),
          ],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        ),
      );

      itf.filled = true;

      // Block
      final block = ObjCBlock(
        context,
        returnType: intType,
        params: [Parameter(name: 'x', type: intType, objCConsumed: false)],
        returnsRetained: false,
      );

      // Protocol
      final proto = ObjCProtocol(
        context: context,
        usr: 'TestProtocol',
        originalName: 'TestProtocol',
        apiAvailability: availability,
      )..isIncluded = true;
      proto.addMethod(
        ObjCMethod(
          context: context,
          originalName: 'protoMethod',
          name: 'protoMethod',
          kind: ObjCMethodKind.method,
          isClassMethod: false,
          isOptional: false,
          returnType: voidType,
          family: null,
          apiAvailability: availability,
          params: [],
          ownershipAttribute: null,
          consumesSelfAttribute: false,
        ),
      );

      final bindings = transformBindings([
        itf,
        testStruct,
        block,
        proto,
      ], context);
      final library = Library.fromContext(bindings: bindings, context: context);
      return library.generate();
    }

    test('unconditionally wraps in autoReleasePool', () {
      final code = generateBindings();

      // Verify import of package:objective_c is present
      expect(
        code,
        contains("import 'package:objective_c/objective_c.dart' as objc;"),
      );

      // Verify instance method returning int
      expect(
        code,
        contains(
          'int addNumber(int num) {\n'
          'final _\$\$ref = object\$.ref;'
          '    return objc.autoReleasePool(() {\n'
          '      return _objc_msgSend_',
        ),
      );

      // Verify void instance method (no return before autoReleasePool)
      expect(
        code,
        contains(
          'void reset() {\n'
          'final _\$\$ref = object\$.ref;'
          '    objc.autoReleasePool(() {\n'
          '      _objc_msgSend_',
        ),
      );

      // Verify static class method returning an object
      expect(
        code,
        contains(
          'static TestClass createObject() {\n'
          '    return objc.autoReleasePool(() {\n'
          '      final \$ret = _objc_msgSend_',
        ),
      );

      // Verify getter
      expect(
        code,
        contains(
          'int get count {\n'
          'final _\$\$ref = object\$.ref;'
          '    return objc.autoReleasePool(() {\n'
          '      return _objc_msgSend_',
        ),
      );

      // Verify setter (must not return a value)
      expect(
        code,
        contains(
          'set count(int value) {\n'
          'final _\$\$ref = object\$.ref;    objc.autoReleasePool(() {\n'
          '      _objc_msgSend_',
        ),
      );

      // Verify stret (struct return) method
      expect(
        code,
        contains(
          'TestStruct getStruct() {\n'
          'final _\$\$ref = object\$.ref;'
          '    return objc.autoReleasePool(() {\n'
          '      final \$ptr = pkg_ffi.calloc<TestStruct>();',
        ),
      );

      // Verify method throwing NSError (autoReleasePool inside try block)
      expect(
        code,
        contains(
          'bool doActionWithError() {\n'
          'final _\$\$ref = object\$.ref;'
          '    final \$err = '
          'pkg_ffi.calloc<ffi.Pointer<objc.ObjCObjectImpl>>();\n'
          '    try {\n'
          '    return objc.autoReleasePool(() {\n'
          '      final \$ret = _objc_msgSend_',
        ),
      );

      // Verify ObjCBlock call extension
      expect(
        code,
        contains('objc.autoReleasePool(() => ref.pointer.ref.invoke'),
      );

      // Verify isA on interface
      expect(
        code,
        contains(
          'static bool isA(objc.ObjCObject? obj) => obj == null\n'
          '      ? false\n'
          '      : objc.autoReleasePool(() => _objc_msgSend_',
        ),
      );

      // Verify conformsTo on protocol
      expect(
        code,
        contains(
          'static bool conformsTo(objc.ObjCObject obj) {\n'
          '    return objc.autoReleasePool(() => _objc_msgSend_',
        ),
      );
    });
  });
}
