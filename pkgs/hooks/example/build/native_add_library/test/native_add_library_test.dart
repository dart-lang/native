// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:native_add_library/native_add_library.dart';
import 'package:test/test.dart';

// Symbols currently in use by io_file:
// errno
// close
// open
// getenv
// fstat
// rename
// unlinkat
// mkdtemp
// mkdir
// stat
// strerror
// error constants
// + 5 or 6 constants
void main() {
  test(
    'invoke native function',
    () => using((arena) {
      final fd = open('foobarbaz'.toNativeUtf8(allocator: arena).cast(), 0, 0);
      print('fd: $fd');
      print('errno: $errno');

      final s = arena<Stat>();
      final r = stat('/'.toNativeUtf8(allocator: arena).cast(), s);
      print(r);
      print(s.ref.st_dev);
      print(s.ref.st_ino);
      print(s.ref.st_mode);
      print(s.ref.st_btime.tv_sec);

      print('UF_HIDDEN: $UF_HIDDEN');
      print('S_IFMT: $S_IFMT');

      final d = opendir('/'.toNativeUtf8(allocator: arena).cast());
      if (d == nullptr) {
        print('open failed');
      }
      final h = readdir(d);
      final b = StringBuffer();
      for (var i = 0; ; i++) {
        if (h.ref.d_name[i] == 0) {
          print(b);
          break;
        } else {
          b.writeCharCode(h.ref.d_name[i]);
        }
      }
      closedir(d);
    }),
  );
}
