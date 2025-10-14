// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jni/jni.dart';

// The hierarchy created in generated code will mirror the java package
// structure.
import 'android_utils.g.dart';

JObject context = Jni.androidApplicationContext(
  PlatformDispatcher.instance.engineId!,
);

final hashmap = HashMap(K: JString.type, V: JString.type);

final emojiCompat = EmojiCompat.get();

extension IntX on int {
  JString toJString() {
    return toString().toJString();
  }
}

const sunglassEmoji = "😎";

/// Display device model number and the number of times this was called
/// as Toast.
void showToast(JObject activity) {
  final toastCount = hashmap.getOrDefault(
    "toastCount".toJString(),
    0.toJString(),
  );
  final newToastCount = (int.parse(toastCount!.toDartString()) + 1).toJString();
  hashmap.put("toastCount".toJString(), newToastCount);
  final emoji = emojiCompat.hasEmojiGlyph(sunglassEmoji.toJString())
      ? sunglassEmoji
      : ':cool:';
  final message =
      '${newToastCount.toDartString()} - ${Build.MODEL!.toDartString()} $emoji';
  AndroidUtils.showToast(activity, message.toJString(), 0);
}

void main() {
  EmojiCompat.init(context);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Stream<JObject?> activityStream;

  @override
  void initState() {
    activityStream = Jni.androidActivities(
      PlatformDispatcher.instance.engineId!,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: activityStream,
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
          return Container();
        }
        final activity = asyncSnapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('Show Device Model'),
                  onPressed: () => showToast(activity),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
