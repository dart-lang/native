// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is the Dart API for FFIgen. The main entrypoint is the [FfiGenerator]
/// class.
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
        Categories,
        CommentType,
        CompoundDependencies,
        Declaration,
        DynamicLibraryBindings,
        Enums,
        ExternalVersions,
        FfiGenerator,
        Functions,
        Globals,
        Headers,
        Integers,
        Interfaces,
        Macros,
        NativeExternalBindings,
        ObjectiveC,
        Output,
        PackingValue,
        Protocols,
        Structs,
        SymbolFile,
        Typedefs,
        Unions,
        UnnamedEnums,
        VarArgFunction,
        Versions,
        YamlConfig,
        defaultCompilerOpts;
