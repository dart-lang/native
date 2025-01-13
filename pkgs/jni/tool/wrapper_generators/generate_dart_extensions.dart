// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';

import 'ffigen_util.dart';
import 'generate_helper_functions.dart';
import 'logging.dart';

class Paths {
  static final currentDir = Directory.current.uri;
  static final bindingsDir = currentDir.resolve('lib/src/third_party/');
  // Contains extensions for our C wrapper types.
  static final globalEnvExts =
      bindingsDir.resolve('global_env_extensions.dart');
  // Contains extensions for JNI's struct types.
  static final localEnvExts =
      bindingsDir.resolve('jnienv_javavm_extensions.dart');
}

const writeLocalEnvExtensions = false;

void executeDartFormat(List<Uri> files) {
  final paths = files.map((u) => u.toFilePath()).toList();
  logger.info('execute dart format ${paths.join(" ")}');
  final format = Process.runSync('dart', ['format', ...paths]);
  if (format.exitCode != 0) {
    logger.severe('dart format exited with ${format.exitCode}');
    stderr.writeln(format.stderr);
  }
}

const globalEnvType = 'GlobalJniEnvStruct';
const localEnvType = 'JNINativeInterface';
const jvmType = 'JNIInvokeInterface';

String getCheckedGetter(Type returnType) {
  const objectPointerGetter = 'objectPointer';

  if (returnType is PointerType) {
    final child = returnType.child.getCType(dummyWriter);
    return 'getPointer<$child>()';
  }
  final cType = returnType.toString();
  if (cType.startsWith('j') && cType.endsWith('Array')) {
    return objectPointerGetter;
  }
  const mappings = {
    'jboolean': 'boolean',
    'jbyte': 'byte',
    'jshort': 'short',
    'jchar': 'char',
    'jint': 'integer',
    'jsize': 'integer', // jsize is aliased to jint
    'jlong': 'long',
    'jfloat': 'float',
    'jdouble': 'doubleFloat',
    'jobject': objectPointerGetter,
    'jobjectRefType': 'referenceType',
    'jthrowable': objectPointerGetter,
    'jstring': objectPointerGetter,
    'jclass': 'value',
    'jfieldID': 'fieldID',
    'jmethodID': 'methodID',
    'ffi.Int32': 'integer',
    'ffi.UnsignedInt': 'integer',
    'ffi.Void': 'check()',
    'jweak': objectPointerGetter,
  };
  if (mappings.containsKey(cType)) {
    return mappings[cType]!;
  }
  stderr.writeln('Unknown return type: $cType');
  exit(1);
}

String? getGlobalEnvExtensionFunction(
  CompoundMember field,
  Type? checkedReturnType, {
  required bool isLeaf,
}) {
  final fieldType = field.type;
  if (fieldType is PointerType && fieldType.child is NativeFunc) {
    final nativeFunc = fieldType.child as NativeFunc;
    final functionType = nativeFunc.type;
    final returnType = functionType.returnType;
    var params = functionType.parameters;
    if (params.first.name.isEmpty) {
      return null;
    }

    // Remove env parameter
    params = params.sublist(1);

    final signature = params
        .map((p) => '${p.type.getDartType(dummyWriter)} ${p.name}')
        .join(', ');

    final dartType =
        FunctionType(returnType: checkedReturnType!, parameters: params)
            .getDartType(dummyWriter);
    final callArgs = params.map((p) => p.name).join(', ');
    final checkedGetter = getCheckedGetter(returnType);
    var returns = returnType.getDartType(dummyWriter);
    if (checkedGetter == 'boolean') {
      returns = 'bool';
    }
    final leafCall = isLeaf ? 'isLeaf: true' : '';
    return '''
late final _${field.name} =
  ptr.ref.${field.name}.asFunction<$dartType>($leafCall);\n
$returns ${field.name}($signature) =>
  _${field.name}($callArgs).$checkedGetter;

''';
  }
  return null;
}

void writeDartExtensions(Library library) {
  const header = '''
// ignore_for_file: non_constant_identifier_names
// coverage:ignore-file

import 'dart:ffi' as ffi;

import '../accessors.dart';
import 'jni_bindings_generated.dart';

''';

  final globalEnvExtension = getGlobalEnvExtension(library);
  File.fromUri(Paths.globalEnvExts)
      .writeAsStringSync('$preamble$header$globalEnvExtension');
  final localEnvExtsFile = File.fromUri(Paths.localEnvExts);
  if (localEnvExtsFile.existsSync()) {
    localEnvExtsFile.deleteSync();
  }
  if (!writeLocalEnvExtensions) {
    return;
  }
  final envExtension = getFunctionPointerExtension(
    library,
    'JniEnv',
    'LocalJniEnv',
    indirect: true,
    implicitThis: true,
  );
  final jvmExtension = getFunctionPointerExtension(
    library,
    'JavaVM',
    'JniJavaVM',
    indirect: true,
    implicitThis: true,
  );
  localEnvExtsFile
      .writeAsStringSync('$preamble$header$envExtension$jvmExtension');
}

const leafFunctions = {
  'GetVersion',
  'FindClass',
  'GetSuperclass',
  'IsAssignableFrom',
  'NewGlobalRef',
  'DeleteGlobalRef',
  'DeleteLocalRef',
  'IsSameObject',
  'NewLocalRef',
  'GetObjectClass',
  'GetMethodID',
  'GetFieldID',
  'GetObjectField',
  'GetBooleanField',
  'GetByteField',
  'GetCharField',
  'GetShortField',
  'GetIntField',
  'GetLongField',
  'GetFloatField',
  'GetDoubleField',
  'SetObjectField',
  'SetBooleanField',
  'SetByteField',
  'SetCharField',
  'SetShortField',
  'SetIntField',
  'SetLongField',
  'SetFloatField',
  'SetDoubleField',
  'GetStaticMethodID',
  'GetStaticFieldID',
  'GetStaticObjectField',
  'GetStaticBooleanField',
  'GetStaticByteField',
  'GetStaticCharField',
  'GetStaticShortField',
  'GetStaticIntField',
  'GetStaticLongField',
  'GetStaticFloatField',
  'GetStaticDoubleField',
  'SetStaticObjectField',
  'SetStaticBooleanField',
  'SetStaticByteField',
  'SetStaticCharField',
  'SetStaticShortField',
  'SetStaticIntField',
  'SetStaticLongField',
  'SetStaticFloatField',
  'SetStaticDoubleField',
  'GetStringLength',
  'GetStringUTFLength',
  'GetArrayLength',
  'GetObjectArrayElement',
  'SetObjectArrayElement',
  'GetJavaVM',
  'NewWeakGlobalRef',
  'DeleteWeakGlobalRef',
  'ExceptionCheck',
  'GetObjectRefType',
  'GetDirectBufferAddress',
  'GetDirectBufferCapacity',
  // Accessors
  'getClass',
  'getFieldID',
  'getStaticFieldID',
  'getMethodID',
  'getStaticMethodID',
  'getArrayElement',
  'setBooleanArrayElement',
  'setByteArrayElement',
  'setShortArrayElement',
  'setCharArrayElement',
  'setIntArrayElement',
  'setLongArrayElement',
  'setFloatArrayElement',
  'setDoubleArrayElement',
  'getField',
  'getStaticField',
};

String getGlobalEnvExtension(
  Library library,
) {
  final env = findCompound(library, localEnvType);
  final globalEnv = findCompound(library, globalEnvType);
  final checkedReturnTypes = <String, Type>{};
  for (var field in globalEnv.members) {
    final fieldType = field.type;
    if (fieldType is PointerType && fieldType.child is NativeFunc) {
      checkedReturnTypes[field.name] =
          (fieldType.child as NativeFunc).type.returnType;
    }
  }
  final extensionFunctions = env.members
      .map((member) => getGlobalEnvExtensionFunction(
            member,
            checkedReturnTypes[member.name],
            isLeaf: leafFunctions.contains(member.name),
          ))
      .nonNulls
      .join('\n');
  final generatedFunctions =
      primitiveArrayHelperFunctions.map((f) => f.dartCode).join('\n');
  return '''
/// Wraps over `Pointer<GlobalJniEnvStruct>` and exposes function pointer fields
/// as methods.
class GlobalJniEnv {
  final ffi.Pointer<GlobalJniEnvStruct> ptr;
  GlobalJniEnv(this.ptr);
  $extensionFunctions
  $generatedFunctions
}
''';
}

String? getFunctionPointerExtensionFunction(
  CompoundMember field, {
  bool indirect = false,
  bool implicitThis = false,
  required bool isLeaf,
}) {
  final fieldType = field.type;
  if (fieldType is PointerType && fieldType.child is NativeFunc) {
    final nativeFunc = fieldType.child as NativeFunc;
    final functionType = nativeFunc.type;
    final returnType = functionType.returnType;
    final params = functionType.parameters;
    if (params.first.name.isEmpty) {
      return null;
    }

    final visibleParams = implicitThis ? params.sublist(1) : params;

    final signature = visibleParams
        .map((p) => '${p.type.getDartType(dummyWriter)} ${p.name}')
        .join(', ');

    final dartType = FunctionType(returnType: returnType, parameters: params)
        .getDartType(dummyWriter);
    final callArgs = [
      if (implicitThis) 'ptr',
      ...visibleParams.map((p) => p.name)
    ].join(', ');
    final returns = returnType.getDartType(dummyWriter);
    final dereference = indirect ? 'value.ref' : 'ref';
    final leafCall = isLeaf ? 'isLeaf: true' : '';
    return '''
late final _${field.name} =
  ptr.$dereference.${field.name}.asFunction<$dartType>($leafCall);
$returns ${field.name}($signature) => _${field.name}($callArgs);

''';
  }
  return null;
}

String getFunctionPointerExtension(
    Library library, String type, String wrapperClassName,
    {bool indirect = false, bool implicitThis = false}) {
  final typeBinding =
      library.bindings.firstWhere((b) => b.name == type) as Type;
  final compound = typeBinding.typealiasType.baseType as Compound;
  final extensionFunctions = compound.members
      .map((f) => getFunctionPointerExtensionFunction(f,
          indirect: indirect,
          implicitThis: implicitThis,
          isLeaf: leafFunctions.contains(f.name)))
      .nonNulls
      .join('\n');
  return '''
/// Wraps over the function pointers in $type and exposes them
/// as methods.
class $wrapperClassName {
  final ffi.Pointer<$type> ptr;
  $wrapperClassName(this.ptr);

  $extensionFunctions
}

''';
}

void generateDartExtensions(Library library) {
  writeDartExtensions(library);
  executeDartFormat([Paths.globalEnvExts, Paths.localEnvExts]);
}
