import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jni/jni.dart';
import 'package:jni/jni_object.dart';
import 'package:jni_example/main.dart';

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
