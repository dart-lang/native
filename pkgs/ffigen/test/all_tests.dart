// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'code_generator_tests/code_generator_test.dart'
    as code_generator_tests_code_generator_test_dart;
import 'collision_tests/decl_decl_collision_test.dart'
    as collision_tests_decl_decl_collision_test_dart;
import 'collision_tests/decl_symbol_address_collision_test.dart'
    as collision_tests_decl_symbol_address_collision_test_dart;
import 'collision_tests/decl_type_name_collision_test.dart'
    as collision_tests_decl_type_name_collision_test_dart;
import 'collision_tests/reserved_keyword_collision_test.dart'
    as collision_tests_reserved_keyword_collision_test_dart;
import 'config_tests/compiler_opts_test.dart'
    as config_tests_compiler_opts_test_dart;
import 'config_tests/deprecate_assetid_test.dart'
    as config_tests_deprecate_assetid_test_dart;
import 'config_tests/exclude_all_by_default_test.dart'
    as config_tests_exclude_all_by_default_test_dart;
import 'config_tests/include_exclude_test.dart'
    as config_tests_include_exclude_test_dart;
import 'config_tests/json_schema_test.dart'
    as config_tests_json_schema_test_dart;
import 'config_tests/no_cursor_definition_warn_test.dart'
    as config_tests_no_cursor_definition_warn_test_dart;
import 'config_tests/packed_struct_override_test.dart'
    as config_tests_packed_struct_override_test_dart;
import 'config_tests/unknown_keys_warn_test.dart'
    as config_tests_unknown_keys_warn_test_dart;
import 'example_tests/add_example_test.dart'
    as example_tests_add_example_test_dart;
import 'example_tests/cjson_example_test.dart'
    as example_tests_cjson_example_test_dart;
import 'example_tests/ffinative_example_test.dart'
    as example_tests_ffinative_example_test_dart;
import 'example_tests/libclang_example_test.dart'
    as example_tests_libclang_example_test_dart;
import 'example_tests/objective_c_example_test.dart'
    as example_tests_objective_c_example_test_dart;
import 'example_tests/shared_bindings_example_test.dart'
    as example_tests_shared_bindings_example_test_dart;
import 'example_tests/simple_example_test.dart'
    as example_tests_simple_example_test_dart;
import 'example_tests/swift_example_test.dart'
    as example_tests_swift_example_test_dart;
import 'header_parser_tests/comment_markup_test.dart'
    as header_parser_tests_comment_markup_test_dart;
import 'header_parser_tests/enum_int_mimic_test.dart'
    as header_parser_tests_enum_int_mimic_test_dart;
import 'header_parser_tests/forward_decl_test.dart'
    as header_parser_tests_forward_decl_test_dart;
import 'header_parser_tests/function_n_struct_test.dart'
    as header_parser_tests_function_n_struct_test_dart;
import 'header_parser_tests/functions_test.dart'
    as header_parser_tests_functions_test_dart;
import 'header_parser_tests/globals_test.dart'
    as header_parser_tests_globals_test_dart;
import 'header_parser_tests/imported_types_test.dart'
    as header_parser_tests_imported_types_test_dart;
import 'header_parser_tests/macros_test.dart'
    as header_parser_tests_macros_test_dart;
import 'header_parser_tests/native_func_typedef_test.dart'
    as header_parser_tests_native_func_typedef_test_dart;
import 'header_parser_tests/nested_parsing_test.dart'
    as header_parser_tests_nested_parsing_test_dart;
import 'header_parser_tests/opaque_dependencies_test.dart'
    as header_parser_tests_opaque_dependencies_test_dart;
import 'header_parser_tests/packed_structs_test.dart'
    as header_parser_tests_packed_structs_test_dart;
import 'header_parser_tests/record_use_test.dart'
    as header_parser_tests_record_use_test_dart;
import 'header_parser_tests/regress_384_test.dart'
    as header_parser_tests_regress_384_test_dart;
import 'header_parser_tests/separate_definition_test.dart'
    as header_parser_tests_separate_definition_test_dart;
import 'header_parser_tests/sort_test.dart'
    as header_parser_tests_sort_test_dart;
import 'header_parser_tests/static_const_test.dart'
    as header_parser_tests_static_const_test_dart;
import 'header_parser_tests/struct_fptr_fields_test.dart'
    as header_parser_tests_struct_fptr_fields_test_dart;
import 'header_parser_tests/typedef_test.dart'
    as header_parser_tests_typedef_test_dart;
import 'header_parser_tests/unions_test.dart'
    as header_parser_tests_unions_test_dart;
import 'header_parser_tests/unnamed_enums_test.dart'
    as header_parser_tests_unnamed_enums_test_dart;
import 'header_parser_tests/varargs_test.dart'
    as header_parser_tests_varargs_test_dart;
import 'large_integration_tests/large_objc_test.dart'
    as large_integration_tests_large_objc_test_dart;
import 'large_integration_tests/large_test.dart'
    as large_integration_tests_large_test_dart;
import 'native_objc_test/arc_test.dart' as native_objc_test_arc_test_dart;
import 'native_objc_test/bad_method_test.dart'
    as native_objc_test_bad_method_test_dart;
import 'native_objc_test/bad_override_test.dart'
    as native_objc_test_bad_override_test_dart;
import 'native_objc_test/block_annotation_test.dart'
    as native_objc_test_block_annotation_test_dart;
import 'native_objc_test/block_inherit_test.dart'
    as native_objc_test_block_inherit_test_dart;
import 'native_objc_test/cast_test.dart' as native_objc_test_cast_test_dart;
import 'native_objc_test/category_test.dart'
    as native_objc_test_category_test_dart;
import 'native_objc_test/deprecated_test.dart'
    as native_objc_test_deprecated_test_dart;
import 'native_objc_test/enum_test.dart' as native_objc_test_enum_test_dart;
import 'native_objc_test/error_method_test.dart'
    as native_objc_test_error_method_test_dart;
import 'native_objc_test/failed_to_load_test.dart'
    as native_objc_test_failed_to_load_test_dart;
import 'native_objc_test/forward_decl_test.dart'
    as native_objc_test_forward_decl_test_dart;
import 'native_objc_test/global_native_test.dart'
    as native_objc_test_global_native_test_dart;
import 'native_objc_test/global_test.dart' as native_objc_test_global_test_dart;
import 'native_objc_test/inherited_instancetype_test.dart'
    as native_objc_test_inherited_instancetype_test_dart;
import 'native_objc_test/is_instance_test.dart'
    as native_objc_test_is_instance_test_dart;
import 'native_objc_test/isolate_test.dart'
    as native_objc_test_isolate_test_dart;
import 'native_objc_test/log_test.dart' as native_objc_test_log_test_dart;
import 'native_objc_test/method_filtering_test.dart'
    as native_objc_test_method_filtering_test_dart;
import 'native_objc_test/method_test.dart' as native_objc_test_method_test_dart;
import 'native_objc_test/native_objc_test.dart'
    as native_objc_test_native_objc_test_dart;
import 'native_objc_test/ns_range_test.dart'
    as native_objc_test_ns_range_test_dart;
import 'native_objc_test/nullable_inheritance_test.dart'
    as native_objc_test_nullable_inheritance_test_dart;
import 'native_objc_test/nullable_test.dart'
    as native_objc_test_nullable_test_dart;
import 'native_objc_test/property_test.dart'
    as native_objc_test_property_test_dart;
import 'native_objc_test/ref_count_test.dart'
    as native_objc_test_ref_count_test_dart;
import 'native_objc_test/rename_test.dart' as native_objc_test_rename_test_dart;
import 'native_objc_test/runtime_version_test.dart'
    as native_objc_test_runtime_version_test_dart;
import 'native_objc_test/sdk_variable_test.dart'
    as native_objc_test_sdk_variable_test_dart;
import 'native_objc_test/static_func_native_test.dart'
    as native_objc_test_static_func_native_test_dart;
import 'native_objc_test/static_func_test.dart'
    as native_objc_test_static_func_test_dart;
import 'native_objc_test/string_test.dart' as native_objc_test_string_test_dart;
import 'native_objc_test/swift_class_test.dart'
    as native_objc_test_swift_class_test_dart;
import 'native_objc_test/swift_unavailable_test.dart'
    as native_objc_test_swift_unavailable_test_dart;
import 'native_objc_test/transitive_test.dart'
    as native_objc_test_transitive_test_dart;
import 'native_objc_test/typedef_test.dart'
    as native_objc_test_typedef_test_dart;
import 'native_objc_test/verify_bindings_test.dart'
    as native_objc_test_verify_bindings_test_dart;
import 'native_test/native_test.dart' as native_test_native_test_dart;
import 'rename_tests/rename_test.dart' as rename_tests_rename_test_dart;
import 'test_utils.dart';
import 'unit_tests/api_availability_test.dart'
    as unit_tests_api_availability_test_dart;
import 'unit_tests/config_util_test.dart' as unit_tests_config_util_test_dart;
import 'unit_tests/normalize_path_test.dart'
    as unit_tests_normalize_path_test_dart;
import 'unit_tests/objc_framework_header_test.dart'
    as unit_tests_objc_framework_header_test_dart;
import 'unit_tests/objc_inheritance_edge_case_test.dart'
    as unit_tests_objc_inheritance_edge_case_test_dart;
import 'unit_tests/record_use_test.dart' as unit_tests_record_use_test_dart;
import 'unit_tests/scope_test.dart' as unit_tests_scope_test_dart;
import 'unit_tests/sdk_variables_test.dart'
    as unit_tests_sdk_variables_test_dart;
import 'unit_tests/subtyping_test.dart' as unit_tests_subtyping_test_dart;

void main() {
  group(
    'code_generator_tests/code_generator_test.dart',
    code_generator_tests_code_generator_test_dart.main,
  );
  group(
    'collision_tests/decl_decl_collision_test.dart',
    collision_tests_decl_decl_collision_test_dart.main,
  );
  group(
    'collision_tests/decl_symbol_address_collision_test.dart',
    collision_tests_decl_symbol_address_collision_test_dart.main,
  );
  group(
    'collision_tests/decl_type_name_collision_test.dart',
    collision_tests_decl_type_name_collision_test_dart.main,
  );
  group(
    'collision_tests/reserved_keyword_collision_test.dart',
    collision_tests_reserved_keyword_collision_test_dart.main,
  );
  group(
    'config_tests/compiler_opts_test.dart',
    config_tests_compiler_opts_test_dart.main,
  );
  group(
    'config_tests/deprecate_assetid_test.dart',
    config_tests_deprecate_assetid_test_dart.main,
  );
  group(
    'config_tests/exclude_all_by_default_test.dart',
    config_tests_exclude_all_by_default_test_dart.main,
  );
  group(
    'config_tests/include_exclude_test.dart',
    config_tests_include_exclude_test_dart.main,
  );
  group(
    'config_tests/json_schema_test.dart',
    config_tests_json_schema_test_dart.main,
  );
  group(
    'config_tests/no_cursor_definition_warn_test.dart',
    config_tests_no_cursor_definition_warn_test_dart.main,
  );
  group(
    'config_tests/packed_struct_override_test.dart',
    config_tests_packed_struct_override_test_dart.main,
  );
  group(
    'config_tests/unknown_keys_warn_test.dart',
    config_tests_unknown_keys_warn_test_dart.main,
  );
  group(
    'example_tests/add_example_test.dart',
    example_tests_add_example_test_dart.main,
  );
  group(
    'example_tests/cjson_example_test.dart',
    example_tests_cjson_example_test_dart.main,
  );
  group(
    'example_tests/ffinative_example_test.dart',
    example_tests_ffinative_example_test_dart.main,
  );
  group(
    'example_tests/libclang_example_test.dart',
    example_tests_libclang_example_test_dart.main,
  );
  group(
    'example_tests/objective_c_example_test.dart',
    example_tests_objective_c_example_test_dart.main,
  );
  group(
    'example_tests/shared_bindings_example_test.dart',
    example_tests_shared_bindings_example_test_dart.main,
  );
  group(
    'example_tests/simple_example_test.dart',
    example_tests_simple_example_test_dart.main,
  );
  group(
    'example_tests/swift_example_test.dart',
    example_tests_swift_example_test_dart.main,
  );
  group(
    'header_parser_tests/comment_markup_test.dart',
    header_parser_tests_comment_markup_test_dart.main,
  );
  group(
    'header_parser_tests/enum_int_mimic_test.dart',
    header_parser_tests_enum_int_mimic_test_dart.main,
  );
  group(
    'header_parser_tests/forward_decl_test.dart',
    header_parser_tests_forward_decl_test_dart.main,
  );
  group(
    'header_parser_tests/function_n_struct_test.dart',
    header_parser_tests_function_n_struct_test_dart.main,
  );
  group(
    'header_parser_tests/functions_test.dart',
    header_parser_tests_functions_test_dart.main,
  );
  group(
    'header_parser_tests/globals_test.dart',
    header_parser_tests_globals_test_dart.main,
  );
  group(
    'header_parser_tests/imported_types_test.dart',
    header_parser_tests_imported_types_test_dart.main,
  );
  group(
    'header_parser_tests/macros_test.dart',
    header_parser_tests_macros_test_dart.main,
  );
  group(
    'header_parser_tests/native_func_typedef_test.dart',
    header_parser_tests_native_func_typedef_test_dart.main,
  );
  group(
    'header_parser_tests/nested_parsing_test.dart',
    header_parser_tests_nested_parsing_test_dart.main,
  );
  group(
    'header_parser_tests/opaque_dependencies_test.dart',
    header_parser_tests_opaque_dependencies_test_dart.main,
  );
  group(
    'header_parser_tests/packed_structs_test.dart',
    header_parser_tests_packed_structs_test_dart.main,
  );
  group(
    'header_parser_tests/record_use_test.dart',
    header_parser_tests_record_use_test_dart.main,
  );
  group(
    'header_parser_tests/regress_384_test.dart',
    header_parser_tests_regress_384_test_dart.main,
  );
  group(
    'header_parser_tests/separate_definition_test.dart',
    header_parser_tests_separate_definition_test_dart.main,
  );
  group(
    'header_parser_tests/sort_test.dart',
    header_parser_tests_sort_test_dart.main,
  );
  group(
    'header_parser_tests/static_const_test.dart',
    header_parser_tests_static_const_test_dart.main,
  );
  group(
    'header_parser_tests/struct_fptr_fields_test.dart',
    header_parser_tests_struct_fptr_fields_test_dart.main,
  );
  group(
    'header_parser_tests/typedef_test.dart',
    header_parser_tests_typedef_test_dart.main,
  );
  group(
    'header_parser_tests/unions_test.dart',
    header_parser_tests_unions_test_dart.main,
  );
  group(
    'header_parser_tests/unnamed_enums_test.dart',
    header_parser_tests_unnamed_enums_test_dart.main,
  );
  group(
    'header_parser_tests/varargs_test.dart',
    header_parser_tests_varargs_test_dart.main,
  );
  group(
    'large_integration_tests/large_objc_test.dart',
    large_integration_tests_large_objc_test_dart.main,
  );
  group(
    'large_integration_tests/large_test.dart',
    large_integration_tests_large_test_dart.main,
  );
  group('native_objc_test/arc_test.dart', native_objc_test_arc_test_dart.main);
  group(
    'native_objc_test/bad_method_test.dart',
    native_objc_test_bad_method_test_dart.main,
  );
  group(
    'native_objc_test/bad_override_test.dart',
    native_objc_test_bad_override_test_dart.main,
  );
  group(
    'native_objc_test/block_annotation_test.dart',
    native_objc_test_block_annotation_test_dart.main,
  );
  group(
    'native_objc_test/block_inherit_test.dart',
    native_objc_test_block_inherit_test_dart.main,
  );
  group(
    'native_objc_test/cast_test.dart',
    native_objc_test_cast_test_dart.main,
  );
  group(
    'native_objc_test/category_test.dart',
    native_objc_test_category_test_dart.main,
  );
  group(
    'native_objc_test/deprecated_test.dart',
    native_objc_test_deprecated_test_dart.main,
  );
  group(
    'native_objc_test/enum_test.dart',
    native_objc_test_enum_test_dart.main,
  );
  group(
    'native_objc_test/error_method_test.dart',
    native_objc_test_error_method_test_dart.main,
  );
  group(
    'native_objc_test/failed_to_load_test.dart',
    native_objc_test_failed_to_load_test_dart.main,
  );
  group(
    'native_objc_test/forward_decl_test.dart',
    native_objc_test_forward_decl_test_dart.main,
  );
  group(
    'native_objc_test/global_native_test.dart',
    native_objc_test_global_native_test_dart.main,
  );
  group(
    'native_objc_test/global_test.dart',
    native_objc_test_global_test_dart.main,
  );
  group(
    'native_objc_test/inherited_instancetype_test.dart',
    native_objc_test_inherited_instancetype_test_dart.main,
  );
  group(
    'native_objc_test/is_instance_test.dart',
    native_objc_test_is_instance_test_dart.main,
  );
  group(
    'native_objc_test/isolate_test.dart',
    native_objc_test_isolate_test_dart.main,
  );
  group('native_objc_test/log_test.dart', native_objc_test_log_test_dart.main);
  group(
    'native_objc_test/method_filtering_test.dart',
    native_objc_test_method_filtering_test_dart.main,
  );
  group(
    'native_objc_test/method_test.dart',
    native_objc_test_method_test_dart.main,
  );
  group(
    'native_objc_test/native_objc_test.dart',
    native_objc_test_native_objc_test_dart.main,
  );
  group(
    'native_objc_test/ns_range_test.dart',
    native_objc_test_ns_range_test_dart.main,
  );
  group(
    'native_objc_test/nullable_inheritance_test.dart',
    native_objc_test_nullable_inheritance_test_dart.main,
  );
  group(
    'native_objc_test/nullable_test.dart',
    native_objc_test_nullable_test_dart.main,
  );
  group(
    'native_objc_test/property_test.dart',
    native_objc_test_property_test_dart.main,
  );
  group(
    'native_objc_test/ref_count_test.dart',
    native_objc_test_ref_count_test_dart.main,
  );
  group(
    'native_objc_test/rename_test.dart',
    native_objc_test_rename_test_dart.main,
  );
  group(
    'native_objc_test/runtime_version_test.dart',
    native_objc_test_runtime_version_test_dart.main,
  );
  group(
    'native_objc_test/sdk_variable_test.dart',
    native_objc_test_sdk_variable_test_dart.main,
  );
  group(
    'native_objc_test/static_func_native_test.dart',
    native_objc_test_static_func_native_test_dart.main,
  );
  group(
    'native_objc_test/static_func_test.dart',
    native_objc_test_static_func_test_dart.main,
  );
  group(
    'native_objc_test/string_test.dart',
    native_objc_test_string_test_dart.main,
  );
  group(
    'native_objc_test/swift_class_test.dart',
    native_objc_test_swift_class_test_dart.main,
  );
  group(
    'native_objc_test/swift_unavailable_test.dart',
    native_objc_test_swift_unavailable_test_dart.main,
  );
  group(
    'native_objc_test/transitive_test.dart',
    native_objc_test_transitive_test_dart.main,
  );
  group(
    'native_objc_test/typedef_test.dart',
    native_objc_test_typedef_test_dart.main,
  );
  group(
    'native_objc_test/verify_bindings_test.dart',
    native_objc_test_verify_bindings_test_dart.main,
  );
  group('native_test/native_test.dart', native_test_native_test_dart.main);
  group('rename_tests/rename_test.dart', rename_tests_rename_test_dart.main);
  group(
    'unit_tests/api_availability_test.dart',
    unit_tests_api_availability_test_dart.main,
  );
  group('unit_tests/config_util_test.dart', unit_tests_config_util_test_dart.main);
  group(
    'unit_tests/normalize_path_test.dart',
    unit_tests_normalize_path_test_dart.main,
  );
  group(
    'unit_tests/objc_framework_header_test.dart',
    unit_tests_objc_framework_header_test_dart.main,
  );
  group(
    'unit_tests/objc_inheritance_edge_case_test.dart',
    unit_tests_objc_inheritance_edge_case_test_dart.main,
  );
  group('unit_tests/record_use_test.dart', unit_tests_record_use_test_dart.main);
  group('unit_tests/scope_test.dart', unit_tests_scope_test_dart.main);
  group(
    'unit_tests/sdk_variables_test.dart',
    unit_tests_sdk_variables_test_dart.main,
  );
  group('unit_tests/subtyping_test.dart', unit_tests_subtyping_test_dart.main);

  test('All tests are imported and invoked', () {
    // TODO(https://github.com/dart-lang/native/issues/3345): Fix and enable.
    const excludedTests = {
      'header_parser_tests/dart_handle_test.dart',
      'native_objc_test/block_test.dart',
      'native_objc_test/protocol_test.dart',
    };

    final testDirectory = Directory(path.join(packagePathForTests, 'test'));
    final allTestFiles = testDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'))
        .map((f) => path.relative(f.path, from: testDirectory.path))
        .where((f) => !excludedTests.contains(f))
        .toSet();

    final source = File(
      path.join(testDirectory.path, 'all_tests.dart'),
    ).readAsStringSync();

    final importRegex = RegExp(r"import\s+'(.+_test\.dart)'\s+as\s+(\w+);");
    final imports = {
      for (final match in importRegex.allMatches(source))
        match.group(1)!: match.group(2)!,
    };

    final invocationRegex = RegExp(
      r"group\(\s*'(.+_test\.dart)',\s*(\w+)\.main\s*,?\s*\);",
    );
    final invocations = {
      for (final match in invocationRegex.allMatches(source))
        match.group(1)!: match.group(2)!,
    };

    expect(
      imports.keys.toSet(),
      allTestFiles,
      reason: 'All test files must be imported',
    );

    expect(
      invocations.keys.toSet(),
      allTestFiles,
      reason: 'All tests must be invoked',
    );

    expect(imports, invocations, reason: 'Imports must match invocations');
  });
}
