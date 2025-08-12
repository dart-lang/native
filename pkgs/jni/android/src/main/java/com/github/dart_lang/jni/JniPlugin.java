// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.github.dart_lang.jni;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

public class JniPlugin implements FlutterPlugin, ActivityAware {
  private static final ConcurrentHashMap<Long, JniPlugin> pluginMap = new ConcurrentHashMap<>();

  private long engineId;
  private Context context;
  private Activity activity;
  private final List<ActivityListener> activityListeners = new ArrayList<>();

  public static @NonNull Context getApplicationContext(long engineId) {
    return Objects.requireNonNull(pluginMap.get(engineId)).context;
  }

  public interface ActivityListener {
    void onActivityChanged(Activity activity);
  }

  public static void addActivityListener(long engineId, @NonNull ActivityListener listener) {
    var plugin = Objects.requireNonNull(pluginMap.get(engineId));
    plugin.activityListeners.add(listener);
    listener.onActivityChanged(plugin.activity);
  }

  public static void removeActivityListener(long engineId, @NonNull ActivityListener listener) {
    var plugin = Objects.requireNonNull(pluginMap.get(engineId));
    plugin.activityListeners.remove(listener);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    //noinspection deprecation
    engineId = binding.getFlutterEngine().getEngineId();
    context = binding.getApplicationContext();
    pluginMap.put(engineId, this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    context = null;
    activity = null;
    pluginMap.remove(engineId);
  }

  private void notifyActivityListeners() {
    for (var listener : activityListeners) {
      listener.onActivityChanged(activity);
    }
  }

  private void setActivity(Activity newActivity) {
    activity = newActivity;
    notifyActivityListeners();
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
