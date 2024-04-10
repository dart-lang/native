// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Autogenerated by jnigen. DO NOT EDIT!

// ignore_for_file: annotate_overrides
// ignore_for_file: camel_case_extensions
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: doc_directive_unknown
// ignore_for_file: file_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: overridden_fields
// ignore_for_file: unnecessary_cast
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// ignore_for_file: unused_import
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_shown_name
// ignore_for_file: use_super_parameters

import "dart:isolate" show ReceivePort;
import "dart:ffi" as ffi;
import "package:jni/internal_helpers_for_jnigen.dart";
import "package:jni/jni.dart" as jni;

// Auto-generated initialization code.

final ffi.Pointer<T> Function<T extends ffi.NativeType>(String sym) jniLookup =
    ProtectedJniExtensions.initGeneratedLibrary("notification_plugin");

/// from: com.example.notification_plugin.Notifications
class Notifications extends jni.JObject {
  @override
  late final jni.JObjType<Notifications> $type = type;

  Notifications.fromReference(
    jni.JReference reference,
  ) : super.fromReference(reference);

  /// The type which includes information such as the signature of this class.
  static const type = $NotificationsType();
  static final _new0 = jniLookup<ffi.NativeFunction<jni.JniResult Function()>>(
          "Notifications__new0")
      .asFunction<jni.JniResult Function()>();

  /// from: public void <init>()
  /// The returned object must be released after use, by calling the [release] method.
  factory Notifications() {
    return Notifications.fromReference(_new0().reference);
  }

  static final _showNotification = jniLookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                  ffi.Pointer<ffi.Void>,
                  ffi.Int32,
                  ffi.Pointer<ffi.Void>,
                  ffi.Pointer<ffi.Void>)>>("Notifications__showNotification")
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, int,
              ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Void>)>();

  /// from: static public void showNotification(android.content.Context context, int notificationID, java.lang.String title, java.lang.String text)
  static void showNotification(
    jni.JObject context,
    int notificationID,
    jni.JString title,
    jni.JString text,
  ) {
    _showNotification(context.reference.pointer, notificationID,
            title.reference.pointer, text.reference.pointer)
        .check();
  }
}

final class $NotificationsType extends jni.JObjType<Notifications> {
  const $NotificationsType();

  @override
  String get signature => r"Lcom/example/notification_plugin/Notifications;";

  @override
  Notifications fromReference(jni.JReference reference) =>
      Notifications.fromReference(reference);

  @override
  jni.JObjType get superType => const jni.JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($NotificationsType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($NotificationsType) &&
        other is $NotificationsType;
  }
}
