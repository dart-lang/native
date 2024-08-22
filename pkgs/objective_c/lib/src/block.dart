// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'c_bindings_generated.dart' as c;
import 'internal.dart';

/// An Objective-C block. Blocks are ObjC's equivalent of lambda functions.
///
/// Ffigen generates utility classes for each block signature referenced in the
/// API it is generating. These utils enable construction of an `ObjCBlock` from
/// a Dart `Function`, and invoking an `ObjCBlock` from Dart.
///
/// T is the signature of the block, as a Dart `Function`. The arguments and
/// returns of the `Function` should be specified as follows:
///  - For ObjC objects, use the ffigen generated wrapper object.
///  - For ObjC blocks, use `ObjCBlock<...>`.
///  - For all other types, use the FFI type (eg `Int32` instead of `int`).
/// For example, the block type `int32_t (^)(NSString*)` would be represented in
/// Dart as `ObjCBlock<ffi.Int32 Function(NSString)>`. The best way to figure
/// out the block's type is to simply copy it from the ffigen generated API.
class ObjCBlock<T extends Function> extends ObjCBlockBase {
  /// This constructor is only for use by ffigen bindings.
  ObjCBlock(super.ptr, {required super.retain, required super.release});
}
