
import 'dart:ffi' as ffi;
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/objc_interface.dart';
import 'package:ffigen/src/code_generator/objc_methods.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/header_parser/clang_bindings/clang_bindings.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('Deprecation Codegen', () {
    late Context context;

    setUp(() {
      // Set a dummy clang to bypass libclang loading.
      clang = Clang.fromLookup(<T extends ffi.NativeType>(String name) {
        return ffi.Pointer<ffi.Void>.fromAddress(0).cast<T>();
      });

      final ffiGen = FfiGenerator(
        output: Output(dartFile: Uri.file('unused.dart')),
        headers: Headers(entryPoints: [Uri.file('unused.h')]),
        functions: Functions.includeAll,
        structs: Structs.includeAll,
        enums: Enums.includeAll,
        typedefs: Typedefs.includeAll,
        objectiveC: const ObjectiveC(
          interfaces: Interfaces.includeAll,
          protocols: Protocols.includeAll,
          categories: Categories.includeAll,
        ),
      );
      context = Context(Logger('test'), ffiGen);
    });

    test('func_deprecated', () {
      final func = Func(
        name: 'func_deprecated',
        returnType: voidType,
        originalName: 'func_deprecated',
      )..deprecatedMessage = 'Deprecated';
      
      final library = Library(
        context: context,
        bindings: [func],
      );
      library.forceFillNamesForTesting();

      final generated = library.generate();
      expect(generated, contains('@Deprecated("Deprecated")'));
      expect(generated, contains('void func_deprecated()'));
    });

    test('struct_deprecated', () {
      final struct = Struct(
        name: 'DeprecatedStruct',
        context: context,
      )..deprecatedMessage = 'struct deprecated';

      final library = Library(
        context: context,
        bindings: [struct],
      );
      library.forceFillNamesForTesting();

      final generated = library.generate();
      expect(generated, contains('@Deprecated("struct deprecated")'));
      expect(generated, contains('final class DeprecatedStruct extends ffi.Opaque'));
    });

    test('enum_deprecated', () {
      final enumClass = EnumClass(
        name: 'DeprecatedEnum',
        context: context,
      )..deprecatedMessage = 'enum deprecated';

      final library = Library(
        context: context,
        bindings: [enumClass],
      );
      library.forceFillNamesForTesting();

      final generated = library.generate();
      expect(generated, contains('@Deprecated("enum deprecated")'));
      expect(generated, contains('class DeprecatedEnum'));
    });

    test('typedef_deprecated', () {
      final typedef = Typealias(
        name: 'DeprecatedTypedef',
        type: intType,
      )..deprecatedMessage = 'typedef deprecated';

      final library = Library(
        context: context,
        bindings: [typedef],
      );
      library.forceFillNamesForTesting();

      final generated = library.generate();
      expect(generated, contains('@Deprecated("typedef deprecated")'));
      expect(generated, contains('typedef DeprecatedTypedef = ffi.Int;'));
    });

    test('objc_interface_deprecated', () {
      final itf = ObjCInterface(
        originalName: 'DeprecatedInterface',
        apiAvailability: ApiAvailability(
          alwaysDeprecated: true,
          deprecatedMessage: 'interface deprecated',
          externalVersions: null,
        ),
        context: context,
      );

      final library = Library(
        context: context,
        bindings: [itf],
      );
      library.forceFillNamesForTesting();

      final generated = library.generate();
      expect(generated, contains('@Deprecated("interface deprecated")'));
      expect(generated, contains('extension type DeprecatedInterface'));
    });

    test('objc_method_deprecated', () {
      final itf = ObjCInterface(
        originalName: 'InterfaceWithDeprecatedMethod',
        apiAvailability: ApiAvailability(externalVersions: null),
        context: context,
      );
      final method = ObjCMethod(
        context: context,
        originalName: 'deprecatedMethod',
        name: 'deprecatedMethod',
        kind: ObjCMethodKind.method,
        isClassMethod: false,
        isOptional: false,
        returnType: voidType,
        params: [],
        family: null,
        apiAvailability: ApiAvailability(
          alwaysDeprecated: true,
          deprecatedMessage: 'method deprecated',
          externalVersions: null,
        ),
        ownershipAttribute: null,
        consumesSelfAttribute: false,
        deprecatedMessage: 'method deprecated',
      );
      itf.addMethod(method);

      // We need to fill the method's msgSend to avoid late initialization error during generation
      method.msgSend = context.objCBuiltInFunctions.getMsgSendFunc(voidType, []);

      final library = Library(
        context: context,
        bindings: [itf],
      );
      library.forceFillNamesForTesting();

      final generated = library.generate();
      expect(generated, contains('@Deprecated("method deprecated")'));
      expect(generated, contains('void deprecatedMethod()'));
    });
  });
}
