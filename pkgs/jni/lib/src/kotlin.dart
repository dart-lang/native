// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show internal;

import 'types.dart';

@internal
final coroutineSingletonsClass =
    JClass.forName('kotlin/coroutines/intrinsics/CoroutineSingletons');

@internal
final result$FailureClass = JClass.forName(r'kotlin/Result$Failure');

@internal
final failureExceptionField =
    result$FailureClass.instanceFieldId('exception', 'Ljava/lang/Throwable;');
