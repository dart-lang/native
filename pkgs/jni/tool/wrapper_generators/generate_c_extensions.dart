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
  static final src = currentDir.resolve('src/');
  static final thirdParty = src.resolve('third_party/');
  static final globalJniEnvH = thirdParty.resolve('global_jni_env.h');
  static final globalJniEnvC = thirdParty.resolve('global_jni_env.c');
  static final bindingsDir = currentDir.resolve('lib/src/third_party/');
  static final envExtensions = bindingsDir.resolve('env_extensions.dart');
}

/// Name of variable used in wrappers to hold the result.
const resultVar = '_result';

/// Name of variable used in wrappers to hold the exception.
const errorVar = '_exception';

/// Name of JNIEnv struct definition in JNI headers.
const envType = 'JNINativeInterface';

/// Name of wrapper to JNIEnv
const wrapperName = 'GlobalJniEnvStruct';

const wrapperIncludes = '''
#include "global_jni_env.h"

''';

const wrapperDeclIncludes = '''
#include <stdint.h>
#include "../dartjni.h"

''';

const wrapperGetter = '''
FFI_PLUGIN_EXPORT
$wrapperName* GetGlobalEnv() {
  if (jni->jvm == NULL) {
    return NULL;
  }
  return &globalJniEnv;
}
''';

const wrapperGetterDecl = '''
FFI_PLUGIN_EXPORT $wrapperName* GetGlobalEnv();
''';

bool hasVarArgs(String name) {
  return name == 'NewObject' ||
      RegExp(r'^Call(Static|Nonvirtual|)[A-Z][a-z]+Method$').hasMatch(name);
}

/// Get C name of a type from its ffigen representation.
String getCType(Type type) {
  if (type is PointerType) {
    return '${getCType(type.child)}*';
  }
  final cType = type.getCType(dummyWriter);
  const specialCaseMappings = {
    'JNIEnv1': 'JNIEnv',
    'ffi.Char': 'char',
    'ffi.Void': 'void',
    'ffi.Int': 'int',
    'ffi.Int32': 'int32_t',
  };
  return specialCaseMappings[cType] ?? cType;
}

/// Get type of wrapping function for a JNIEnv function.
FunctionType getGlobalJniEnvFunctionType(FunctionType ft) {
  return FunctionType(
    returnType: ft.returnType,
    parameters: ft.parameters.sublist(1),
  );
}

String getWrapperFuncName(String name) {
  return 'globalEnv_$name';
}

// Returns declaration of function field in GlobalJniEnv struct
String getFunctionFieldDecl(Member field, {required bool isField}) {
  final fieldType = field.type;
  if (fieldType is PointerType && fieldType.child is NativeFunc) {
    final nativeFunc = fieldType.child as NativeFunc;
    final functionType = getGlobalJniEnvFunctionType(nativeFunc.type);
    final resultWrapper = getResultWrapper(getCType(functionType.returnType));
    final name = field.name;
    final withVarArgs = hasVarArgs(name);
    final params = functionType.parameters
            .map((param) => '${getCType(param.type)} ${param.name}')
            .join(', ') +
        (withVarArgs ? ', ...' : '');
    final willExport = withVarArgs ? 'FFI_PLUGIN_EXPORT ' : '';
    if (isField) {
      return '${resultWrapper.returnType} (*$name)($params);';
    }
    return '$willExport${resultWrapper.returnType} '
        '${getWrapperFuncName(field.name)}($params);';
  } else {
    return 'void* ${field.name};';
  }
}

class ResultWrapper {
  String returnType, onResult, onError;
  ResultWrapper.withResultAndError(
      this.returnType, this.onResult, this.onError);
  ResultWrapper.unionType(
    String returnType,
    String defaultValue,
  ) : this.withResultAndError(
          returnType,
          '($returnType){.value = $resultVar, .exception = NULL}',
          '($returnType){.value = $defaultValue, .exception = $errorVar}',
        );
  ResultWrapper.forJValueField(String fieldChar)
      : this.withResultAndError(
          'JniResult',
          '(JniResult){.value = {.$fieldChar = $resultVar}, .exception = NULL}',
          '(JniResult){.value = {.j = 0}, .exception = $errorVar}',
        );
}

String jValueGetterOf(String returnType) {
  const getters = {
    'jboolean': 'z',
    'jbyte': 'b',
    'jshort': 's',
    'jchar': 'c',
    'jint': 'i',
    'jsize': 'i', // jsize is an alias to jint
    'jfloat': 'f',
    'jlong': 'j',
    'jdouble': 'd',
    'jobject': 'l',
    'jweak': 'l',
    'jarray': 'l',
    'jstring': 'l',
    'jthrowable': 'l',
  };
  if (!getters.containsKey(returnType)) {
    stderr.writeln('Unknown type $returnType for return type');
    exit(1);
  }
  return getters[returnType]!;
}

ResultWrapper getResultWrapper(String returnType) {
  if (returnType.endsWith('*')) {
    return ResultWrapper.unionType('JniPointerResult', 'NULL');
  }

  final jobjectWrapper = ResultWrapper.forJValueField('l');
  if (returnType.endsWith('Array')) {
    return jobjectWrapper;
  }

  switch (returnType) {
    case 'void':
      return ResultWrapper.withResultAndError(
        'jthrowable',
        'NULL',
        errorVar,
      );
    case 'jmethodID':
    case 'jfieldID':
      return ResultWrapper.unionType('JniPointerResult', 'NULL');
    case 'jclass':
      return ResultWrapper.unionType('JniClassLookupResult', 'NULL');
    case 'int32_t':
      return ResultWrapper.forJValueField('i');
    default:
      return ResultWrapper.forJValueField(jValueGetterOf(returnType));
  }
}

bool isJRefType(String type) {
  // No need to include jweak here, its only returned by ref-related functions.
  const refTypes = {
    'jclass',
    'jobject',
    'jstring',
    'jthrowable',
    'jarray',
    'jweak'
  };
  return (type.startsWith('j') && type.endsWith('Array')) ||
      refTypes.contains(type);
}

const refFunctions = {
  'NewGlobalRef',
  'DeleteGlobalRef',
  'NewLocalRef',
  'DeleteLocalRef',
  'NewWeakGlobalRef',
  'DeleteWeakGlobalRef',
};

/// These return const ptrs so the assignment statement needs to be
/// adjusted in the wrapper.
const constBufferReturningFunctions = {
  'GetStringChars',
  'GetStringUTFChars',
  'GetStringCritical',
};

/// Methods which do not throw exceptions, and thus not need to be checked
const _noCheckException = {
  'GetVersion',
  'GetStringCritical',
  'ExceptionClear',
  'ExceptionDescribe',
};

String? getWrapperFunc(Member field) {
  final fieldType = field.type;
  if (fieldType is PointerType && fieldType.child is NativeFunc) {
    final functionType = (fieldType.child as NativeFunc).type;
    if (functionType.parameters.first.name.isEmpty) {
      return null;
    }

    final outerFunctionType = getGlobalJniEnvFunctionType(functionType);
    final wrapperName = getWrapperFuncName(field.name);
    final returnType = getCType(outerFunctionType.returnType);
    final withVarArgs = hasVarArgs(field.name);
    final params = [
      ...outerFunctionType.parameters
          .map((param) => '${getCType(param.type)} ${param.name}'),
      if (withVarArgs) '...',
    ].join(', ');
    var returnCapture = returnType == 'void' ? '' : '$returnType $resultVar =';
    if (constBufferReturningFunctions.contains(field.name)) {
      returnCapture = 'const $returnCapture';
    }
    final callParams = [
      'jniEnv',
      ...outerFunctionType.parameters.map((param) => param.name),
      if (withVarArgs) 'args',
    ].join(', ');
    final resultWrapper = getResultWrapper(returnType);

    var convertRef = '';
    if (isJRefType(returnType) && !refFunctions.contains(field.name)) {
      convertRef = '  $resultVar = to_global_ref($resultVar);\n';
    }
    final callee = field.name + (withVarArgs ? 'V' : '');
    final varArgsInit = withVarArgs
        ? '''
  va_list args;
  va_start(args, methodID);
'''
        : '';
    final varArgsEnd = withVarArgs ? 'va_end(args);\n' : '';
    final exceptionCheck = _noCheckException.contains(field.name)
        ? ''
        : '''
  jthrowable $errorVar = check_exception();
  if ($errorVar != NULL) {
    return ${resultWrapper.onError};
  }
''';
    final willExport = withVarArgs ? 'FFI_PLUGIN_EXPORT ' : '';
    return '$willExport'
        '${resultWrapper.returnType} $wrapperName($params) {\n'
        '  attach_thread();\n'
        '$varArgsInit'
        '  $returnCapture (*jniEnv)->$callee($callParams);\n'
        '$varArgsEnd'
        '$exceptionCheck'
        '$convertRef'
        '  return ${resultWrapper.onResult};\n'
        '}\n';
  }
  return null;
}

void writeGlobalJniEnvWrapper(Library library) {
  final jniEnvType = findCompound(library, envType);
  final fieldDecls = jniEnvType.members
      .map((member) => getFunctionFieldDecl(member, isField: true))
      .join('\n');
  final varArgsFunctions = jniEnvType.members
      .where((member) => hasVarArgs(member.name))
      .map((member) => getFunctionFieldDecl(member, isField: false))
      .join('\n');
  final generatedFields = primitiveArrayHelperFields.join();
  final structDecl = '''
typedef struct $wrapperName {
  $fieldDecls
  $generatedFields
} $wrapperName;
''';
  File.fromUri(Paths.globalJniEnvH).writeAsStringSync('$preamble'
      '$wrapperDeclIncludes'
      '$structDecl'
      '$wrapperGetterDecl'
      '$varArgsFunctions\n');

  final functionWrappers = StringBuffer();
  final structInst = StringBuffer('$wrapperName globalJniEnv = {\n');
  for (final member in jniEnvType.members) {
    final wrapper = getWrapperFunc(member);
    if (wrapper == null) {
      structInst.writeln('.${member.name} = NULL,');
    } else {
      structInst
          .writeln('.${member.name} = ${getWrapperFuncName(member.name)},');
      functionWrappers.writeln(wrapper);
    }
  }
  final generatedFunctions = primitiveArrayHelperFunctions;
  for (final function in generatedFunctions) {
    structInst
        .writeln('.${function.name} = ${getWrapperFuncName(function.name)},');
    functionWrappers.writeln(function);
  }

  structInst.write('};');
  File.fromUri(Paths.globalJniEnvC).writeAsStringSync(
      '$preamble$wrapperIncludes$functionWrappers$structInst$wrapperGetter');
}

void executeClangFormat(List<Uri> files) {
  final paths = files.map((u) => u.toFilePath()).toList();
  logger.info('execute clang-format -i ${paths.join(" ")}');
  final format = Process.runSync('clang-format', ['-i', ...paths]);
  if (format.exitCode != 0) {
    stderr.writeln('clang-format exited with ${format.exitCode}');
    stderr.writeln(format.stderr);
  }
}

void generateCWrappers(Library minimalLibrary) {
  writeGlobalJniEnvWrapper(minimalLibrary);
  executeClangFormat([Paths.globalJniEnvC, Paths.globalJniEnvH]);
}
