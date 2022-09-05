// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/jni_gen.dart';

void main(List<String> args) async {
  final config = Config(
    sourcePath: [Uri.directory('android/app/src/main/java')],
    classes: ['com.example.in_app_java.AndroidUtils'],
    cRoot: Uri.directory('src/android_utils'),
    dartRoot: Uri.directory('lib/android_utils'),
    libraryName: 'android_utils',
    androidSdkConfig: AndroidSdkConfig(
      addGradleDeps: true,
    ),
  );
  await generateJniBindings(config);
}
