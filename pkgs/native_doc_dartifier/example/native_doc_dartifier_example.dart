// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_doc_dartifier/src/dartify_code.dart';
import 'package:native_doc_dartifier/src/context.dart';

void main() async {
  const code = '''public void onClick() {
    ImageCapture.OutputFileOptions outputFileOptions =
            new ImageCapture.OutputFileOptions.Builder(new File("...")).build();
    imageCapture.takePicture(outputFileOptions, cameraExecutor,
        new ImageCapture.OnImageSavedCallback() {
            @Override
            public void onImageSaved(ImageCapture.OutputFileResults outputFileResults) {
                // insert your code here.
            }
            @Override
            public void onError(ImageCaptureException error) {
                // insert your code here.
            }
       }
    );
}
''';

  final bindingsFile = File('example/camerax.dart');

  final bindingsPath = bindingsFile.absolute.path;

  try {
    final context = await Context.create(Directory.current.path, bindingsPath);
    final dartCode = await dartifyNativeCode(code, context);
    print(dartCode);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
