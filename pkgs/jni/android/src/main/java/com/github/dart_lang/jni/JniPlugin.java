// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class JniPlugin implements FlutterPlugin {
  @Override
  @SuppressWarnings("deprecation")
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  static native void setClassLoader(ClassLoader classLoader);

  static {
    System.loadLibrary("dartjni");
    setClassLoader(JniPlugin.class.getClassLoader());
  }
}
