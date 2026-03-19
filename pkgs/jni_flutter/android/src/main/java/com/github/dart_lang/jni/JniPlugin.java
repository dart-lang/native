// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

public class JniPlugin implements FlutterPlugin, ActivityAware {
  private static final ConcurrentHashMap<Long, JniPlugin> pluginMap = new ConcurrentHashMap<>();

  private long engineId;

  @SuppressLint("StaticFieldLeak")
  private static Context context;

  private volatile Activity activity;

  public static @NonNull Context getApplicationContext() {
    return context;
  }

  public static @Nullable Activity getActivity(long engineId) {
    return Objects.requireNonNull(pluginMap.get(engineId)).activity;
  }

  @Override
  @SuppressWarnings("deprecation")
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    //noinspection deprecation
    engineId = binding.getFlutterEngine().getEngineId();
    context = binding.getApplicationContext();
    pluginMap.put(engineId, this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    activity = null;
    pluginMap.remove(engineId);
  }

  private void setActivity(Activity newActivity) {
    activity = newActivity;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    setActivity(null);
  }

  static native void setClassLoader(ClassLoader classLoader);

  static {
    System.loadLibrary("dartjni");
    setClassLoader(JniPlugin.class.getClassLoader());
  }
}
