// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:maven_libs/maven_libs.dart';
import 'package:jni/jni.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _runTest();
  }

  void _runTest() {
    try {
      final builder = OkHttpClient$Builder();
      final client = builder.build();

      final gson = Gson();
      final map = JHashMap<JString, JString>();
      map.asDart()['abc'.toJString()] = '123'.toJString();
      map.asDart()['def'.toJString()] = '456'.toJString();

      final json = gson.toJson(map.as(JObject.type))!.toDartString();

      setState(() {
        _status = '''
JSON from Gson: $json
OkHttpClient: ${client.toString()}''';
      });

      // Cleanup
      map.release();
      gson.release();
      client?.release();
      builder.release();
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Maven Libs')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
