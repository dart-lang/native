// AUTO GENERATED BY JNIGEN 0.14.2. DO NOT EDIT!

// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: annotate_overrides
// ignore_for_file: argument_type_not_assignable
// ignore_for_file: camel_case_extensions
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: comment_references
// ignore_for_file: doc_directive_unknown
// ignore_for_file: file_names
// ignore_for_file: inference_failure_on_untyped_parameter
// ignore_for_file: invalid_internal_annotation
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: library_prefixes
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: no_leading_underscores_for_library_prefixes
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: only_throw_errors
// ignore_for_file: overridden_fields
// ignore_for_file: prefer_double_quotes
// ignore_for_file: unintended_html_in_doc_comment
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// ignore_for_file: unused_import
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_shown_name
// ignore_for_file: use_super_parameters

import 'dart:core' show Object, String, bool, double, int;
import 'dart:core' as core$_;

import 'package:jni/_internal.dart' as jni$_;
import 'package:jni/jni.dart' as jni$_;

/// from: `com.example.notification_plugin.Notifications`
class Notifications extends jni$_.JObject {
  @jni$_.internal
  @core$_.override
  final jni$_.JObjType<Notifications> $type;

  @jni$_.internal
  Notifications.fromReference(
    jni$_.JReference reference,
  )   : $type = type,
        super.fromReference(reference);

  static final _class =
      jni$_.JClass.forName(r'com/example/notification_plugin/Notifications');

  /// The type which includes information such as the signature of this class.
  static const nullableType = $Notifications$NullableType();
  static const type = $Notifications$Type();
  static final _id_new$ = _class.constructorId(
    r'()V',
  );

  static final _new$ = jni$_.ProtectedJniExtensions.lookup<
          jni$_.NativeFunction<
              jni$_.JniResult Function(
                jni$_.Pointer<jni$_.Void>,
                jni$_.JMethodIDPtr,
              )>>('globalEnv_NewObject')
      .asFunction<
          jni$_.JniResult Function(
            jni$_.Pointer<jni$_.Void>,
            jni$_.JMethodIDPtr,
          )>();

  /// from: `public void <init>()`
  /// The returned object must be released after use, by calling the [release] method.
  factory Notifications() {
    return Notifications.fromReference(
        _new$(_class.reference.pointer, _id_new$ as jni$_.JMethodIDPtr)
            .reference);
  }

  static final _id_showNotification = _class.staticMethodId(
    r'showNotification',
    r'(Landroid/content/Context;ILjava/lang/String;Ljava/lang/String;)V',
  );

  static final _showNotification = jni$_.ProtectedJniExtensions.lookup<
          jni$_.NativeFunction<
              jni$_.JThrowablePtr Function(
                  jni$_.Pointer<jni$_.Void>,
                  jni$_.JMethodIDPtr,
                  jni$_.VarArgs<
                      (
                        jni$_.Pointer<jni$_.Void>,
                        jni$_.Int32,
                        jni$_.Pointer<jni$_.Void>,
                        jni$_.Pointer<jni$_.Void>
                      )>)>>('globalEnv_CallStaticVoidMethod')
      .asFunction<
          jni$_.JThrowablePtr Function(
              jni$_.Pointer<jni$_.Void>,
              jni$_.JMethodIDPtr,
              jni$_.Pointer<jni$_.Void>,
              int,
              jni$_.Pointer<jni$_.Void>,
              jni$_.Pointer<jni$_.Void>)>();

  /// from: `static public void showNotification(android.content.Context context, int notificationID, java.lang.String title, java.lang.String text)`
  static void showNotification(
    jni$_.JObject? context,
    int notificationID,
    jni$_.JString? title,
    jni$_.JString? text,
  ) {
    final _$context = context?.reference ?? jni$_.jNullReference;
    final _$title = title?.reference ?? jni$_.jNullReference;
    final _$text = text?.reference ?? jni$_.jNullReference;
    _showNotification(
            _class.reference.pointer,
            _id_showNotification as jni$_.JMethodIDPtr,
            _$context.pointer,
            notificationID,
            _$title.pointer,
            _$text.pointer)
        .check();
  }
}

final class $Notifications$NullableType extends jni$_.JObjType<Notifications?> {
  @jni$_.internal
  const $Notifications$NullableType();

  @jni$_.internal
  @core$_.override
  String get signature => r'Lcom/example/notification_plugin/Notifications;';

  @jni$_.internal
  @core$_.override
  Notifications? fromReference(jni$_.JReference reference) => reference.isNull
      ? null
      : Notifications.fromReference(
          reference,
        );
  @jni$_.internal
  @core$_.override
  jni$_.JObjType get superType => const jni$_.JObjectNullableType();

  @jni$_.internal
  @core$_.override
  jni$_.JObjType<Notifications?> get nullableType => this;

  @jni$_.internal
  @core$_.override
  final superCount = 1;

  @core$_.override
  int get hashCode => ($Notifications$NullableType).hashCode;

  @core$_.override
  bool operator ==(Object other) {
    return other.runtimeType == ($Notifications$NullableType) &&
        other is $Notifications$NullableType;
  }
}

final class $Notifications$Type extends jni$_.JObjType<Notifications> {
  @jni$_.internal
  const $Notifications$Type();

  @jni$_.internal
  @core$_.override
  String get signature => r'Lcom/example/notification_plugin/Notifications;';

  @jni$_.internal
  @core$_.override
  Notifications fromReference(jni$_.JReference reference) =>
      Notifications.fromReference(
        reference,
      );
  @jni$_.internal
  @core$_.override
  jni$_.JObjType get superType => const jni$_.JObjectNullableType();

  @jni$_.internal
  @core$_.override
  jni$_.JObjType<Notifications?> get nullableType =>
      const $Notifications$NullableType();

  @jni$_.internal
  @core$_.override
  final superCount = 1;

  @core$_.override
  int get hashCode => ($Notifications$Type).hashCode;

  @core$_.override
  bool operator ==(Object other) {
    return other.runtimeType == ($Notifications$Type) &&
        other is $Notifications$Type;
  }
}
