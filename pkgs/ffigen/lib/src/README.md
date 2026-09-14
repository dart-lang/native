# **_package:ffigen_**: Internal Working
## Table of Contents -
1. [Overview](#overview)
2. [LibClang](#LibClang)
    1. [Bindings](#Bindings)
3. [Scripts](#scripts)
    1. [ffigen.dart](#ffigen.dart)
4. [Components](#components)
    1. [Config Provider](#Config-Provider)
    2. [Header Parser](#Header-Parser)
    3. [Code Generator](#Code-Generator)
# Overview
`package:ffigen` simplifies the process of generating `dart:ffi` bindings from C and Objective-C header files. It is simple to use, configured via a Dart script (`FfiGenerator`). It requires LLVM (9+) to work. This document tries to give a complete overview of every component without going into too many details about every single class/file.
# LibClang
`package:ffigen` binds to LibClang using `dart:ffi` for parsing C header files. 
## Bindings
The script for generating bindings is `tool/generate_clang_bindings.dart`. The bindings are generated to `lib/src/header_parser/clang_bindings/clang_bindings.dart`. These are used by [Header Parser](#header-parser) for calling libclang functions.
# Scripts
## ffigen.dart
FFIgen is typically run via a Dart script such as `tool/ffigen.dart` using `dart run tool/ffigen.dart`.
- The script creates an `FfiGenerator` object specifying `Input`, `Output`, and `Visitor`s.
- `FfiGenerator.generate()` parses the headers, runs AST visitors, and generates the Dart bindings.
- LibClang dynamic library is found in default system locations or resolved automatically.
# Components
## Config Provider
The Config Provider holds all the configurations required by other modules.
- Holds input paths, compiler options, output configurations, and visitors.
- Provides configurations to the header parser and code generator modules.
## Header Parser
The Header Parser parses C and Objective-C header files and converts them into AST nodes and a `Library` object.
- Declarations are traversed and converted to AST nodes.
- AST visitors filter, rename, and customize declarations.
- Header Parser also filters out any _unimplemented_ or _unsupported_ declarations before generating a `Library` object.
## Code Generator
The Code Generator generates the actual string bindings.
- Code generator handles all external name collisions, while internal name conflicts are handled by each specific `Binding`.
- Code Generator also handles how workarounds for arrays and bools are generated.
