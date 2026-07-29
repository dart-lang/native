// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This script generates all FFIgen-based bindings we require to use JNI, which
// includes some C wrappers over `JNIEnv` type and some Dart extension methods.

import 'dart:io';

import 'package:args/args.dart';
import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:ffigen/src/config_provider/config.dart' as ffigen;
import 'package:ffigen/src/context.dart' as ffigen;
import 'package:ffigen/src/header_parser.dart' as ffigen;
import 'package:logging/logging.dart';

import 'wrapper_generators/generate_c_extensions.dart';
import 'wrapper_generators/generate_dart_extensions.dart';
import 'wrapper_generators/logging.dart';

class JniVisitor extends ffigen.Visitor {
  static const enumRenames = {
    'JniType': 'JniCallType',
    'jobjectRefType': 'JObjectRefType',
  };

  static const funcRenames = {
    'FindClass': 'JniFindClass',
    'GetJavaVM': 'JniGetJavaVM',
  };

  static const excludedFuncs = {
    'GetJniContextPtr',
    'setJniGetters',
    'jni_log',
    'acquire_lock',
    'attach_thread',
    'check_exception',
    'destroy_cond',
    'destroy_lock',
    'init_cond',
    'init_lock',
    'load_class',
    'load_class_global_ref',
    'load_class_local_ref',
    'load_class_platform',
    'load_env',
    'load_field',
    'load_method',
    'load_static_field',
    'load_static_method',
    'release_lock',
    'signal_cond',
    'thread_id',
    'to_global_ref',
    'to_global_ref_result',
    'wait_for',
  };

  static final globalEnvNewObjectRegExp = RegExp(r'^globalEnv_NewObject$');
  static final globalEnvCallRegExp = RegExp(
    r'^globalEnv_Call(Static|Nonvirtual|)[A-Z][a-z]+Method$',
  );

  static const excludedStructs = {
    'JniContext',
    'JniLocks',
    'JNIEnv',
    '_JNIEnv',
    'JNIInvokeInterface',
    '__va_list_tag',
    'CallbackResult',
  };

  static const structRenames = {
    '_Dart_FinalizableHandle': 'Dart_FinalizableHandle_',
    '_jfieldID': 'jfieldID_',
    '_jmethodID': 'jmethodID_',
  };

  static const excludedGlobals = {
    'jni',
    'jniEnv',
    'context_getter',
    'env_getter',
  };

  static const excludedTypeDefs = {
    'va_list',
    '__builtin_va_list',
  };

  static const typedefRenames = {
    'jbyte': 'JByteMarker',
    'jboolean': 'JBooleanMarker',
    'jchar': 'JCharMarker',
    'jshort': 'JShortMarker',
    'jint': 'JIntMarker',
    'jlong': 'JLongMarker',
    'jfloat': 'JFloatMarker',
    'jdouble': 'JDoubleMarker',
    'jsize': 'JSizeMarker',
    'jclass': 'JClassPtr',
    'jobject': 'JObjectPtr',
    'jmethodID': 'JMethodIDPtr',
    'jfieldID': 'JFieldIDPtr',
    'jthrowable': 'JThrowablePtr',
    'jstring': 'JStringPtr',
    'jarray': 'JArrayPtr',
    'jobjectArray': 'JObjectArrayPtr',
    'jbooleanArray': 'JBooleanArrayPtr',
    'jbyteArray': 'JByteArrayPtr',
    'jcharArray': 'JCharArrayPtr',
    'jshortArray': 'JShortArrayPtr',
    'jintArray': 'JIntArrayPtr',
    'jlongArray': 'JLongArrayPtr',
    'jfloatArray': 'JFloatArrayPtr',
    'jdoubleArray': 'JDoubleArrayPtr',
    'jweak': 'JWeakPtr',
    'jvalue': 'JValue',
  };

  const JniVisitor();

  @override
  void visitEnum(ffigen.EnumClass node) {
    final renamed = enumRenames[node.originalName];
    if (renamed != null) {
      node.name = renamed;
    }
    node.isIncluded = true;
  }

  @override
  void visitFunc(ffigen.Func node) {
    if (node.originalName.startsWith('JNI_') ||
        excludedFuncs.contains(node.originalName) ||
        globalEnvNewObjectRegExp.hasMatch(node.originalName) ||
        globalEnvCallRegExp.hasMatch(node.originalName)) {
      node.isIncluded = false;
      return;
    }
    final renamed = funcRenames[node.originalName];
    if (renamed != null) {
      node.name = renamed;
    }
    node.isIncluded = true;
  }

  @override
  void visitStruct(ffigen.Struct node) {
    if (excludedStructs.contains(node.originalName)) {
      node.isIncluded = false;
      return;
    }
    final renamed = structRenames[node.originalName];
    if (renamed != null) {
      node.name = renamed;
    }
    node.isIncluded = true;
  }

  @override
  void visitUnion(ffigen.Union node) {
    if (node.originalName == 'jvalue') {
      node.name = 'JValue';
    }
    node.isIncluded = true;
  }

  @override
  void visitGlobal(ffigen.Global node) {
    if (excludedGlobals.contains(node.originalName)) {
      node.isIncluded = false;
      return;
    }
    node.isIncluded = true;
  }

  @override
  void visitTypealias(ffigen.Typealias node) {
    if (excludedTypeDefs.contains(node.originalName)) {
      node.isIncluded = false;
      return;
    }
    final renamed = typedefRenames[node.originalName];
    if (renamed != null) {
      node.name = renamed;
    } else if (node.originalName.startsWith('JNI')) {
      node.name = 'Jni${node.originalName.substring(3)}';
    }
    node.isIncluded = true;
  }
}

void main(List<String> args) {
  final levels = Map.fromEntries(
    Level.LEVELS.map((l) => MapEntry(l.name.toLowerCase(), l)),
  );
  final argParser = ArgParser()
    ..addOption(
      'verbose',
      defaultsTo: 'severe',
      help: 'set FFIgen log verbosity',
      allowed: levels.keys,
    )
    ..addFlag(
      'help',
      negatable: false,
      abbr: 'h',
      defaultsTo: false,
      help: 'display this help message',
    );

  final argResults = argParser.parse(args);

  if (argResults['help'] as bool) {
    stderr.writeln('Generates FFI bindings required for package:jni');
    stderr.writeln(argParser.usage);
    exitCode = 1;
    return;
  }

  hierarchicalLoggingEnabled = true;
  Logger.root.level = levels[argResults['verbose']]!;
  logger.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.message}');
  });

  logger.info('Generating C wrappers');
  final minimalConfig =
      ffigen.YamlConfig.fromFile(File('ffigen_exts.yaml'), logger)
          .configAdapter();
  final minimalLibrary = ffigen.parse(ffigen.Context(logger, minimalConfig));
  generateCWrappers(minimalLibrary);

  logger.info('Generating FFI bindings for package:jni');

  final generator = ffigen.FfiGenerator(
    headers: ffigen.Headers(
      entryPoints: [
        Uri.file('src/dartjni.h'),
        Uri.file('src/third_party/global_jni_env.h'),
        Uri.file('src/jni_constants.h'),
      ],
      include: (uri) {
        final path = uri.toFilePath();
        return path.endsWith('src/dartjni.h') ||
            path.endsWith('src/third_party/global_jni_env.h') ||
            path.endsWith('third_party/jni.h') ||
            path.endsWith('src/jni_constants.h');
      },
      compilerOptions: ['-Ithird_party/'],
      ignoreSourceErrors: true,
    ),
    visitors: const [JniVisitor()],
    output: ffigen.Output(
      style: const ffigen.DynamicLibraryBindings(wrapperName: 'JniBindings'),
      preamble: '''
// Autogenerated file. Do not edit.
// Generated from an annotated version of jni.h provided in Android NDK.
// (NDK Version 23.1.7779620)
// The license for original file is provided below:

/*
 * Copyright (C) 2006 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * JNI specification, as defined by Sun:
 * http://java.sun.com/javase/6/docs/technotes/guides/jni/spec/jniTOC.html
 *
 * Everything here is expected to be VM-neutral.
 */

// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names
// ignore_for_file: unused_field
// ignore_for_file: unused_element
// coverage:ignore-file
''',
      dartFile: Uri.file('lib/src/third_party/jni_bindings_generated.dart'),
    ),
  );
  final config = ffigen.Config(generator);
  final library = ffigen.parse(ffigen.Context(logger, config));
  final outputFile = File(config.output.dartFile.toFilePath());
  library.generateFile(outputFile);

  logger.info('Generating Dart extensions');
  generateDartExtensions(library);
}
