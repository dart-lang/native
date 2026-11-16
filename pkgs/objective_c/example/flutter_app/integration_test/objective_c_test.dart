// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:integration_test/integration_test.dart';

import '../../../../ffigen/test/native_objc_test/arc_test.dart' as arc_test;
import '../../../../ffigen/test/native_objc_test/bad_method_test.dart'
    as bad_method_test;
import '../../../../ffigen/test/native_objc_test/bad_override_test.dart'
    as bad_override_test;
import '../../../../ffigen/test/native_objc_test/block_annotation_test.dart'
    as block_annotation_test;
import '../../../../ffigen/test/native_objc_test/block_inherit_test.dart'
    as block_inherit_test;
import '../../../../ffigen/test/native_objc_test/block_test.dart' as block_test;
import '../../../../ffigen/test/native_objc_test/cast_test.dart' as cast_test;
import '../../../../ffigen/test/native_objc_test/category_test.dart'
    as category_test;
import '../../../../ffigen/test/native_objc_test/enum_test.dart' as enum_test;
import '../../../../ffigen/test/native_objc_test/error_method_test.dart'
    as error_method_test;
import '../../../../ffigen/test/native_objc_test/failed_to_load_test.dart'
    as failed_to_load_test;
import '../../../../ffigen/test/native_objc_test/forward_decl_test.dart'
    as forward_decl_test;
import '../../../../ffigen/test/native_objc_test/global_native_test.dart'
    as global_native_test;
import '../../../../ffigen/test/native_objc_test/inherited_instancetype_test.dart'
    as inherited_instancetype_test;
import '../../../../ffigen/test/native_objc_test/is_instance_test.dart'
    as is_instance_test;
import '../../../../ffigen/test/native_objc_test/isolate_test.dart'
    as isolate_test;
import '../../../../ffigen/test/native_objc_test/method_test.dart'
    as method_test;
import '../../../../ffigen/test/native_objc_test/native_objc_test.dart'
    as native_objc_test;
import '../../../../ffigen/test/native_objc_test/nullable_inheritance_test.dart'
    as nullable_inheritance_test;
import '../../../../ffigen/test/native_objc_test/nullable_test.dart'
    as nullable_test;
import '../../../../ffigen/test/native_objc_test/property_test.dart'
    as property_test;
import '../../../../ffigen/test/native_objc_test/protocol_test.dart'
    as protocol_test;
import '../../../../ffigen/test/native_objc_test/ref_count_test.dart'
    as ref_count_test;
import '../../../../ffigen/test/native_objc_test/rename_test.dart'
    as rename_test;
import '../../../../ffigen/test/native_objc_test/runtime_version_test.dart'
    as runtime_version_test;
import '../../../../ffigen/test/native_objc_test/small_struct_test.dart'
    as small_struct_test;
import '../../../../ffigen/test/native_objc_test/static_func_native_test.dart'
    as static_func_native_test;
import '../../../../ffigen/test/native_objc_test/string_test.dart'
    as string_test;
import '../../../../ffigen/test/native_objc_test/swift_class_test.dart'
    as swift_class_test;
import '../../../../ffigen/test/native_objc_test/typedef_test.dart'
    as typedef_test;
import '../../../test/autorelease_test.dart' as autorelease_test;
import '../../../test/cf_string_test.dart' as cf_string_test;
import '../../../test/converter_test.dart' as converter_test;
import '../../../test/internal_test.dart' as internal_test;
import '../../../test/ns_input_stream_test.dart' as ns_input_stream_test;
import '../../../test/ns_mutable_data_test.dart' as ns_mutable_data_test;
import '../../../test/nsarray_test.dart' as nsarray_test;
import '../../../test/nsdata_test.dart' as nsdata_test;
import '../../../test/nsdate_test.dart' as nsdate_test;
import '../../../test/nsdictionary_test.dart' as nsdictionary_test;
import '../../../test/nsmutablearray_test.dart' as nsmutablearray_test;
import '../../../test/nsmutabledictionary_test.dart'
    as nsmutabledictionary_test;
import '../../../test/nsmutableset_test.dart' as nsmutableset_test;
import '../../../test/nsnumber_test.dart' as nsnumber_test;
import '../../../test/nsset_test.dart' as nsset_test;
import '../../../test/nsstring_test.dart' as nsstring_test;
import '../../../test/observer_test.dart' as observer_test;
import '../../../test/os_version_test.dart' as os_version_test;
import '../../../test/protocol_builder_test.dart' as protocol_builder_test;
import '../../../test/selector_test.dart' as selector_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // package:objective_c runtime tests.
  autorelease_test.main();
  cf_string_test.main();
  converter_test.main();
  internal_test.main();
  ns_input_stream_test.main();
  ns_mutable_data_test.main();
  nsarray_test.main();
  nsdata_test.main();
  nsdate_test.main();
  nsdictionary_test.main();
  nsmutablearray_test.main();
  nsmutabledictionary_test.main();
  nsmutableset_test.main();
  nsnumber_test.main();
  nsset_test.main();
  nsstring_test.main();
  observer_test.main();
  os_version_test.main();
  protocol_builder_test.main();
  selector_test.main();

  // package:ffigen Objective-C runtime tests.
  arc_test.main();
  bad_method_test.main();
  bad_override_test.main();
  block_annotation_test.main();
  block_inherit_test.main();
  block_test.main();
  cast_test.main();
  category_test.main();
  enum_test.main();
  error_method_test.main();
  failed_to_load_test.main();
  forward_decl_test.main();
  global_native_test.main();
  inherited_instancetype_test.main();
  is_instance_test.main();
  isolate_test.main();
  method_test.main();
  native_objc_test.main();
  nullable_inheritance_test.main();
  nullable_test.main();
  property_test.main();
  protocol_test.main();
  ref_count_test.main();
  rename_test.main();
  runtime_version_test.main();
  small_struct_test.main();
  static_func_native_test.main();
  string_test.main();
  swift_class_test.main();
  typedef_test.main();
}
