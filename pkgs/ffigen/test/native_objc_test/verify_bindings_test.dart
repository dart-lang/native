// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'arc_config.dart' as arc_config;
import 'bad_method_config.dart' as bad_method_config;
import 'bad_override_config.dart' as bad_override_config;
import 'block_annotation_config.dart' as block_annotation_config;
import 'block_config.dart' as block_config;
import 'block_inherit_config.dart' as block_inherit_config;
import 'cast_config.dart' as cast_config;
import 'category_config.dart' as category_config;
import 'enum_config.dart' as enum_config;
import 'error_method_config.dart' as error_method_config;
import 'failed_to_load_config.dart' as failed_to_load_config;
import 'forward_decl_config.dart' as forward_decl_config;
import 'global_config.dart' as global_config;
import 'global_native_config.dart' as global_native_config;
import 'inherited_instancetype_config.dart' as inherited_instancetype_config;
import 'is_instance_config.dart' as is_instance_config;
import 'isolate_config.dart' as isolate_config;
import 'log_config.dart' as log_config;
import 'method_config.dart' as method_config;
import 'method_filtering_config.dart' as method_filtering_config;
import 'native_objc_config.dart' as native_objc_config;
import 'nullable_config.dart' as nullable_config;
import 'nullable_inheritance_config.dart' as nullable_inheritance_config;
import 'property_config.dart' as property_config;
import 'protocol_config.dart' as protocol_config;
import 'ref_count_config.dart' as ref_count_config;
import 'rename_config.dart' as rename_config;
import 'runtime_version_config.dart' as runtime_version_config;
import 'sdk_variable_config.dart' as sdk_variable_config;
import 'small_struct_config.dart' as small_struct_config;
import 'static_func_config.dart' as static_func_config;
import 'static_func_native_config.dart' as static_func_native_config;
import 'string_config.dart' as string_config;
import 'swift_class_config.dart' as swift_class_config;
import 'typedef_config.dart' as typedef_config;
import 'util.dart';

void main() {
  group('verify_bindings_test', () {
    final testDir = Directory(
      path.join(packagePathForTests, 'test', 'native_objc_test'),
    );

    // These tests don't use verifyBindings because they generate their bindings
    // programmatically.
    const excludedTests = {
      'deprecated_test.dart',
      'ns_range_test.dart',
      'swift_unavailable_test.dart',
      'transitive_test.dart',
      'verify_bindings_test.dart',
    };

    const customVerifiers = {
      'protocol_test.dart': (
        _verifyProtocolTestDartBindings,
        _verifyProtocolTestObjCBindings,
      ),
    };

    final testFiles =
        testDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_test.dart'))
            .map((f) => path.basename(f.path))
            .where((f) => !excludedTests.contains(f))
            .toList()
          ..sort();

    final packageRoot = Uri.file(path.join(packagePathForTests, ''));
    final configs = <String, FfiGenerator>{
      'arc': arc_config.getConfig(packageRoot),
      'bad_method': bad_method_config.getConfig(packageRoot),
      'bad_override': bad_override_config.getConfig(packageRoot),
      'block_annotation': block_annotation_config.getConfig(packageRoot),
      'block': block_config.getConfig(packageRoot),
      'block_inherit': block_inherit_config.getConfig(packageRoot),
      'cast': cast_config.getConfig(packageRoot),
      'category': category_config.getConfig(packageRoot),
      'enum': enum_config.getConfig(packageRoot),
      'error_method': error_method_config.getConfig(packageRoot),
      'failed_to_load': failed_to_load_config.getConfig(packageRoot),
      'forward_decl': forward_decl_config.getConfig(packageRoot),
      'global': global_config.getConfig(packageRoot),
      'global_native': global_native_config.getConfig(packageRoot),
      'inherited_instancetype': inherited_instancetype_config.getConfig(
        packageRoot,
      ),
      'is_instance': is_instance_config.getConfig(packageRoot),
      'isolate': isolate_config.getConfig(packageRoot),
      'log': log_config.getConfig(packageRoot),
      'method': method_config.getConfig(packageRoot),
      'method_filtering': method_filtering_config.getConfig(packageRoot),
      'native_objc': native_objc_config.getConfig(packageRoot),
      'nullable': nullable_config.getConfig(packageRoot),
      'nullable_inheritance': nullable_inheritance_config.getConfig(
        packageRoot,
      ),
      'property': property_config.getConfig(packageRoot),
      'protocol': protocol_config.getConfig(packageRoot),
      'ref_count': ref_count_config.getConfig(packageRoot),
      'rename': rename_config.getConfig(packageRoot),
      'runtime_version': runtime_version_config.getConfig(packageRoot),
      'sdk_variable': sdk_variable_config.getConfig(packageRoot),
      'small_struct': small_struct_config.getConfig(packageRoot),
      'static_func': static_func_config.getConfig(packageRoot),
      'static_func_native': static_func_native_config.getConfig(packageRoot),
      'string': string_config.getConfig(packageRoot),
      'swift_class': swift_class_config.getConfig(packageRoot),
      'typedef': typedef_config.getConfig(packageRoot),
    };

    for (final testFile in testFiles) {
      final configName = testFile.replaceFirst('_test.dart', '');

      test('verifyBindings for $testFile', () {
        final config = configs[configName];
        if (config == null) {
          fail('No FfiGenerator config registered for $testFile in `configs`.');
        }
        final verifiers = customVerifiers[testFile];
        verifyBindings(
          config,
          dartVerify: verifiers?.$1,
          objCVerify: verifiers?.$2,
        );
      });
    }
  });
}

bool _verifyProtocolTestDartBindings(String expected, String actual) {
  expect(
    actual,
    contains('extension type ProtocolConsumer._(objc.ObjCObject '),
  );
  expect(
    actual,
    contains('extension type ObjCProtocolImpl._(objc.ObjCObject '),
  );
  expect(actual, contains('extension type MyProtocol._(objc.ObjCProtocol '));
  expect(
    actual,
    contains('extension type SecondaryProtocol._(objc.ObjCProtocol '),
  );
  expect(actual, contains(r'interface class MyProtocol$Builder {'));
  expect(actual, contains(r'interface class SecondaryProtocol$Builder {'));
  expect(
    actual,
    contains(
      'objc.NSString instanceMethod('
      'objc.NSString s, {required double withDouble})',
    ),
  );
  expect(actual, contains('int optionalMethod(SomeStruct s)'));
  expect(
    actual,
    contains(
      'int otherMethod('
      'int a, {required int b, required int c, required int d})',
    ),
  );
  expect(actual, contains('int fooMethod()'));
  expect(actual, contains('extension type EmptyProtocol._(objc.ObjCProtocol '));
  expect(actual, isNot(contains('EmptyProtocol is a stub')));
  expect(actual, contains('SuperProtocol is a stub'));
  expect(actual, contains('FilteredProtocol is a stub'));
  return true;
}

bool _verifyProtocolTestObjCBindings(String expected, String actual) {
  expect(actual, contains('@protocol(EmptyProtocol)'));
  expect(actual, contains('@protocol(MyProtocol)'));
  expect(actual, contains('@protocol(SecondaryProtocol)'));
  expect(actual, contains('@protocol(UnusedProtocol)'));
  expect(actual, contains('BLOCKING_BLOCK_IMPL'));
  return true;
}
