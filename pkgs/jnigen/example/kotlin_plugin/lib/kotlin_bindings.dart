// Autogenerated by jnigen. DO NOT EDIT!

// ignore_for_file: annotate_overrides
// ignore_for_file: argument_type_not_assignable
// ignore_for_file: camel_case_extensions
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: doc_directive_unknown
// ignore_for_file: file_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: only_throw_errors
// ignore_for_file: overridden_fields
// ignore_for_file: prefer_double_quotes
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// ignore_for_file: unused_import
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_shown_name
// ignore_for_file: use_super_parameters

import 'dart:ffi' as ffi;
import 'dart:isolate' show ReceivePort;

import 'package:jni/internal_helpers_for_jnigen.dart';
import 'package:jni/jni.dart' as jni;

/// from: `Example`
class Example extends jni.JObject {
  @override
  late final jni.JObjType<Example> $type = type;

  Example.fromReference(
    jni.JReference reference,
  ) : super.fromReference(reference);

  static final _class = jni.JClass.forName(r'Example');

  /// The type which includes information such as the signature of this class.
  static const type = $ExampleType();
  static final _id_new$ = _class.constructorId(
    r'()V',
  );

  static final _new$ = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>('globalEnv_NewObject')
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: `public void <init>()`
  /// The returned object must be released after use, by calling the [release] method.
  factory Example() {
    return Example.fromReference(
        _new$(_class.reference.pointer, _id_new$ as jni.JMethodIDPtr)
            .reference);
  }

  static final _id_thinkBeforeAnswering = _class.instanceMethodId(
    r'thinkBeforeAnswering',
    r'(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;',
  );

  static final _thinkBeforeAnswering = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          'globalEnv_CallObjectMethod')
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: `public final java.lang.Object thinkBeforeAnswering(kotlin.coroutines.Continuation continuation)`
  /// The returned object must be released after use, by calling the [release] method.
  Future<jni.JString> thinkBeforeAnswering() async {
    final $p = ReceivePort();
    final $c = jni.JObject.fromReference(
        ProtectedJniExtensions.newPortContinuation($p));
    _thinkBeforeAnswering(reference.pointer,
            _id_thinkBeforeAnswering as jni.JMethodIDPtr, $c.reference.pointer)
        .object(const jni.JObjectType());
    final $o = jni.JGlobalReference(jni.JObjectPtr.fromAddress(await $p.first));
    final $k = const jni.JStringType().jClass.reference.pointer;
    if (!jni.Jni.env.IsInstanceOf($o.pointer, $k)) {
      throw 'Failed';
    }
    return const jni.JStringType().fromReference($o);
  }
}

final class $ExampleType extends jni.JObjType<Example> {
  const $ExampleType();

  @override
  String get signature => r'LExample;';

  @override
  Example fromReference(jni.JReference reference) =>
      Example.fromReference(reference);

  @override
  jni.JObjType get superType => const jni.JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($ExampleType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($ExampleType) && other is $ExampleType;
  }
}
