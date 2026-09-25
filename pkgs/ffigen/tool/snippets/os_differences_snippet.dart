// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'dart:io';

class MacSpecificBar {}

class IosSpecificBar {}

class Foo {
  void macSpecificMethod(MacSpecificBar bar) {}
  void iosSpecificMethod(IosSpecificBar bar) {}
}

void singleWrapperExample() {
  // snippet-start#single_wrapper
  final foo = Foo();
  if (Platform.isMacOS) {
    final bar = MacSpecificBar();
    foo.macSpecificMethod(bar);
  } else {
    assert(Platform.isIOS);
    final bar = IosSpecificBar();
    foo.iosSpecificMethod(bar);
  }
  // snippet-end#single_wrapper
}

class WKWebViewMacOS {}

class WKWebViewIOS {}

void renamedApisExample() {
  // snippet-start#renamed_apis
  if (Platform.isMacOS) {
    final webView = WKWebViewMacOS();
    // ...
  } else {
    assert(Platform.isIOS);
    final webView = WKWebViewIOS();
    // ...
  }
  // snippet-end#renamed_apis
}
