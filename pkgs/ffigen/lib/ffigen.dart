// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is the Dart API for ffigen. The main entrypoint is the FfiGen class.
///
/// For most use cases the YAML based API is simpler. See
/// https://pub.dev/packages/ffigen for details.
///
/// {@category Errors}
library;

export 'src/code_generator/imports.dart' show ImportedType, LibraryImport;
export 'src/config_provider.dart'
    show
        BindingStyle,
        CommentType,
        CompoundDependencies,
        Declaration,
        DeclarationFilters,
        DynamicLibraryBindings,
        Enums,
        ExternalVersions,
        FfiGenerator,
        FfiNativeConfig,
        Functions,
        Headers,
        Language,
        NativeExternalBindings,
        Output,
        PackingValue,
        Structs,
        SymbolFile,
        UnnamedEnums,
        VarArgFunction,
        Versions,
        YamlConfig,
        defaultCompilerOpts;
