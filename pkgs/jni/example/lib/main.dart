// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:ffi';

import 'package:jni/jni.dart';

// An example of calling JNI methods using low level primitives.
// GlobalJniEnv is a thin abstraction over JNIEnv in JNI C API.
//
// For a more ergonomic API for common use cases of calling methods and
// accessing fields, see next examples using JObject and JClass.
String toJavaStringUsingEnv(int n) => using((arena) {
      final env = Jni.env;
      final cls = env.FindClass("java/lang/String".toNativeChars(arena));
      final mId = env.GetStaticMethodID(cls, "valueOf".toNativeChars(),
          "(I)Ljava/lang/String;".toNativeChars(arena));
      final i = arena<JValue>();
      i.ref.i = n;
      final res = env.CallStaticObjectMethodA(cls, mId, i);
      final str = env.toDartString(res);
      env.deleteAllRefs([res, cls]);
      return str;
    });

int randomUsingEnv(int n) => using((arena) {
      final env = Jni.env;
      final randomCls = env.FindClass("java/util/Random".toNativeChars(arena));
      final ctor = env.GetMethodID(
          randomCls, "<init>".toNativeChars(arena), "()V".toNativeChars(arena));
      final random = env.NewObject(randomCls, ctor);
      final nextInt = env.GetMethodID(randomCls, "nextInt".toNativeChars(arena),
          "(I)I".toNativeChars(arena));
      final res = env.CallIntMethodA(random, nextInt, Jni.jvalues([n]));
      env.deleteAllRefs([randomCls, random]);
      return res;
    });
double randomDouble() {
  final math = Jni.findJClass("java/lang/Math");
  final random = math.callStaticMethodByName<double>("random", "()D", []);
  math.delete();
  return random;
}

int uptime() {
  return Jni.findJClass("android/os/SystemClock").use(
    (systemClock) => systemClock.callStaticMethodByName<int>(
        "uptimeMillis", "()J", [], JniCallType.longType),
  );
}

String backAndForth() {
  final jstring = '🪓'.toJString();
  final dartString = jstring.toDartString(deleteOriginal: true);
  return dartString;
}

void quit() {
  JObject.fromRef(Jni.getCurrentActivity())
      .use((ac) => ac.callMethodByName<void>("finish", "()V", []));
}

void showToast(String text) {
  // This is example for calling your app's custom java code.
  // Place the Toaster class in the app's android/ source Folder, with a Keep
  // annotation or appropriate proguard rules to retain classes in release mode.
  //
  // In this example, Toaster class wraps android.widget.Toast so that it
  // can be called from any thread. See
  // android/app/src/main/java/com/github/dart_lang/jni_example/Toaster.java
  Jni.invokeStaticMethod<JObject>(
      "com/github/dart_lang/jni_example/Toaster",
      "makeText",
      "(Landroid/app/Activity;Landroid/content/Context;"
          "Ljava/lang/CharSequence;I)"
          "Lcom/github/dart_lang/jni_example/Toaster;",
      [
        Jni.getCurrentActivity(),
        Jni.getCachedApplicationContext(),
        "😀",
        0,
      ]).callMethodByName<void>("show", "()V", []);
}

void main() {
  if (!Platform.isAndroid) {
    Jni.spawn();
  }
  final examples = [
    Example("String.valueOf(1332)", () => toJavaStringUsingEnv(1332)),
    Example("Generate random number", () => randomUsingEnv(180),
        runInitially: false),
    Example("Math.random()", () => randomDouble(), runInitially: false),
    if (Platform.isAndroid) ...[
      Example("Minutes of usage since reboot",
          () => (uptime() / (60 * 1000)).floor()),
      Example("Back and forth string conversion", () => backAndForth()),
      Example(
          "Device name",
          () => Jni.retrieveStaticField<String>(
              "android/os/Build", "DEVICE", "Ljava/lang/String;")),
      Example(
        "Package name",
        () => JObject.fromRef(Jni.getCurrentActivity()).use((activity) =>
            activity.callMethodByName<String>(
                "getPackageName", "()Ljava/lang/String;", [])),
      ),
      Example("Show toast", () => showToast("Hello from JNI!"),
          runInitially: false),
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

class MyApp extends StatefulWidget {
  const MyApp(this.examples, {Key? key}) : super(key: key);
  final List<Example> examples;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JNI Examples'),
        ),
        body: ListView.builder(
            itemCount: widget.examples.length,
            itemBuilder: (context, i) {
              final eg = widget.examples[i];
              return ExampleCard(eg);
            }),
      ),
    );
  }
}

class ExampleCard extends StatefulWidget {
  const ExampleCard(this.example, {Key? key}) : super(key: key);
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
