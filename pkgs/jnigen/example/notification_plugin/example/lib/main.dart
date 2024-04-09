// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:jni/jni.dart';

// The hierarchy created in generated code will mirror the java package
// structure. This is an implementation convenience and we may allow
// more customization in future.
import 'package:notification_plugin/notifications.dart';

JObject activity = JObject.fromReference(Jni.getCurrentActivity());

int i = 0;

void showNotification(String title, String text) {
  i = i + 1;
  var jTitle = JString.fromString(title);
  var jText = JString.fromString(text);
  Notifications.showNotification(activity, i, jTitle, jText);
  jTitle.release();
  jText.release();
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  final _title = TextEditingController(text: 'Hello from JNI');
  final _text = TextEditingController(text: '😀');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    const InputDecoration(labelText: 'Notification title'),
              ),
              TextFormField(
                controller: _text,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                decoration:
                    const InputDecoration(labelText: 'Notification text'),
              ),
              ElevatedButton(
                child: const Text('Show Notification'),
                onPressed: () => showNotification(_title.text, _text.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
