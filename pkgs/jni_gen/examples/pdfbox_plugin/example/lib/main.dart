import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

import 'dart:ffi'; // for nullptr :=
import 'package:jni/jni.dart';
import 'package:path/path.dart';

// Import the generated bindings.
// Note: the structure generated bindings corresponds to Java package's
// structure. Therefore, `org.apache.pdfbox.pdmodel` package becomes
// `org/apache/pdfbox/pdmodel.dart`
import 'package:pdfbox_plugin/third_party/org/apache/pdfbox/pdmodel.dart';

Stream<String> files(String dir) => Directory(dir).list().map((e) => e.path);

late Jni jni;
const jarError = 'No JAR files were found.\n'
    'Run `dart run jni_gen:download_maven_jars --config jnigen.yaml` '
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
  jni = Jni.getInstance();
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

  /// Converts JlString to dart string and deletes the original.
  String _fromJavaStr(JlString jstr) {
    if (jstr.reference == nullptr) {
      return '(null)';
    }
    final result = jstr.toDartString();
    jstr.delete();
    return result;
  }

  PDFFileInfo.usingPDFBox(this.filename) {
    // Since java.io is not directly available, use package:jni API to
    // create a java.io.File object.
    final inputFile =
        jni.newInstance("java/io/File", "(Ljava/lang/String;)V", [filename]);
    final inputJl = JlObject.fromRef(inputFile.jobject);

    // Static method call PDDocument.load -> PDDocument
    final pdf = PDDocument.load(inputJl);
    // Instance method call getNumberOfPages() -> int
    numPages = pdf.getNumberOfPages();
    // Instance method that returns an object
    final info = pdf.getDocumentInformation();

    /// java.lang.String is a special case and is mapped to JlString which is
    /// a subclass of JlObject.
    author = _fromJavaStr(info.getAuthor());
    title = _fromJavaStr(info.getTitle());
    subject = _fromJavaStr(info.getSubject());

    /// Delete objects after done.
    info.delete();
    pdf.close();
    pdf.delete();
    inputFile.delete();
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
