// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jni/jni.dart';

double randomDouble() {
  final math = JClass.forName("java/lang/Math");
  final random =
      math.staticMethodId("random", "()D").call(math, jdouble.type, []);
  math.release();
  return random;
}

int uptime() {
  return JClass.forName("android/os/SystemClock").use(
    (systemClock) => systemClock
        .staticMethodId("uptimeMillis", "()J")
        .call(systemClock, jlong.type, []),
  );
}

String backAndForth() {
  final jstring = '🪓'.toJString();
  final dartString = jstring.toDartString(releaseOriginal: true);
  return dartString;
}

void quit() {
  final activity = Jni.androidActivity(PlatformDispatcher.instance.engineId!);
  if (activity == null) return;
  activity.jClass
      .instanceMethodId("finish", "()V")
      .call(activity, jvoid.type, []);
  activity.release();
}

void showToast(String text) {
  final activity = Jni.androidActivity(PlatformDispatcher.instance.engineId!);
  if (activity == null) return;
  final toasterClass =
      JClass.forName('com/github/dart_lang/jni_example/Toaster');
  final makeText = toasterClass.staticMethodId(
      'makeText',
      '(Landroid/app/Activity;Landroid/content/Context;'
          'Ljava/lang/CharSequence;I)'
          'Lcom/github/dart_lang/jni_example/Toaster;');
  final applicationContext =
      Jni.androidApplicationContext(PlatformDispatcher.instance.engineId!);
  final toaster = makeText(toasterClass, JObject.type, [
    activity,
    applicationContext,
    text.toJString(),
    0,
  ]);
  final show = toasterClass.instanceMethodId('show', '()V');
  show(toaster, jvoid.type, []);
  toaster.release();
  applicationContext.release();
  activity.release();
  text.toJString().release();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isAndroid) {
    Jni.spawn();
  }
  final examples = [
    Example("Math.random()", () => randomDouble(), runInitially: false),
    if (Platform.isAndroid) ...[
      Example("Minutes of usage since reboot",
          () => (uptime() / (60 * 1000)).floor()),
      Example("Back and forth string conversion", () => backAndForth()),
      Example("Device name", () {
        final buildClass = JClass.forName("android/os/Build");
        return buildClass
            .staticFieldId("DEVICE", JString.type.signature)
            .get(buildClass, JString.type)
            .toDartString(releaseOriginal: true);
      }),
      Example(
        "Package name",
        () {
          final activity =
              Jni.androidActivity(PlatformDispatcher.instance.engineId!);
          if (activity == null) return "Activity not available";
          final packageName = activity.jClass
              .instanceMethodId("getPackageName", "()Ljava/lang/String;")
              .call(activity, JString.type, []);
          activity.release();
          return packageName;
        },
      ),
      Example(
        "Show toast",
        () => showToast("Hello from JNI!"),
        runInitially: false,
      ),
      Example(
        "Quit",
        quit,
        runInitially: false,
      ),
    ]
  ];
  runApp(MyApp(examples));
}

class Example {
  String title;
  dynamic Function() callback;
  bool runInitially;
  Example(this.title, this.callback, {this.runInitially = true});
}

class MyApp extends StatelessWidget {
  const MyApp(this.examples, {super.key});
  final List<Example> examples;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JNI Examples'),
        ),
        body: ListView.builder(
          itemCount: examples.length,
          itemBuilder: (context, i) {
            final eg = examples[i];
            return ExampleCard(eg);
          },
        ),
      ),
    );
  }
}

class ExampleCard extends StatefulWidget {
  const ExampleCard(this.example, {super.key});
  final Example example;

  @override
  _ExampleCardState createState() => _ExampleCardState();
}

class _ExampleCardState extends State<ExampleCard> {
  Widget _pad(Widget w, double h, double v) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: h, vertical: v), child: w);
  }

  bool _run = false;

  @override
  void initState() {
    super.initState();
    _run = widget.example.runInitially;
  }

  @override
  Widget build(BuildContext context) {
    final eg = widget.example;
    var result = "";
    var hasError = false;
    if (_run) {
      try {
        result = eg.callback().toString();
      } on Exception catch (e) {
        hasError = true;
        result = e.toString();
      } on Error catch (e) {
        hasError = true;
        result = e.toString();
      }
    }
    var resultStyle = const TextStyle(fontFamily: "Monospace");
    if (hasError) {
      resultStyle = const TextStyle(fontFamily: "Monospace", color: Colors.red);
    }
    return Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eg.title,
            softWrap: true,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        _pad(
            Text(result.toString(), softWrap: true, style: resultStyle), 8, 16),
        _pad(
            ElevatedButton(
              child: Text(_run ? "Run again" : "Run"),
              onPressed: () => setState(() => _run = true),
            ),
            8,
            8),
      ]),
    );
  }
}
