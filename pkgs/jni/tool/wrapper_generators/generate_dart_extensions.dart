// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/context.dart';

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

String getCheckedGetter(Context context, Type returnType) {
  const objectPointerGetter = 'objectPointer';

  if (returnType is PointerType) {
    final childName = returnType.child.toString();
    const markerMap = {
      'jboolean': 'JBooleanMarker',
      'jbyte': 'JByteMarker',
      'jchar': 'JCharMarker',
      'jshort': 'JShortMarker',
      'jint': 'JIntMarker',
      'jlong': 'JLongMarker',
      'jfloat': 'JFloatMarker',
      'jdouble': 'JDoubleMarker',
    };
    final child = markerMap[childName] ?? returnType.child.getCType(context);
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
    'jclass': 'checkedClassRef',
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

bool _isPointerType(Type type, Context context) {
  final dartType = type.getDartType(context);
  return dartType.startsWith('ffi.Pointer<') || dartType.endsWith('Ptr');
}

bool _isAllowedNull(String functionName, String paramName) {
  const allowAllParams = {
    'DeleteGlobalRef',
    'NewGlobalRef',
    'DeleteLocalRef',
    'NewLocalRef',
    'DeleteWeakGlobalRef',
    'NewWeakGlobalRef',
    'PopLocalFrame',
    'GetObjectRefType',
    'IsSameObject',
  };
  if (allowAllParams.contains(functionName)) {
    return true;
  }
  if (functionName == 'IsInstanceOf' && paramName == 'obj') {
    return true;
  }
  if ((functionName.startsWith('Set') && functionName.endsWith('Field') ||
          functionName == 'SetObjectArrayElement') &&
      paramName == 'val') {
    return true;
  }
  if (functionName == 'NewObjectArray' && paramName == 'initialElement') {
    return true;
  }
  if (functionName == 'DefineClass' &&
      (paramName == 'loader' || paramName == 'name')) {
    return true;
  }
  if (functionName == 'ThrowNew' && paramName == 'message') {
    return true;
  }
  if (functionName.endsWith('A') && paramName == 'args') {
    return true;
  }
  if (paramName == 'isCopy') {
    return true;
  }
  return false;
}

String getDartReturnType(Type returnType, String checkedGetter) {
  if (checkedGetter == 'check()') return 'void';
  if (checkedGetter == 'boolean') return 'bool';
  if (checkedGetter == 'integer') return 'Dartjint';
  if (checkedGetter == 'byte') return 'Dartjbyte';
  if (checkedGetter == 'char') return 'Dartjchar';
  if (checkedGetter == 'short') return 'Dartjshort';
  if (checkedGetter == 'long') return 'Dartjlong';
  if (checkedGetter == 'float') return 'Dartjfloat';
  if (checkedGetter == 'doubleFloat') return 'Dartjdouble';
  if (checkedGetter == 'checkedClassRef') return 'JClassPtr';
  if (checkedGetter == 'fieldID') return 'JFieldIDPtr';
  if (checkedGetter == 'methodID') return 'JMethodIDPtr';
  if (checkedGetter == 'referenceType') return 'JObjectRefType';
  if (checkedGetter.startsWith('getPointer<')) {
    final inner = checkedGetter.substring(
        'getPointer<'.length, checkedGetter.length - '>()'.length);
    return 'ffi.Pointer<$inner>';
  }
  final cType = returnType.toString();
  if (cType == 'jstring') return 'JStringPtr';
  if (cType == 'jthrowable') return 'JThrowablePtr';
  if (cType == 'jclass') return 'JClassPtr';
  if (cType == 'jobjectArray') return 'JObjectArrayPtr';
  if (cType == 'jbooleanArray') return 'JBooleanArrayPtr';
  if (cType == 'jbyteArray') return 'JByteArrayPtr';
  if (cType == 'jcharArray') return 'JCharArrayPtr';
  if (cType == 'jshortArray') return 'JShortArrayPtr';
  if (cType == 'jintArray') return 'JIntArrayPtr';
  if (cType == 'jlongArray') return 'JLongArrayPtr';
  if (cType == 'jfloatArray') return 'JFloatArrayPtr';
  if (cType == 'jdoubleArray') return 'JDoubleArrayPtr';
  if (cType == 'jarray') return 'JArrayPtr';
  if (cType == 'jweak') return 'JWeakPtr';
  return 'JObjectPtr';
}

String? getGlobalEnvExtensionFunction(
  Context context,
  CompoundMember member,
  CompoundMember globalMember, {
  required bool isLeaf,
}) {
  final globalFieldType = globalMember.type;
  final memberFieldType = member.type;
  if (globalFieldType is PointerType &&
      globalFieldType.child is NativeFunc &&
      memberFieldType is PointerType &&
      memberFieldType.child is NativeFunc) {
    final globalFunc = (globalFieldType.child as NativeFunc).type;
    final memberFunc = (memberFieldType.child as NativeFunc).type;
    final checkedReturnType = globalFunc.returnType;
    final returnType = memberFunc.returnType;
    final params = globalFunc.parameters;
    if (params.isNotEmpty && params.first.name.isEmpty) {
      return null;
    }

    final signature = params
        .map((p) => '${p.type.getDartType(context)} ${p.name}')
        .join(', ');

    final dartType =
        FunctionType(returnType: checkedReturnType, parameters: params)
            .getDartType(context);
    final callArgs = params.map((p) => p.name).join(', ');
    final checkedGetter = getCheckedGetter(context, returnType);
    final returns = getDartReturnType(returnType, checkedGetter);
    final nullChecks = [
      for (final p in params)
        if (_isPointerType(p.type, context) &&
            !_isAllowedNull(member.name, p.name))
          'if (${p.name} == ffi.nullptr) { throw JNullError(); }'
    ];
    final leafCall = isLeaf ? 'isLeaf: true' : '';
    final body = nullChecks.isEmpty
        ? '=> _${member.name}($callArgs).$checkedGetter;'
        : '{\n'
            '${nullChecks.join('\n')}\n'
            '${returns == 'void' ? '' : 'return '}'
            '_${member.name}($callArgs).$checkedGetter;\n'
            '}';
    return '''
late final _${member.name} =
  ptr.ref.${member.name}.asFunction<$dartType>($leafCall);\n
$returns ${member.name}($signature) $body

''';
  }
  return null;
}

void writeDartExtensions(Library library, {Library? envLibrary}) {
  const header = '''
// ignore_for_file: non_constant_identifier_names
// coverage:ignore-file

import 'dart:ffi' as ffi;

import '../accessors.dart';
import '../errors.dart';
import 'jni_bindings_generated.dart';

''';

  final globalEnvExtension =
      getGlobalEnvExtension(library, envLibrary: envLibrary);
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
  Library library, {
  Library? envLibrary,
}) {
  final env = findCompound(envLibrary ?? library, localEnvType);
  final globalEnv = findCompound(library, globalEnvType);
  final globalMembers = <String, CompoundMember>{};
  for (var field in globalEnv.members) {
    globalMembers[field.name] = field;
  }
  final extensionFunctions = env.members
      // ignore ones that get va_list
      .where((member) => !member.name.endsWith('V'))
      .map((member) {
        final globalMember = globalMembers[member.name];
        if (globalMember == null) return null;
        return getGlobalEnvExtensionFunction(
          library.context,
          member,
          globalMember,
          isLeaf: leafFunctions.contains(member.name),
        );
      })
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
  Context context,
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
        .map((p) => '${p.type.getDartType(context)} ${p.name}')
        .join(', ');

    final dartType = FunctionType(returnType: returnType, parameters: params)
        .getDartType(context);
    final callArgs = [
      if (implicitThis) 'ptr',
      ...visibleParams.map((p) => p.name)
    ].join(', ');
    final returns = returnType.getDartType(context);
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
      .map((f) => getFunctionPointerExtensionFunction(library.context, f,
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

void generateDartExtensions(Library library, {Library? envLibrary}) {
  writeDartExtensions(library, envLibrary: envLibrary);
  executeDartFormat([Paths.globalEnvExts, Paths.localEnvExts]);
}
