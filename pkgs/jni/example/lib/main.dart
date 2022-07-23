// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';
import 'package:jni/jni_object.dart';

late Jni jni;

String localToJavaString(int n) {
  final jniEnv = jni.getEnv();
  final arena = Arena();
  final cls = jniEnv.FindClass("java/lang/String".toNativeChars(arena));
  final mId = jniEnv.GetStaticMethodID(cls, "valueOf".toNativeChars(),
      "(I)Ljava/lang/String;".toNativeChars(arena));
  final i = arena<JValue>();
  i.ref.i = n;
  final res = jniEnv.CallStaticObjectMethodA(cls, mId, i);
  final str = jniEnv.asDartString(res);
  jniEnv.deleteAllLocalRefs([res, cls]);
  arena.releaseAll();
  return str;
}

int random(int n) {
  final arena = Arena();
  final jniEnv = jni.getEnv();
  final randomCls = jniEnv.FindClass("java/util/Random".toNativeChars(arena));
  final ctor = jniEnv.GetMethodID(
      randomCls, "<init>".toNativeChars(arena), "()V".toNativeChars(arena));
  final random = jniEnv.NewObject(randomCls, ctor);
  final nextInt = jniEnv.GetMethodID(
      randomCls, "nextInt".toNativeChars(arena), "(I)I".toNativeChars(arena));
  final res = jniEnv.CallIntMethodA(random, nextInt, Jni.jvalues([n]));
  jniEnv.deleteAllLocalRefs([randomCls, random]);
  return res;
}

double randomDouble() {
  final math = jni.findJniClass("java/lang/Math");
  final random = math.callStaticDoubleMethodByName("random", "()D", []);
  math.delete();
  return random;
}

int uptime() {
  final systemClock = jni.findJniClass("android/os/SystemClock");
  final uptime =
      systemClock.callStaticLongMethodByName("uptimeMillis", "()J", []);
  systemClock.delete();
  return uptime;
}

void quit() {
  jni
      .wrap(jni.getCurrentActivity())
      .use((ac) => ac.callVoidMethodByName("finish", "()V", []));
}

void showToast(String text) {
  // This is example for calling you app's custom java code.
  // You place the AnyToast class in you app's android/ source
  // Folder, with a Keep annotation or appropriate proguard rules
  // to retain the class in release mode.
  // In this example, AnyToast class is just a type of `Toast` that
  // can be called from any thread. See
  // android/app/src/main/java/dev/dart/jni_example/AnyToast.java
  jni.invokeObjectMethod(
      "dev/dart/jni_example/AnyToast",
      "makeText",
      "(Landroid/app/Activity;Landroid/content/Context;"
          "Ljava/lang/CharSequence;I)"
          "Ldev/dart/jni_example/AnyToast;",
      [
        jni.getCurrentActivity(),
        jni.getCachedApplicationContext(),
        ":-)",
        0
      ]).callVoidMethodByName("show", "()V", []);
}

void main() {
  if (!Platform.isAndroid) {
    Jni.spawn();
  }
  jni = Jni.getInstance();
  final examples = [
    Example("String.valueOf(1332)", () => localToJavaString(1332)),
    Example("Generate random number", () => random(180), runInitially: false),
    Example("Math.random()", () => randomDouble(), runInitially: false),
    if (Platform.isAndroid) ...[
      Example("Minutes of usage since reboot",
          () => (uptime() / (60 * 1000)).floor()),
      Example(
          "Device name",
          () => jni.retrieveStringField(
              "android/os/Build", "DEVICE", "Ljava/lang/String;")),
      Example(
        "Package name",
        () => jni.wrap(jni.getCurrentActivity()).use((activity) => activity
            .callStringMethodByName(
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
