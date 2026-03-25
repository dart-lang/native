// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni/jni.dart';

import 'generated_plugin.dart';

/// Retrieves the global Android `ApplicationContext` associated with a
/// Flutter engine.
///
/// The `ApplicationContext` is a long-lived singleton tied to the
/// application's lifecycle. It is safe to store and use from any thread.
JObject get androidApplicationContext => JniFlutterPlugin.applicationContext;

/// Retrieves the current Android `Activity` associated with a Flutter engine.
///
/// The `engineId` can be obtained from `PlatformDispatcher.instance.engineId`
/// in Dart.
///
/// **WARNING: This reference is volatile and must be used with care.**
///
/// The Android `Activity` lifecycle is asynchronous. The `Activity` returned
/// by this function can become `null` or stale (destroyed) at any moment,
/// such as during screen rotation or when the app is backgrounded.
///
/// To prevent native crashes, this function has two strict usage rules:
///
/// 1. **Platform Thread Only**: It must *only* be called from the platform
///     thread.
/// 2. **Synchronous Use Only**: The returned `JObject` must be used
///     immediately and synchronously, with no asynchronous gaps (`await`).
///
/// Do not store the returned `JObject` in a field or local variable that
/// persists across an `await`.
///
/// ---
///
/// ### Correct Usage (Synchronous, "Get-and-Use"):
///
/// ```dart
/// void safeCall() {
///   // This is safe because the `Activity` is retrieved and used
///   // in a single, unbroken, synchronous block.
///   final activity = Jni.androidActivity(engineId);
///   if (activity != null) {
///     someGeneratedApi.doSomething(activity);
///     activity.release();
///   }
/// }
/// ```
///
/// ### **DANGEROUS** Usage (Asynchronous Gap):
///
/// ```dart
/// Future<void> dangerousCall() async {
///   // 1. Get the Activity (e.g., Activity "A")
///   final activity = Jni.androidActivity(engineId);
///
///   // 2. An `await` occurs. The main thread is freed.
///   //    While waiting, Android might destroy Activity "A" and create "B".
///   await someOtherFuture();
///
///   // 3. CRASH: The code resumes, but `activity` is now a stale
///   //    reference to the destroyed Activity "A".
///   if (activity != null) {
///     someGeneratedApi.doSomething(activity); // This will crash
///     activity.release();
///   }
/// }
/// ```
JObject? androidActivity(int engineId) =>
    JniFlutterPlugin.getActivity(engineId);
