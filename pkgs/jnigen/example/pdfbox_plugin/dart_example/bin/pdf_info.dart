// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart';
import 'package:jni/jni.dart';

import 'package:pdfbox_plugin/pdfbox_plugin.dart';

void writeInfo(String file) {
  final fileInputStreamClass = JClass.forName("java/io/FileInputStream");
  final inputFile = fileInputStreamClass
      .constructorId("(Ljava/lang/String;)V")
      .call(fileInputStreamClass, JObject.type, [file.toJString()]);
  final pdDoc = PDDocument.load6(inputFile);
  int pages = pdDoc.getNumberOfPages();
  final info = pdDoc.getDocumentInformation();
  final title = info.getTitle();
  final subject = info.getSubject();
  final author = info.getAuthor();
  stderr.writeln('Number of pages: $pages');

  if (!title.isNull) {
    stderr.writeln('Title: ${title.toDartString()}');
  }

  if (!subject.isNull) {
    stderr.writeln('Subject: ${subject.toDartString()}');
  }

  if (!author.isNull) {
    stderr.writeln('Author: ${author.toDartString()}');
  }

  stderr.writeln('PDF Version: ${pdDoc.getVersion().toStringAsPrecision(2)}');
}

final jniLibsDir = join('build', 'jni_libs');

const jarError = 'No JAR files were found.\n'
    'Run `dart run jnigen:download_maven_jars --config jnigen.yaml` '
    'in plugin directory.\n'
    'Alternatively, regenerate JNI bindings in plugin directory, which will '
    'automatically download the JAR files.';

void main(List<String> arguments) {
  final jarDir = join('..', 'mvn_jar');
  List<String> jars;
  try {
    jars = Directory(jarDir)
        .listSync()
        .map((e) => e.path)
        .where((path) => path.endsWith('.jar'))
        .toList();
  } on OSError catch (_) {
    stderr.writeln(jarError);
    return;
  }
  if (jars.isEmpty) {
    stderr.writeln(jarError);
    return;
  }
  Jni.spawn(dylibDir: jniLibsDir, classPath: jars);
  if (arguments.length != 1) {
    stderr.writeln('usage: dart run pdf_info:pdf_info <Path_to_PDF>');
    exitCode = 1;
    return;
  }
  writeInfo(arguments[0]);
}
