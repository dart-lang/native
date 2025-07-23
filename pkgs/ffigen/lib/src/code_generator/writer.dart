// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as p;

import '../code_generator.dart';
import '../context.dart';
import '../strings.dart' as strings;
import 'unique_namer.dart';
import 'utils.dart';

/// To store generated String bindings.
class Writer {
  final Context context;
  final String? header;

  /// Holds bindings, which lookup symbols.
  final List<Binding> lookUpBindings;

  /// Holds bindings, which lookup symbols through `FfiNative`.
  final List<Binding> ffiNativeBindings;

  /// Holds bindings which don't lookup symbols.
  final List<Binding> noLookUpBindings;

  /// The default asset id to use for [ffiNativeBindings].
  final String? nativeAssetId;

  /// Manages the `_SymbolAddress` class.
  final symbolAddressWriter = SymbolAddressWriter();

  late String _className;
  String get className => _className;

  final String? classDocComment;

  final bool generateForPackageObjectiveC;

  final List<String> nativeEntryPoints;

  /// Tracks the enums for which enumType.getCType is called. Reset everytime
  /// [generate] is called.
  final usedEnumCTypes = <EnumClass>{};

  String? _ffiLibraryPrefix;
  String get ffiLibraryPrefix {
    if (_ffiLibraryPrefix != null) {
      return _ffiLibraryPrefix!;
    }

    final import = _usedImports.firstWhere(
      (element) => element.name == ffiImport.name,
      orElse: () => ffiImport,
    );
    _usedImports.add(import);
    return _ffiLibraryPrefix = import.prefix;
  }

  String? _ffiPkgLibraryPrefix;
  String get ffiPkgLibraryPrefix {
    if (_ffiPkgLibraryPrefix != null) {
      return _ffiPkgLibraryPrefix!;
    }

    final import = _usedImports.firstWhere(
      (element) => element.name == ffiPkgImport.name,
      orElse: () => ffiPkgImport,
    );
    _usedImports.add(import);
    return _ffiPkgLibraryPrefix = import.prefix;
  }

  String? _objcPkgPrefix;
  String get objcPkgPrefix {
    if (_objcPkgPrefix != null) {
      return _objcPkgPrefix!;
    }

    final import = _usedImports.firstWhere(
      (element) => element.name == objcPkgImport.name,
      orElse: () => objcPkgImport,
    );
    _usedImports.add(import);
    return _objcPkgPrefix = import.prefix;
  }

  late String selfImportPrefix = () {
    final import = _usedImports.firstWhere(
      (element) => element.name == self.name,
      orElse: () => self,
    );
    _usedImports.add(import);
    return import.prefix;
  }();

  final Set<LibraryImport> _usedImports = {};

  late String _lookupFuncIdentifier;
  String get lookupFuncIdentifier => _lookupFuncIdentifier;

  late String _symbolAddressClassName;
  late String _symbolAddressVariableName;
  late String _symbolAddressLibraryVarName;

  /// Initial namers set after running constructor. Namers are reset to this
  /// initial state everytime [generate] is called.
  late UniqueNamer _initialTopLevelUniqueNamer;
  late UniqueNamer _initialWrapperLevelUniqueNamer;

  /// Used by [Binding]s for generating required code.
  late UniqueNamer _topLevelUniqueNamer;
  UniqueNamer get topLevelUniqueNamer => _topLevelUniqueNamer;
  late UniqueNamer _wrapperLevelUniqueNamer;
  UniqueNamer get wrapperLevelUniqueNamer => _wrapperLevelUniqueNamer;
  late UniqueNamer _objCLevelUniqueNamer;
  UniqueNamer get objCLevelUniqueNamer => _objCLevelUniqueNamer;

  /// Set true after calling [generate]. Indicates if
  /// [generateSymbolOutputYamlMap] can be called.
  bool get canGenerateSymbolOutput => _canGenerateSymbolOutput;
  bool _canGenerateSymbolOutput = false;

  final bool silenceEnumWarning;

  Writer({
    required this.lookUpBindings,
    required this.ffiNativeBindings,
    required this.noLookUpBindings,
    required String className,
    required this.nativeAssetId,
    List<LibraryImport> additionalImports = const <LibraryImport>[],
    this.classDocComment,
    this.header,
    required this.generateForPackageObjectiveC,
    required this.silenceEnumWarning,
    required this.nativeEntryPoints,
    required this.context,
  }) {
    final globalLevelNames = noLookUpBindings.map((e) => e.name);
    final wrapperLevelNames = lookUpBindings.map((e) => e.name);

    _initialTopLevelUniqueNamer = UniqueNamer()..markAllUsed(globalLevelNames);
    _initialWrapperLevelUniqueNamer = UniqueNamer()
      ..markAllUsed(wrapperLevelNames);
    final allLevelsUniqueNamer = UniqueNamer()
      ..markAllUsed(globalLevelNames)
      ..markAllUsed(wrapperLevelNames);

    /// Wrapper class name must be unique among all names.
    _className = _resolveNameConflict(
      name: className,
      makeUnique: allLevelsUniqueNamer,
      markUsed: [_initialWrapperLevelUniqueNamer, _initialTopLevelUniqueNamer],
    );

    /// Library imports prefix should be unique unique among all names.
    for (final lib in [...additionalImports, ...allLibraries]) {
      lib.prefix = _resolveNameConflict(
        name: lib.prefix,
        makeUnique: allLevelsUniqueNamer,
        markUsed: [
          _initialWrapperLevelUniqueNamer,
          _initialTopLevelUniqueNamer,
        ],
      );
    }

    /// [_lookupFuncIdentifier] should be unique in top level.
    _lookupFuncIdentifier = _resolveNameConflict(
      name: '_lookup',
      makeUnique: _initialTopLevelUniqueNamer,
    );

    /// Resolve name conflicts of identifiers used for SymbolAddresses.
    _symbolAddressClassName = _resolveNameConflict(
      name: '_SymbolAddresses',
      makeUnique: allLevelsUniqueNamer,
      markUsed: [_initialWrapperLevelUniqueNamer, _initialTopLevelUniqueNamer],
    );
    _symbolAddressVariableName = _resolveNameConflict(
      name: 'addresses',
      makeUnique: _initialWrapperLevelUniqueNamer,
    );
    _symbolAddressLibraryVarName = _resolveNameConflict(
      name: '_library',
      makeUnique: _initialWrapperLevelUniqueNamer,
    );

    _resetUniqueNamers();
  }

  /// Resolved name conflict using [makeUnique] and marks the result as used in
  /// all [markUsed].
  String _resolveNameConflict({
    required String name,
    required UniqueNamer makeUnique,
    List<UniqueNamer> markUsed = const [],
  }) {
    final s = makeUnique.makeUnique(name);
    for (final un in markUsed) {
      un.markUsed(s);
    }
    return s;
  }

  /// Resets the namers to initial state. Namers are reset before generating.
  void _resetUniqueNamers() {
    _topLevelUniqueNamer = UniqueNamer(parent: _initialTopLevelUniqueNamer);
    _wrapperLevelUniqueNamer = UniqueNamer(
      parent: _initialWrapperLevelUniqueNamer,
    );
    _objCLevelUniqueNamer = UniqueNamer();
  }

  void markImportUsed(LibraryImport import) {
    _usedImports.add(import);
  }

  /// Writes all bindings to a String.
  String generate() {
    final s = StringBuffer();

    // We write the source first to determine which imports are actually
    // referenced. Headers and [s] are then combined into the final result.
    final result = StringBuffer();

    // Reset unique namers to initial state.
    _resetUniqueNamers();

    // Reset [usedEnumCTypes].
    usedEnumCTypes.clear();

    // Write file header (if any).
    if (header != null) {
      result.writeln(header);
    }

    // Write auto generated declaration.
    result.write(
      makeDoc(
        'AUTO GENERATED FILE, DO NOT EDIT.\n\nGenerated by `package:ffigen`.',
      ),
    );

    // Write lint ignore if not specified by user already.
    if (!RegExp(r'ignore_for_file:\s*type\s*=\s*lint').hasMatch(header ?? '')) {
      result.write(makeDoc('ignore_for_file: type=lint'));
    }

    // If there are any @Native bindings, the file needs to have an
    // `@DefaultAsset` annotation for the symbols to resolve properly. This
    // avoids duplicating the asset on every element.
    // Since the annotation goes on a `library;` directive, it needs to appear
    // before other definitions in the file.
    if (ffiNativeBindings.isNotEmpty && nativeAssetId != null) {
      result
        ..writeln("@$ffiLibraryPrefix.DefaultAsset('$nativeAssetId')")
        ..writeln('library;\n');
    }

    /// Write [lookUpBindings].
    if (lookUpBindings.isNotEmpty) {
      // Write doc comment for wrapper class.
      s.write(makeDartDoc(classDocComment));
      // Write wrapper classs.
      s.write('class $_className{\n');
      // Write dylib.
      s.write('/// Holds the symbol lookup function.\n');
      s.write(
        'final $ffiLibraryPrefix.Pointer<T> Function<T extends '
        '$ffiLibraryPrefix.NativeType>(String symbolName) '
        '$lookupFuncIdentifier;\n',
      );
      s.write('\n');
      //Write doc comment for wrapper class constructor.
      s.write(makeDartDoc('The symbols are looked up in [dynamicLibrary].'));
      // Write wrapper class constructor.
      s.write(
        '$_className($ffiLibraryPrefix.DynamicLibrary dynamicLibrary): '
        '$lookupFuncIdentifier = dynamicLibrary.lookup;\n\n',
      );
      //Write doc comment for wrapper class named constructor.
      s.write(makeDartDoc('The symbols are looked up with [lookup].'));
      // Write wrapper class named constructor.
      s.write(
        '$_className.fromLookup($ffiLibraryPrefix.Pointer<T> '
        'Function<T extends $ffiLibraryPrefix.NativeType>('
        'String symbolName) lookup): $lookupFuncIdentifier = lookup;\n\n',
      );
      for (final b in lookUpBindings) {
        s.write(b.toBindingString(this).string);
      }
      if (symbolAddressWriter.shouldGenerate) {
        s.write(symbolAddressWriter.writeObject(this));
      }

      s.write('}\n\n');
    }

    if (ffiNativeBindings.isNotEmpty) {
      for (final b in ffiNativeBindings) {
        s.write(b.toBindingString(this).string);
      }

      if (symbolAddressWriter.shouldGenerate) {
        s.write(symbolAddressWriter.writeObject(this));
      }
    }

    if (symbolAddressWriter.shouldGenerate) {
      s.write(symbolAddressWriter.writeClass(this));
    }

    /// Write [noLookUpBindings].
    for (final b in noLookUpBindings) {
      s.write(b.toBindingString(this).string);
    }

    // Write neccesary imports.
    for (final lib in _usedImports) {
      final path = lib.importPath(generateForPackageObjectiveC);
      result.write("import '$path' as ${lib.prefix};\n");
    }
    result.write(s);

    // Warn about Enum usage in API surface.
    if (!silenceEnumWarning && usedEnumCTypes.isNotEmpty) {
      final names = usedEnumCTypes.map((e) => e.originalName).toList()..sort();
      context.logger.severe(
        'The integer type used for enums is '
        'implementation-defined. FFIgen tries to mimic the integer sizes '
        'chosen by the most common compilers for the various OS and '
        'architecture combinations. To prevent any crashes, remove the '
        'enums from your API surface. To rely on the (unsafe!) mimicking, '
        'you can silence this warning by adding silence-enum-warning: true '
        'to the FFIgen config. Affected enums:\n\t${names.join('\n\t')}',
      );
    }

    _canGenerateSymbolOutput = true;
    return result.toString();
  }

  List<Binding> get _allBindings => <Binding>[
    ...noLookUpBindings,
    ...ffiNativeBindings,
    ...lookUpBindings,
  ];

  Map<String, dynamic> generateSymbolOutputYamlMap(String importFilePath) {
    final bindings = _allBindings;
    if (!canGenerateSymbolOutput) {
      throw Exception(
        'Invalid state: generateSymbolOutputYamlMap() '
        'called before generate()',
      );
    }

    // Warn for macros.
    final hasMacroBindings = bindings.any(
      (element) => element is Constant && element.usr.contains('@macro@'),
    );
    if (hasMacroBindings) {
      context.logger.info(
        'Removing all Macros from symbol file since they cannot '
        'be cross referenced reliably.',
      );
    }

    // Remove internal bindings and macros.
    bindings.removeWhere((element) {
      return element.isInternal ||
          (element is Constant && element.usr.contains('@macro@'));
    });

    // Sort bindings alphabetically by USR.
    bindings.sort((a, b) => a.usr.compareTo(b.usr));

    final usesFfiNative = bindings.whereType<Func>().any(
      (element) => element.ffiNativeConfig.enabled,
    );

    return {
      strings.formatVersion: strings.symbolFileFormatVersion,
      strings.files: {
        importFilePath: {
          strings.usedConfig: {strings.ffiNative: usesFfiNative},
          strings.symbols: {
            for (final b in bindings) b.usr: _makeSymbolMapValue(b),
          },
        },
      },
    };
  }

  Map<String, String> _makeSymbolMapValue(Binding b) {
    final dartName = b is Typealias ? getTypedefDartAliasName(b) : null;
    return {
      strings.name: b.name,
      if (dartName != null) strings.dartName: dartName,
    };
  }

  String? getTypedefDartAliasName(Type b) {
    if (b is! Typealias) return null;
    return b.dartAliasName ?? getTypedefDartAliasName(b.type);
  }

  static String _objcImport(String entryPoint, String outDir) {
    final frameworkHeader = parseObjCFrameworkHeader(entryPoint);

    if (frameworkHeader == null) {
      // If it's not a framework header, use a relative import.
      return '#import "${p.relative(entryPoint, from: outDir)}"\n';
    }

    // If it's a framework header, use a <> style import.
    return '#import <$frameworkHeader>\n';
  }

  /// Writes the Objective C code needed for the bindings, if any. Returns null
  /// if there are no bindings that need generated ObjC code. This function does
  /// not generate the output file, but the [outFilename] does affect the
  /// generated code.
  String? generateObjC(String outFilename) {
    final outDir = p.dirname(outFilename);

    final s = StringBuffer();
    s.write('''
#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
''');

    for (final entryPoint in nativeEntryPoints) {
      s.write(_objcImport(entryPoint, outDir));
    }
    s.write(r'''

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef struct {
  int64_t version;
  void* (*newWaiter)(void);
  void (*awaitWaiter)(void*);
  void* (*currentIsolate)(void);
  void (*enterIsolate)(void*);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, BLOCK_SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  return BLOCK_SIG {                                                           \
    void* currentIsolate = ctx->currentIsolate();                              \
    bool mayEnterIsolate =                                                     \
        currentIsolate == NULL &&                                              \
        ctx->getCurrentThreadOwnsIsolate != NULL &&                            \
        ctx->getCurrentThreadOwnsIsolate(targetPort);                          \
    if (currentIsolate == targetIsolate || mayEnterIsolate) {                  \
      if (mayEnterIsolate) {                                                   \
        ctx->enterIsolate(targetIsolate);                                      \
      }                                                                        \
      INVOKE_DIRECT;                                                           \
      if (mayEnterIsolate) {                                                   \
        ctx->exitIsolate();                                                    \
      }                                                                        \
    } else {                                                                   \
      void* waiter = ctx->newWaiter();                                         \
      INVOKE_LISTENER;                                                         \
      ctx->awaitWaiter(waiter);                                                \
    }                                                                          \
  };

''');

    var empty = true;
    for (final binding in _allBindings) {
      final bindingString = binding.toObjCBindingString(this);
      if (bindingString != null) {
        empty = false;
        s.write(bindingString.string);
      }
    }

    s.write('''
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
''');

    return empty ? null : s.toString();
  }
}

/// Manages the generated `_SymbolAddress` class.
class SymbolAddressWriter {
  final List<_SymbolAddressUnit> _addresses = [];

  /// Used to check if we need to generate `_SymbolAddress` class.
  bool get shouldGenerate => _addresses.isNotEmpty;

  bool get hasNonNativeAddress => _addresses.any((e) => !e.native);

  void addSymbol({
    required String type,
    required String name,
    required String ptrName,
  }) {
    _addresses.add(_SymbolAddressUnit(type, name, ptrName, false));
  }

  void addNativeSymbol({required String type, required String name}) {
    _addresses.add(_SymbolAddressUnit(type, name, '', true));
  }

  String writeObject(Writer w) {
    final className = w._symbolAddressClassName;
    final fieldName = w._symbolAddressVariableName;

    if (hasNonNativeAddress) {
      return 'late final $fieldName = $className(this);';
    } else {
      return 'const $fieldName = $className();';
    }
  }

  String writeClass(Writer w) {
    final sb = StringBuffer();
    sb.write('class ${w._symbolAddressClassName} {\n');

    if (hasNonNativeAddress) {
      // Write Library object.
      sb.write('final ${w._className} ${w._symbolAddressLibraryVarName};\n');
      // Write Constructor.
      sb.write(
        '${w._symbolAddressClassName}('
        'this.${w._symbolAddressLibraryVarName});\n',
      );
    } else {
      // Native bindings are top-level, so we don't need a field here.
      sb.write('const ${w._symbolAddressClassName}();');
    }

    for (final address in _addresses) {
      sb.write('${address.type} get ${address.name} => ');

      if (address.native) {
        // For native fields and functions, we can use Native.addressOf to look
        // up their address.
        // The name of address getter shadows the actual element in the library,
        // so we need to use a self-import.
        final arg = '${w.selfImportPrefix}.${address.name}';
        sb.writeln('${w.ffiLibraryPrefix}.Native.addressOf($arg);');
      } else {
        // For other elements, the generator will write a private field of type
        // Pointer which we can reference here.
        sb.writeln('${w._symbolAddressLibraryVarName}.${address.ptrName};');
      }
    }
    sb.write('}\n');
    return sb.toString();
  }
}

/// Holds the data for a single symbol address.
class _SymbolAddressUnit {
  final String type, name, ptrName;

  /// Whether the symbol we're looking up has been declared with `@Native`.
  final bool native;

  _SymbolAddressUnit(this.type, this.name, this.ptrName, this.native);
}
