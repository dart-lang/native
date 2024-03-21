// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

import 'package:jni/jni.dart';
import 'package:path/path.dart';

import 'package:pdfbox_plugin/pdfbox_plugin.dart';

Stream<String> files(String dir) => Directory(dir).list().map((e) => e.path);

const jarError = 'No JAR files were found.\n'
    'Run `dart run jnigen:download_maven_jars --config jnigen.yaml` '
    'in plugin directory.\n'
    'Alternatively, regenerate JNI bindings in plugin directory, which will '
    'automatically download the JAR files.';

void main() {
  if (!Platform.isAndroid) {
    // Assuming application is run from example/ folder
    // It's required to manually provide the JAR files as classpath when
    // spawning the JVM.
    const jarDir = '../mvn_jar/';
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
    Jni.spawn(classPath: jars);
  }
  runApp(const PDFInfoApp());
}

class PDFInfoApp extends StatefulWidget {
  const PDFInfoApp({super.key});

  @override
  PDFInfoAppState createState() => PDFInfoAppState();
}

class PDFInfoAppState extends State<PDFInfoApp> {
  bool _isLoading = true;
  String _dir = '.';
  List<String> _pdfs = [];
  List<String> _dirs = [];

  void setDir(String dir) async {
    final pdfs = <String>[];
    final dirs = <String>[];

    setState(() => _isLoading = true);

    await for (var item in Directory(dir).list()) {
      final isDir = (await item.stat()).type == FileSystemEntityType.directory;
      if (item.path.endsWith('.pdf') && !isDir) {
        pdfs.add(item.path);
      } else if (isDir) {
        dirs.add(item.path);
      }
    }
    setState(() {
      _isLoading = false;
      _dir = dir;
      _pdfs = pdfs;
      _dirs = dirs;
    });
  }

  @override
  void initState() {
    super.initState();
    final dir = Platform.environment['HOME'] ?? '.';
    setDir(dir);
  }

  @override
  Widget build(BuildContext context) {
    final dirBaseName = basename(_dir);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('PDF Info: $dirBaseName'),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(10),
              child: _isLoading
                  ? const Text('loading...')
                  : Table(border: TableBorder.all(), children: [
                      TableRow(children: [
                        for (var heading in ['File', 'Title', 'Pages'])
                          TableCell(
                              child: _pad(Text(heading,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      decoration: TextDecoration.underline)))),
                      ]),
                      TableRow(children: [
                        TableCell(
                          child: _pad(
                            InkWell(
                              child: const Text('..'),
                              onTap: () => setDir(dirname(_dir)),
                            ),
                          ),
                        ),
                        const TableCell(child: Text('')),
                        const TableCell(child: Text('')),
                      ]),
                      for (var dir in _dirs) _dirTile(basename(dir)),
                      for (var pdfname in _pdfs)
                        _pdfInfo(PDFFileInfo.usingPDFBox(pdfname)),
                    ])),
        ),
      ),
    );
  }

  TableRow _dirTile(String target) {
    return TableRow(children: [
      TableCell(
        child: _pad(
          InkWell(
            onTap: () => setDir(join(_dir, target)),
            child: Text(
              target,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      const TableCell(child: Text('-')),
      const TableCell(child: Text('-')),
    ]);
  }
}

// It's generally a good practice to separate JNI calls from UI / model code.
class PDFFileInfo {
  String filename;
  late String author, subject, title;
  late int numPages;

  /// Converts JString to dart string and deletes the original.
  /// Also handles the case where the underlying string is Null.
  String _fromJavaStr(JString jstr) {
    if (jstr.reference.pointer == nullptr) {
      return '(null)';
    }
    return jstr.toDartString(releaseOriginal: true);
  }

  PDFFileInfo.usingPDFBox(this.filename) {
    // Since java.io is not directly available, use package:jni API to
    // create a java.io.File object.
    final fileClass = JClass.forName("java/io/File");
    final inputFile = fileClass
        .constructorId("(Ljava/lang/String;)V")
        .call(fileClass, JObject.type, [filename]);
    // Static method call PDDocument.load -> PDDocument
    final pdf = PDDocument.load(inputFile);
    // Instance method call getNumberOfPages() -> int
    numPages = pdf.getNumberOfPages();
    // Instance method that returns an object
    final info = pdf.getDocumentInformation();

    /// java.lang.String is a special case and is mapped to JlString which is
    /// a subclass of JlObject.
    author = _fromJavaStr(info.getAuthor());
    title = _fromJavaStr(info.getTitle());
    subject = _fromJavaStr(info.getSubject());

    pdf.close();
  }
}

Padding _pad(Widget w) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: w);

TableRow _pdfInfo(PDFFileInfo info) {
  return TableRow(children: [
    TableCell(
        child: _pad(Text(basename(info.filename),
            style: const TextStyle(fontWeight: FontWeight.bold)))),
    TableCell(child: _pad(Text(info.title))),
    TableCell(
        child: _pad(Text(info.numPages.toString(),
            style: const TextStyle(color: Colors.grey)))),
  ]);
}
