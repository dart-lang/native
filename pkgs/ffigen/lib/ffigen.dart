// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is the Dart API for FFIgen. The main entrypoint is the [FfiGenerator]
/// class.
///
/// For most use cases the YAML based API is simpler. See
/// https://pub.dev/packages/ffigen for details.
///
/// @docImport 'src/config_provider.dart';
library;

export 'src/code_generator/imports.dart' show ImportedType, LibraryImport;
export 'src/config_provider.dart'
    show
        BindingStyle,
        CommentLength,
        CommentStyle,
        CommentType,
        CompoundDependencies,
        Cpp,
        DartOutput,
        Declaration,
        DynamicLibraryBindings,
        EnumStyle,
        ExternalVersions,
        FfiGenerator,
        Input,
        NativeExternalBindings,
        ObjectiveC,
        Output,
        PackingValue,
        SymbolFile,
        TypealiasInclude,
        VarArgFunction,
        Version,
        Versions,
        YamlConfig,
        defaultCompilerOpts,
        importFromSymbolFile,
        importFromSymbolFiles,
        iosSdkPath,
        iosSdkUri,
        macSdkPath,
        macSdkUri,
        xcodePath,
        xcodeUri;
export 'src/config_provider/public_ast.dart';
export 'src/config_provider/public_visitor.dart';
