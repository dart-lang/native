// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:jni/jni.dart';

// The hierarchy created in generated code will mirror the java package
// structure. This is an implementation convenience and we may allow
// more customization in future.
import 'android_utils/com/example/in_app_java.dart';

JniObject activity = JniObject.fromRef(Jni.getCurrentActivity());

void showToast(String text) {
  AndroidUtils.showToast(activity, text.jniString(), 0);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Show toast'),
              onPressed: () => showToast('😀'),
            ),
          ],
        ),
      ),
    );
  }
}
