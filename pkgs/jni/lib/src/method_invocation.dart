// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:meta/meta.dart' show internal;

import 'jarray.dart';
import 'jobject.dart';
import 'jreference.dart';
import 'lang/jstring.dart';
import 'third_party/generated_bindings.dart';

@internal
class MethodInvocation {
  final Pointer<CallbackResult> result;
  final JString methodDescriptor;
  final JArray<JObject?>? args;

  MethodInvocation._(this.result, this.methodDescriptor, this.args);

  factory MethodInvocation.fromAddresses(
    int resultAddress,
    int descriptorAddress,
    int argsAddress,
  ) {
    return MethodInvocation._(
      Pointer<CallbackResult>.fromAddress(resultAddress),
      JString.fromReference(
          JGlobalReference(Pointer<Void>.fromAddress(descriptorAddress))),
      argsAddress == 0
          ? null
          : JArray.fromReference(
              const JObjectNullableType(),
              JGlobalReference(Pointer<Void>.fromAddress(argsAddress)),
            ),
    );
  }

  factory MethodInvocation.fromMessage(List<dynamic> message) {
    return MethodInvocation.fromAddresses(
      message[0] as int,
      message[1] as int,
      message[2] as int,
    );
  }
}
