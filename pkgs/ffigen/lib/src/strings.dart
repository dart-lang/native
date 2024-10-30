// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'code_generator.dart';
import 'header_parser/clang_bindings/clang_bindings.dart' as clang;

/// Name of the dynamic library file according to current platform.
String get dylibFileName {
  String name;
  if (Platform.isLinux) {
    name = libclangDylibLinux;
  } else if (Platform.isMacOS) {
    name = libclangDylibMacos;
  } else if (Platform.isWindows) {
    name = libclangDylibWindows;
  } else {
    throw Exception('Unsupported Platform.');
  }
  return name;
}

const llvmPath = 'llvm-path';

/// Name of the parent folder of dynamic library `lib` or `bin` (on windows).
String get dynamicLibParentName => Platform.isWindows ? 'bin' : 'lib';

const output = 'output';

// Sub-keys of output.
const bindings = 'bindings';
const objCBindings = 'objc-bindings';
const symbolFile = 'symbol-file';

const language = 'language';

// String mappings for the Language enum.
const langC = 'c';
const langObjC = 'objc';

// Clang command line args for Objective C.
const clangLangObjC = ['-x', 'objective-c'];
const clangObjCBoolDefine = '__OBJC_BOOL_IS_BOOL';
const clangInclude = '-include';

// Special objective C types.
const objcBOOL = 'BOOL';
const objcInstanceType = 'instancetype';

const headers = 'headers';

// Sub-fields of headers
const entryPoints = 'entry-points';
const includeDirectives = 'include-directives';

const compilerOpts = 'compiler-opts';

const macos = 'macos';
const ios = 'ios';

const externalVersions = 'external-versions';
const externalVersionsPlatforms = [ios, macos];
const externalVersionsMin = 'min';

const compilerOptsAuto = 'compiler-opts-automatic';
// Sub-fields of compilerOptsAuto.macos
const includeCStdLib = 'include-c-standard-library';

// Declarations.
const functions = 'functions';
const structs = 'structs';
const unions = 'unions';
const enums = 'enums';
const unnamedEnums = 'unnamed-enums';
const globals = 'globals';
const macros = 'macros';
const typedefs = 'typedefs';
const objcInterfaces = 'objc-interfaces';
const objcProtocols = 'objc-protocols';

const excludeAllByDefault = 'exclude-all-by-default';
const includeUnusedTypedefs = 'include-unused-typedefs';
const includeTransitiveObjCInterfaces = 'include-transitive-objc-interfaces';
const includeTransitiveObjCProtocols = 'include-transitive-objc-protocols';
const generateForPackageObjectiveC = 'generate-for-package-objective-c';

// Sub-fields of Declarations.
const include = 'include';
const exclude = 'exclude';
const rename = 'rename';
const memberRename = 'member-rename';
const memberFilter = 'member-filter';
const symbolAddress = 'symbol-address';

// Nested under `functions`
const exposeFunctionTypedefs = 'expose-typedefs';
const leafFunctions = 'leaf';
const varArgFunctions = 'variadic-arguments';

// Nested under `enums`
const enumAsInt = 'as-int';

// Nested under varArg entries
const postfix = 'postfix';
const types = 'types';

// Sub-fields of ObjC interfaces.
const objcModule = 'module';

const dependencyOnly = 'dependency-only';
// Values for `compoundDependencies`.
const fullCompoundDependencies = 'full';
const opaqueCompoundDependencies = 'opaque';

const structPack = 'pack';
const Map<Object, int?> packingValuesMap = {
  'none': null,
  1: 1,
  2: 2,
  4: 4,
  8: 8,
  16: 16,
};

// Sizemap values.
const sChar = 'char';
const uChar = 'unsigned char';
const short = 'short';
const uShort = 'unsigned short';
const intType = 'int';
const uInt = 'unsigned int';
const long = 'long';
const uLong = 'unsigned long';
const longLong = 'long long';
const uLongLong = 'unsigned long long';
const enumType = 'enum';

// Used for validation and extraction of sizemap.
const sizemapNativeMapping = <String, int>{
  sChar: clang.CXTypeKind.CXType_SChar,
  uChar: clang.CXTypeKind.CXType_UChar,
  short: clang.CXTypeKind.CXType_Short,
  uShort: clang.CXTypeKind.CXType_UShort,
  intType: clang.CXTypeKind.CXType_Int,
  uInt: clang.CXTypeKind.CXType_UInt,
  long: clang.CXTypeKind.CXType_Long,
  uLong: clang.CXTypeKind.CXType_ULong,
  longLong: clang.CXTypeKind.CXType_LongLong,
  uLongLong: clang.CXTypeKind.CXType_ULongLong,
  enumType: clang.CXTypeKind.CXType_Enum
};

// Library imports.
const libraryImports = 'library-imports';

// Sub Keys of symbol file.
const symbols = 'symbols';

// Symbol file yaml.
const formatVersion = 'format_version';

/// Current symbol file format version.
///
/// This is generated when generating any symbol file. When importing any other
/// symbol file, this version is compared according to `semantic` versioning
/// to determine compatibility.
const symbolFileFormatVersion = '1.0.0';
const files = 'files';
const usedConfig = 'used-config';

const import = 'import';
const defaultSymbolFileImportPrefix = 'imp';

// Sub keys of import.
const symbolFilesImport = 'symbol-files';
// Sub-Sub keys of symbolFilesImport.
const importPath = 'import-path';

final predefinedLibraryImports = {
  ffiImport.name: ffiImport,
  ffiPkgImport.name: ffiPkgImport
};

const typeMap = 'type-map';

// Sub-fields for type-map.
const typeMapTypedefs = 'typedefs';
const typeMapStructs = 'structs';
const typeMapUnions = 'unions';
const typeMapNativeTypes = 'native-types';

// Sub-sub-keys for fields under typeMap.
const lib = 'lib';
const cType = 'c-type';
const dartType = 'dart-type';

const supportedNativeTypeMappings = <String, SupportedNativeType>{
  'Void': SupportedNativeType.voidType,
  'Uint8': SupportedNativeType.uint8,
  'Uint16': SupportedNativeType.uint16,
  'Uint32': SupportedNativeType.uint32,
  'Uint64': SupportedNativeType.uint64,
  'Int8': SupportedNativeType.int8,
  'Int16': SupportedNativeType.int16,
  'Int32': SupportedNativeType.int32,
  'Int64': SupportedNativeType.int64,
  'IntPtr': SupportedNativeType.intPtr,
  'Float': SupportedNativeType.float,
  'Double': SupportedNativeType.double,
};

// Boolean flags.
const sort = 'sort';
const useSupportedTypedefs = 'use-supported-typedefs';
const useDartHandle = 'use-dart-handle';
const silenceEnumWarning = 'silence-enum-warning';
const ignoreSourceErrors = 'ignore-source-errors';

const comments = 'comments';
// Sub-fields of comments.
const style = 'style';
const length = 'length';

// Sub-fields of style.
const doxygen = 'doxygen';
const any = 'any';
// Sub-fields of length.
const brief = 'brief';
const full = 'full';
// Cmd line comment option.
const fparseAllComments = '-fparse-all-comments';

// Library input.
const name = 'name';
const description = 'description';
const preamble = 'preamble';

// Dynamic library names.
const libclangDylibLinux = 'libclang.so';
const libclangDylibMacos = 'libclang.dylib';
const libclangDylibWindows = 'libclang.dll';

// Dynamic library default locations.
const linuxDylibLocations = {
  '/usr/lib/llvm-9/lib/',
  '/usr/lib/llvm-10/lib/',
  '/usr/lib/llvm-11/lib/',
  '/usr/lib/llvm-12/lib/',
  '/usr/lib/llvm-13/lib/',
  '/usr/lib/llvm-14/lib/',
  '/usr/lib/llvm-15/lib/',
  '/usr/lib/',
  '/usr/lib64/',
};
const windowsDylibLocations = {
  r'C:\Program Files\LLVM\bin\',
};
const macOsDylibLocations = {
  // Default Xcode commandline tools installation.
  '/Library/Developer/CommandLineTools/usr/',
  // Default path for LLVM installed with apt-get.
  '/usr/local/opt/llvm/lib/',
  // Default path for LLVM installed with brew.
  '/opt/homebrew/opt/llvm/lib/',
  // Default Xcode installation.
  // Last because it does not include ObjectiveC headers by default.
  // See https://github.com/dart-lang/ffigen/pull/402#issuecomment-1154348670.
  '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/',
};
const xcodeDylibLocation = 'Toolchains/XcodeDefault.xctoolchain/usr/lib/';

// Writen doubles.
const doubleInfinity = 'double.infinity';
const doubleNegativeInfinity = 'double.negativeInfinity';
const doubleNaN = 'double.nan';

/// USR for struct `_Dart_Handle`.
const dartHandleUsr = 'c:@S@_Dart_Handle';

const ffiNative = 'ffi-native';
const ffiNativeAsset = 'asset-id';

Directory? _tmpDir;

/// A path to a unique temporary directory that should be used for files meant
/// to be discarded after the current execution is finished.
String get tmpDir {
  if (Platform.environment.containsKey('TEST_TMPDIR')) {
    return Platform.environment['TEST_TMPDIR']!;
  }

  _tmpDir ??= Directory.systemTemp.createTempSync();
  return _tmpDir!.path;
}

const ffigenJsonSchemaIndent = '  ';
const ffigenJsonSchemaId = 'https://json.schemastore.org/ffigen';
const ffigenJsonSchemaFileName = 'ffigen.schema.json';
