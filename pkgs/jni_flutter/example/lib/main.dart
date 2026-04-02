// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: JniExamplePage());
  }
}

class JniExamplePage extends StatefulWidget {
  const JniExamplePage({super.key});

  @override
  State<JniExamplePage> createState() => _JniExamplePageState();
}

class _JniExamplePageState extends State<JniExamplePage> {
  String _packageName = 'Unknown';
  String _className = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getAndroidInfo();
  }

  void _getAndroidInfo() {
    try {
      final context = androidApplicationContext;
      final contextClass = context.jClass;

      final getPackageNameId = contextClass.instanceMethodId(
        'getPackageName',
        '()Ljava/lang/String;',
      );

      final packageName = getPackageNameId.call(context, JString.type, []);

      setState(() {
        _packageName = packageName.toDartString(releaseOriginal: true);
        _className = contextClass.toString();
      });

      contextClass.release();
      // We don't release androidApplicationContext as it's a global singleton
      // in jni_flutter.
    } catch (e) {
      setState(() {
        _packageName = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JNI Flutter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainType.center.toMainAxisAlignment(),
          children: [
            Text('Package Name: $_packageName'),
            const SizedBox(height: 10),
            Text('Context Class: $_className'),
          ],
        ),
      ),
    );
  }
}

// Just a helper to show off some Dart 3.7 features if possible,
// but let's stick to the basics first.
enum MainType {
  center;

  MainAxisAlignment toMainAxisAlignment() => switch (this) {
    MainType.center => MainAxisAlignment.center,
  };
}
