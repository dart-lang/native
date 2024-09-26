// Autogenerated by jnigen. DO NOT EDIT!

// ignore_for_file: annotate_overrides
// ignore_for_file: argument_type_not_assignable
// ignore_for_file: camel_case_extensions
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: doc_directive_unknown
// ignore_for_file: file_names
// ignore_for_file: inference_failure_on_untyped_parameter
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
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// ignore_for_file: unused_import
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_shown_name
// ignore_for_file: use_super_parameters

import 'dart:core' show Object, String, bool, double, int;
import 'dart:core' as _$core;

import 'package:jni/_internal.dart' as _$jni;
import 'package:jni/jni.dart' as _$jni;

/// from: `Example`
class Example extends _$jni.JObject {
  @_$jni.internal
  @_$core.override
  final _$jni.JObjType<Example> $type;

  @_$jni.internal
  Example.fromReference(
    _$jni.JReference reference,
  )   : $type = type,
        super.fromReference(reference);

  static final _class = _$jni.JClass.forName(r'Example');

  /// The type which includes information such as the signature of this class.
  static const type = $Example$Type();
  static final _id_new$ = _class.constructorId(
    r'()V',
  );

  static final _new$ = _$jni.ProtectedJniExtensions.lookup<
          _$jni.NativeFunction<
              _$jni.JniResult Function(
                _$jni.Pointer<_$jni.Void>,
                _$jni.JMethodIDPtr,
              )>>('globalEnv_NewObject')
      .asFunction<
          _$jni.JniResult Function(
            _$jni.Pointer<_$jni.Void>,
            _$jni.JMethodIDPtr,
          )>();

  /// from: `public void <init>()`
  /// The returned object must be released after use, by calling the [release] method.
  factory Example() {
    return Example.fromReference(
        _new$(_class.reference.pointer, _id_new$ as _$jni.JMethodIDPtr)
            .reference);
  }

  static final _id_thinkBeforeAnswering = _class.instanceMethodId(
    r'thinkBeforeAnswering',
    r'(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;',
  );

  static final _thinkBeforeAnswering = _$jni.ProtectedJniExtensions.lookup<
              _$jni.NativeFunction<
                  _$jni.JniResult Function(
                      _$jni.Pointer<_$jni.Void>,
                      _$jni.JMethodIDPtr,
                      _$jni.VarArgs<(_$jni.Pointer<_$jni.Void>,)>)>>(
          'globalEnv_CallObjectMethod')
      .asFunction<
          _$jni.JniResult Function(_$jni.Pointer<_$jni.Void>,
              _$jni.JMethodIDPtr, _$jni.Pointer<_$jni.Void>)>();

  /// from: `public final java.lang.Object thinkBeforeAnswering(kotlin.coroutines.Continuation continuation)`
  /// The returned object must be released after use, by calling the [release] method.
  _$core.Future<_$jni.JString> thinkBeforeAnswering() async {
    final $p = _$jni.ReceivePort();
    final $c = _$jni.JObject.fromReference(
        _$jni.ProtectedJniExtensions.newPortContinuation($p));
    _thinkBeforeAnswering(
            reference.pointer,
            _id_thinkBeforeAnswering as _$jni.JMethodIDPtr,
            $c.reference.pointer)
        .object(const _$jni.JObjectType());
    final $o =
        _$jni.JGlobalReference(_$jni.JObjectPtr.fromAddress(await $p.first));
    final $k = const _$jni.JStringType().jClass.reference.pointer;
    if (!_$jni.Jni.env.IsInstanceOf($o.pointer, $k)) {
      throw 'Failed';
    }
    return const _$jni.JStringType().fromReference($o);
  }
}

final class $Example$Type extends _$jni.JObjType<Example> {
  @_$jni.internal
  const $Example$Type();

  @_$jni.internal
  @_$core.override
  String get signature => r'LExample;';

  @_$jni.internal
  @_$core.override
  Example fromReference(_$jni.JReference reference) =>
      Example.fromReference(reference);

  @_$jni.internal
  @_$core.override
  _$jni.JObjType get superType => const _$jni.JObjectType();

  @_$jni.internal
  @_$core.override
  final superCount = 1;

  @_$core.override
  int get hashCode => ($Example$Type).hashCode;

  @_$core.override
  bool operator ==(Object other) {
    return other.runtimeType == ($Example$Type) && other is $Example$Type;
  }
}
