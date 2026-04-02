// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui';

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
  String _packageName = '';
  String _activity = '';

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

      final packageName = getPackageNameId
          .call(context, JString.type, [])
          .toDartString(releaseOriginal: true);

      final activity = androidActivity(PlatformDispatcher.instance.engineId!);
      final activityString = activity?.jClass.toString() ?? 'no activity';

      activity?.release();
      contextClass.release();
      context.release();

      setState(() {
        _packageName = packageName;
        _activity = activityString;
      });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Package name:'),
            Text(_packageName),
            const SizedBox(height: 20),
            Text('Activity:'),
            Text(_activity),
          ],
        ),
      ),
    );
  }
}
