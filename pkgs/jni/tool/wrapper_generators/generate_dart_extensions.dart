// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ffigen/src/code_generator.dart';

import 'ffigen_util.dart';
import 'logging.dart';

class Paths {
  static final currentDir = Directory.current.uri;
  static final bindingsDir = currentDir.resolve("lib/src/third_party/");
  // Contains extensions for our C wrapper types.
  static final globalEnvExts =
      bindingsDir.resolve("global_env_extensions.dart");
  // Contains extensions for JNI's struct types.
  static final localEnvExts =
      bindingsDir.resolve("jnienv_javavm_extensions.dart");
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
  final cType = returnType.getCType(dummyWriter);
  if (cType.endsWith("ArrayPtr")) {
    return objectPointerGetter;
  }
  const mappings = {
    'JBooleanMarker': 'boolean',
    'JByteMarker': 'byte',
    'JShortMarker': 'short',
    'JCharMarker': 'char',
    'JIntMarker': 'integer',
    'JSizeMarker': 'integer', // jsize is aliased to jint
    'JLongMarker': 'long',
    'JFloatMarker': 'float',
    'JDoubleMarker': 'doubleFloat',
    'JObjectPtr': objectPointerGetter,
    'JThrowablePtr': objectPointerGetter,
    'JStringPtr': objectPointerGetter,
    'JClassPtr': 'value',
    'JFieldIDPtr': 'fieldID',
    'JMethodIDPtr': 'methodID',
    'ffi.Int32': 'integer',
    'ffi.Void': 'check()',
    'JWeakPtr': objectPointerGetter,
  };
  if (mappings.containsKey(cType)) {
    return mappings[cType]!;
  }
  throw 'Unknown return type: $cType';
}

String? getGlobalEnvExtensionFunction(Member field, Type? checkedReturnType) {
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
    return '''
late final _${field.name} =
  ptr.ref.${field.name}.asFunction<$dartType>();\n
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

import "dart:ffi" as ffi;\n
import "jni_bindings_generated.dart";

''';
  const importAccessors = '''
import "../accessors.dart";

''';

  final globalEnvExtension = getGlobalEnvExtension(library);
  final accessorExtension = getFunctionPointerExtension(
    library,
    'JniAccessorsStruct',
    'JniAccessors',
  );
  File.fromUri(Paths.globalEnvExts).writeAsStringSync(preamble +
      header +
      importAccessors +
      globalEnvExtension +
      accessorExtension);
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
      .writeAsStringSync(preamble + header + envExtension + jvmExtension);
}

String getGlobalEnvExtension(
  Library library,
) {
  final env = findCompound(library, localEnvType);
  final globalEnv = findCompound(library, globalEnvType);
  final checkedReturnTypes = {};
  for (var field in globalEnv.members) {
    final fieldType = field.type;
    if (fieldType is PointerType && fieldType.child is NativeFunc) {
      checkedReturnTypes[field.name] =
          (fieldType.child as NativeFunc).type.returnType;
    }
  }
  final extensionFunctions = env.members
      .map((m) => getGlobalEnvExtensionFunction(m, checkedReturnTypes[m.name]))
      .whereNotNull()
      .join('\n');
  return '''
/// Wraps over Pointer<GlobalJniEnvStruct> and exposes function pointer fields
/// as methods.
class GlobalJniEnv {
  final ffi.Pointer<GlobalJniEnvStruct> ptr;
  GlobalJniEnv(this.ptr);
  $extensionFunctions
}
''';
}

String? getFunctionPointerExtensionFunction(Member field,
    {bool indirect = false, bool implicitThis = false}) {
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
    return '''
late final _${field.name} =
  ptr.$dereference.${field.name}.asFunction<$dartType>();
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
          indirect: indirect, implicitThis: implicitThis))
      .whereNotNull()
      .join('\n');
  return '''
/// Wraps over the function pointers in $type and exposes them as methods.
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
