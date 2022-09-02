// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jni/jni.dart';
import 'package:jni/jni_object.dart';
import 'package:jni_example/main.dart';

// TODO(#38): This test is skipped because it broke for unknown reason in
// in flutter 3.3.0

// This test exists just to verify that
// when everything is correct, JNI actually runs
// However it's also kind of meaningless, because test environment
// differs substantially from the device.

void main() {
  if (!Platform.isAndroid) {
    Jni.spawn(helperDir: "build/jni_libs");
  }
  final jni = Jni.getInstance();
  testWidgets("simple toString example", (tester) async {
    await tester.pumpWidget(ExampleForTest(ExampleCard(Example(
        "toString",
        () => jni.findJniClass("java/lang/Long").use((long) => long
            .callStaticStringMethodByName(
                "toHexString", "(J)Ljava/lang/String;", [0x1876]))))));
    expect(find.text("1876"), findsOneWidget);
  });
}

class ExampleForTest extends StatelessWidget {
  const ExampleForTest(this.widget, {Key? key}) : super(key: key);
  final Widget widget;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '__TEST__',
      home: Scaffold(
        appBar: AppBar(title: const Text("__test__")),
        body: Center(child: widget),
      ),
    );
  }
}
