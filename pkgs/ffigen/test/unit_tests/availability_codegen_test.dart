// ignore_for_file: lines_longer_than_80_chars

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/config_provider/config_types.dart';
import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/header_parser/sub_parsers/api_availability.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('Availability Codegen', () {
    late Context context;
    final voidType = NativeType(SupportedNativeType.voidType);
    
    setUp(() {
       final config = FfiGenerator(
        output: Output(dartFile: Uri.file('unused')),
        objectiveC: const ObjectiveC(
          interfaces: Interfaces.includeAll,
          categories: Categories.includeAll,
        ),
      );
      context = testContext(config);
    });

    ObjCInterface makeInterface(String name, {Version? ios, Version? macos}) {
      return ObjCInterface(
        context: context,
        usr: name,
        originalName: name,
        apiAvailability: ApiAvailability(
            externalVersions: null,
            ios: ios == null ? null : PlatformAvailability(name: 'ios', introduced: ios),
            macos: macos == null ? null : PlatformAvailability(name: 'macos', introduced: macos),
        ),
      );
    }

    test('Block with no availability Types', () {
      final block = ObjCBlock(
        context,
        returnType: voidType,
        params: [],
        returnsRetained: false,
      );
      // Force generating bindings
      block.hasListener; // ensure it thinks it has listener if needed, but ObjCBlock logic mostly checks returnType==void
      // Actually ObjCBlock constructor checks hasListener. 
      // void return type means hasListener is true.
      
      final binding = block.toObjCBindingString(Writer(context: context));
      expect(binding!.string, isNot(contains('API_AVAILABLE')));
    });

    test('Block with one restricted parameter', () {
      final ios12 = makeInterface('IOS12Class', ios: Version(12, 0, 0));
      final block = ObjCBlock(
        context,
        returnType: voidType,
        params: [Parameter(type: ios12, name: 'p1')],
        returnsRetained: false,
      );

      final binding = block.toObjCBindingString(Writer(context: context));
      expect(binding!.string, contains('API_AVAILABLE(ios(12.0.0))'));
    });
    
    test('Block with multiple restricted parameters (Max version)', () {
      final ios10 = makeInterface('IOS10Class', ios: Version(10, 0, 0));
      final ios12 = makeInterface('IOS12Class', ios: Version(12, 0, 0));
      
      final block = ObjCBlock(
        context,
        returnType: voidType,
        params: [
            Parameter(type: ios10, name: 'p1'),
            Parameter(type: ios12, name: 'p2'),
        ],
        returnsRetained: false,
      );

      final binding = block.toObjCBindingString(Writer(context: context));
      // Should pick max version (12.0)
      expect(binding!.string, contains('API_AVAILABLE(ios(12.0.0))'));
      expect(binding.string, isNot(contains('ios(10.0.0)')));
    });

    test('Block with restricted return type', () {
       // Note: ObjCBlock only has listeners (trampolines) if returnType is void.
       // Only void blocks generate trampolines where we put annotations?
       // Let's check ObjCBlock.dart logic. 
       // `if (hasListener) { _blockWrappers = ... }`
       // `bool get hasListener => returnType == voidType;`
       // So if return type is NOT void, it might not generate the trampoline we want to annotate.
       // However, `_blockWrappersBindingString` is what generates the trampoline C code.
       // Wait, if return type is not void, `api` might be different. 
       // The user request says "Annotate them with API_AVAILABLE corresponding to the types in the block’s signature."
       // If the block itself doesn't generate a trampoline (because it's not a listener block?), 
       // maybe we don't need to annotate it? 
       // But let's assume valid case where we generate code.
       // Actually, the issue says "For block trampolines".
       // Block trampolines are generated for listener blocks.
       // Listener blocks strictly return void.
       // So asking for "restricted return type" test might be moot if listener blocks MUST return void.
       // But wait, `ObjCBlock` has `getProtocolMethodTrampoline` too.
       
       // Let's check protocol trampoline.
       final macos11 = makeInterface('MacOS11Class', macos: Version(11, 0, 0));
       
       // Protocol method trampoline is generated if we access it? 
       // `fillProtocolTrampoline` is called when used in protocol.
       // We can force it.
       
       final block = ObjCBlock(
           context,
           returnType: macos11,
           params: [],
           returnsRetained: false,
       );
       block.fillProtocolTrampoline(); 
       
       final binding = block.toObjCBindingString(Writer(context: context));
       expect(binding!.string, contains('API_AVAILABLE(macos(11.0.0))'));
    });

    test('Mixed platforms', () {
      final ios10 = makeInterface('IOS10', ios: Version(10, 0, 0));
      final macos10 = makeInterface('MacOS10', macos: Version(10, 12, 0));
      
      final block = ObjCBlock(
        context,
        returnType: voidType,
        params: [
            Parameter(type: ios10, name: 'p1'),
            Parameter(type: macos10, name: 'p2'),
        ],
        returnsRetained: false,
      );
      
      final binding = block.toObjCBindingString(Writer(context: context));
      expect(binding!.string, contains('API_AVAILABLE(ios(10.0.0), macos(10.12.0))'));
    });
  });
}
