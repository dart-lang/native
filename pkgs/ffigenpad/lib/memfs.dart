// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:js_interop';
import 'dart:convert' as convert;
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

// adapted functions from https://emscripten.org/docs/api_reference/Filesystem-API.html#id2
extension type MemFS(JSObject _) implements JSObject {
  external JSArray<JSString> readdir(String path);
  external JSUint8Array readFile(String path, [JSObject? opts]);
  external void writeFile(String path, String data);
  external void unlink(String path);
  external void mkdir(String path);
  external void rmdir(String path);
  external void rename(String oldpath, String newpath);
  external String cwd();
  external void chdir(String path);
  external JSObject analyzePath(String path, bool dontResolveLastLink);
}

@JS('FS')
external MemFS get memfs;

class MemFSDirectory implements Directory {
  @override
  String path;

  MemFSDirectory(this.path);

  @override
  void createSync({bool recursive = false}) {
    memfs.mkdir(path);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MemFSFile implements File {
  @override
  String path;

  MemFSFile(this.path);

  @override
  MemFSFile get absolute => MemFSFile(path);

  @override
  void createSync({bool recursive = false, bool exclusive = false}) {
    memfs.writeFile(path, '');
  }

  @override
  void deleteSync({bool recursive = false}) {
    memfs.unlink(path);
  }

  @override
  bool existsSync() {
    return memfs
        .analyzePath(path, false)
        .getProperty<JSBoolean>('exists'.toJS)
        .toDart;
  }

  @override
  void writeAsStringSync(String contents,
      {FileMode mode = FileMode.write,
      convert.Encoding encoding = convert.utf8,
      bool flush = false}) {
    memfs.writeFile(path, contents);
  }

  @override
  Uint8List readAsBytesSync() {
    return memfs.readFile(path).toDart;
  }

  @override
  String readAsStringSync({convert.Encoding encoding = convert.utf8}) {
    return encoding.decode(readAsBytesSync());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MemFSIOOverrides extends IOOverrides {
  @override
  MemFSDirectory createDirectory(String path) {
    return MemFSDirectory(path);
  }

  @override
  MemFSFile createFile(String path) {
    return MemFSFile(path);
  }

  @override
  bool fsWatchIsSupported() {
    return false;
  }

  @override
  void setCurrentDirectory(String path) {
    memfs.chdir(path);
  }

  @override
  MemFSDirectory getCurrentDirectory() {
    return MemFSDirectory(memfs.cwd());
  }

  @override
  MemFSDirectory getSystemTempDirectory() {
    return MemFSDirectory("/tmp");
  }
}
