// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: unused_local_variable

import 'package:objective_c/objective_c.dart';

void protocolBuilderExample() {
  // snippet-start#protocol_builder
  // Build an object that implements an Objective-C protocol.
  final builder = ObjCProtocolBuilder();
  NSStreamDelegate$Builder.addToBuilder(
    builder,
    stream_handleEvent_: (stream, event) {
      // Handle stream event.
    },
  );
  final delegate = NSStreamDelegate.as(builder.build());
  // snippet-end#protocol_builder
}
