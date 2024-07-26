// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains all the neccesary classes required by config.
library;

import 'dart:io';

import 'package:package_config/package_config.dart';
import 'package:quiver/pattern.dart' as quiver;

import '../code_generator.dart';
import 'config.dart';
import 'path_finder.dart';

enum Language { c, objc }

class CommentType {
  CommentStyle style;
  CommentLength length;
  CommentType(this.style, this.length);

  /// Sets default style as [CommentStyle.doxygen], default length as
  /// [CommentLength.full].
  CommentType.def()
      : style = CommentStyle.doxygen,
        length = CommentLength.full;

  /// Disables any comments.
  CommentType.none()
      : style = CommentStyle.doxygen,
        length = CommentLength.none;
}

enum CommentStyle { doxygen, any }

enum CommentLength { none, brief, full }

enum CompoundDependencies { full, opaque }

/// Holds config for how Structs Packing will be overriden.
class StructPackingOverride {
  final List<(RegExp, int?)> _matchers;

  StructPackingOverride(this._matchers);

  /// Returns pack value for [name].
  PackingValue? getOverridenPackValue(String name) {
    for (final (regex, value) in _matchers) {
      if (quiver.matchesFull(regex, name)) {
        return PackingValue(value);
      }
    }
    return null;
  }
}

// Holds headers and filters for header.
class YamlHeaders {
  /// Path to headers.
  ///
  /// This contains all the headers, after extraction from Globs.
  final List<Uri> entryPoints;

  /// Include filter for headers.
  final HeaderIncludeFilter includeFilter;

  YamlHeaders({List<String>? entryPoints, HeaderIncludeFilter? includeFilter})
      : entryPoints = entryPoints?.map(Uri.file).toList() ?? [],
        includeFilter = includeFilter ?? GlobHeaderFilter();
}

abstract class HeaderIncludeFilter {
  bool shouldInclude(Uri headerSourceFile);
}

class GlobHeaderFilter extends HeaderIncludeFilter {
  List<quiver.Glob>? includeGlobs = [];

  GlobHeaderFilter({
    this.includeGlobs,
  });

  @override
  bool shouldInclude(Uri headerSourceFile) {
    // Return true if header was included.
    for (final globPattern in includeGlobs!) {
      if (quiver.matchesFull(globPattern, headerSourceFile.toFilePath())) {
        return true;
      }
    }

    // If any includedInclusionHeaders is provided, return false.
    if (includeGlobs!.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

/// A generic declaration config, used for Functions, Structs, Enums, Macros,
/// unnamed Enums and Globals.
class YamlDeclaration implements Declaration {
  final YamlIncluder _includer;
  final YamlRenamer _renamer;
  final YamlMemberRenamer _memberRenamer;
  final YamlIncluder _symbolAddressIncluder;
  final bool excludeAllByDefault;

  YamlDeclaration({
    YamlIncluder? includer,
    YamlRenamer? renamer,
    YamlMemberRenamer? memberRenamer,
    YamlIncluder? symbolAddressIncluder,
    required this.excludeAllByDefault,
  })  : _includer = includer ?? YamlIncluder(),
        _renamer = renamer ?? YamlRenamer(),
        _memberRenamer = memberRenamer ?? YamlMemberRenamer(),
        _symbolAddressIncluder =
            symbolAddressIncluder ?? YamlIncluder.excludeByDefault();

  /// Applies renaming and returns the result.
  @override
  String rename(String name) => _renamer.rename(name);

  /// Applies member renaming and returns the result.
  @override
  String renameMember(String declaration, String member) =>
      _memberRenamer.rename(declaration, member);

  /// Checks if a name is allowed by a filter.
  @override
  bool shouldInclude(String name) =>
      _includer.shouldInclude(name, excludeAllByDefault);

  /// Checks if the symbol address should be included for this name.
  @override
  bool shouldIncludeSymbolAddress(String name) =>
      _symbolAddressIncluder.shouldInclude(name);
}

/// Matches `$<single_digit_int>`, value can be accessed in group 1 of match.
final replaceGroupRegexp = RegExp(r'\$([0-9])');

/// Match/rename using [regExp].
class RegExpRenamer {
  final RegExp regExp;
  final String replacementPattern;

  RegExpRenamer(this.regExp, this.replacementPattern);

  /// Returns true if [str] has a full match with [regExp].
  bool matches(String str) => quiver.matchesFull(regExp, str);

  /// Renames [str] according to [replacementPattern].
  ///
  /// Returns [str] if [regExp] doesn't have a full match.
  String rename(String str) {
    if (matches(str)) {
      // Get match.
      final regExpMatch = regExp.firstMatch(str)!;

      /// Get group values.
      /// E.g for `str`: `clang_dispose` and `regExp`: `clang_(.*)`
      /// groups will be `0`: `clang_disponse`, `1`: `dispose`.
      final groups = regExpMatch.groups(
          List.generate(regExpMatch.groupCount, (index) => index) +
              [regExpMatch.groupCount]);

      /// Replace all `$<int>` symbols with respective groups (if any).
      final result =
          replacementPattern.replaceAllMapped(replaceGroupRegexp, (match) {
        final groupInt = int.parse(match.group(1)!);
        return groups[groupInt]!;
      });
      return result;
    } else {
      return str;
    }
  }

  @override
  String toString() {
    return 'Regexp: $regExp, ReplacementPattern: $replacementPattern';
  }
}

/// Handles `include/exclude` logic for a declaration.
class YamlIncluder {
  final List<RegExp> _includeMatchers;
  final Set<String> _includeFull;
  final List<RegExp> _excludeMatchers;
  final Set<String> _excludeFull;

  YamlIncluder({
    List<RegExp>? includeMatchers,
    Set<String>? includeFull,
    List<RegExp>? excludeMatchers,
    Set<String>? excludeFull,
  })  : _includeMatchers = includeMatchers ?? [],
        _includeFull = includeFull ?? {},
        _excludeMatchers = excludeMatchers ?? [],
        _excludeFull = excludeFull ?? {};

  YamlIncluder.excludeByDefault()
      : _includeMatchers = [],
        _includeFull = {},
        _excludeMatchers = [RegExp('.*', dotAll: true)],
        _excludeFull = {};

  /// Returns true if [name] is allowed.
  ///
  /// Exclude overrides include.
  bool shouldInclude(String name, [bool excludeAllByDefault = false]) {
    if (_excludeFull.contains(name)) {
      return false;
    }

    for (final em in _excludeMatchers) {
      if (quiver.matchesFull(em, name)) {
        return false;
      }
    }

    if (_includeFull.contains(name)) {
      return true;
    }

    for (final im in _includeMatchers) {
      if (quiver.matchesFull(im, name)) {
        return true;
      }
    }

    // If user has provided 'include' field in the filter, then default
    // matching is false.
    if (_includeMatchers.isNotEmpty || _includeFull.isNotEmpty) {
      return false;
    } else {
      // Otherwise, fall back to the default behavior for empty filters.
      return !excludeAllByDefault;
    }
  }
}

/// Handles `full/regexp` renaming logic.
class YamlRenamer {
  final Map<String, String> _renameFull;
  final List<RegExpRenamer> _renameMatchers;

  YamlRenamer({
    List<RegExpRenamer>? renamePatterns,
    Map<String, String>? renameFull,
  })  : _renameMatchers = renamePatterns ?? [],
        _renameFull = renameFull ?? {};

  YamlRenamer.noRename()
      : _renameMatchers = [],
        _renameFull = {};

  String rename(String name) {
    // Apply full rename (if any).
    if (_renameFull.containsKey(name)) {
      return _renameFull[name]!;
    }

    // Apply rename regexp (if matches).
    for (final renamer in _renameMatchers) {
      if (renamer.matches(name)) {
        return renamer.rename(name);
      }
    }

    // No renaming is provided for this declaration, return unchanged.
    return name;
  }
}

/// Match declaration name using [declarationRegExp].
class RegExpMemberRenamer {
  final RegExp declarationRegExp;
  final YamlRenamer memberRenamer;

  RegExpMemberRenamer(this.declarationRegExp, this.memberRenamer);

  /// Returns true if [declaration] has a full match with [declarationRegExp].
  bool matchesDeclarationName(String declaration) =>
      quiver.matchesFull(declarationRegExp, declaration);

  @override
  String toString() {
    return 'DeclarationRegExp: $declarationRegExp, '
        'YamlMemberRenamer: $memberRenamer';
  }
}

/// Handles `full/regexp` member renaming.
class YamlMemberRenamer {
  final Map<String, YamlRenamer> _memberRenameFull;
  final List<RegExpMemberRenamer> _memberRenameMatchers;

  final Map<String, YamlRenamer> _cache = {};

  YamlMemberRenamer({
    Map<String, YamlRenamer>? memberRenameFull,
    List<RegExpMemberRenamer>? memberRenamePattern,
  })  : _memberRenameFull = memberRenameFull ?? {},
        _memberRenameMatchers = memberRenamePattern ?? [];

  String rename(String declaration, String member) {
    if (_cache.containsKey(declaration)) {
      return _cache[declaration]!.rename(member);
    }

    // Apply full rename (if any).
    if (_memberRenameFull.containsKey(declaration)) {
      // Add to cache.
      _cache[declaration] = _memberRenameFull[declaration]!;
      return _cache[declaration]!.rename(member);
    }

    // Apply rename regexp (if matches).
    for (final renamer in _memberRenameMatchers) {
      if (renamer.matchesDeclarationName(declaration)) {
        // Add to cache.
        _cache[declaration] = renamer.memberRenamer;
        return _cache[declaration]!.rename(member);
      }
    }

    // No renaming is provided for this declaration, return unchanged.
    return member;
  }
}

/// Handles config for automatically added compiler options.
class CompilerOptsAuto {
  final bool macIncludeStdLib;

  CompilerOptsAuto({bool? macIncludeStdLib})
      : macIncludeStdLib = macIncludeStdLib ?? true;

  /// Extracts compiler options based on OS and config.
  List<String> extractCompilerOpts() {
    return [
      if (Platform.isMacOS && macIncludeStdLib)
        ...getCStandardLibraryHeadersForMac(),
      if (Platform.isMacOS) '-Wno-nullability-completeness',
    ];
  }
}

class _ObjCModulePrefixerEntry {
  final RegExp pattern;
  final String moduleName;

  _ObjCModulePrefixerEntry(this.pattern, this.moduleName);
}

/// Handles applying module prefixes to ObjC classes.
class ObjCModulePrefixer {
  final _prefixes = <_ObjCModulePrefixerEntry>[];

  ObjCModulePrefixer(Map<String, String> prefixes) {
    for (final entry in prefixes.entries) {
      _prefixes.add(_ObjCModulePrefixerEntry(RegExp(entry.key), entry.value));
    }
  }

  /// If any of the prefixing patterns match, applies that module prefix.
  /// Otherwise returns the class name unmodified.
  String applyPrefix(String className) {
    for (final entry in _prefixes) {
      if (quiver.matchesFull(entry.pattern, className)) {
        return '${entry.moduleName}.$className';
      }
    }
    return className;
  }
}

class FfiNativeConfig {
  final bool enabled;
  final String? assetId;

  const FfiNativeConfig({required this.enabled, this.assetId});
}

class SymbolFile {
  final Uri importPath;
  final Uri output;

  SymbolFile(this.importPath, this.output);
}

class OutputConfig {
  final String output;
  final String? outputObjC;
  final SymbolFile? symbolFile;

  OutputConfig(this.output, this.outputObjC, this.symbolFile);
}

class RawVarArgFunction {
  String? postfix;
  final List<String> rawTypeStrings;

  RawVarArgFunction(this.postfix, this.rawTypeStrings);
}

class VarArgFunction {
  final String postfix;
  final List<Type> types;

  VarArgFunction(this.postfix, this.types);
}

class PackingValue {
  int? value;
  PackingValue(this.value);
}

class ConfigImpl implements Config {
  @override
  final Uri? filename;

  @override
  final PackageConfig? packageConfig;

  @override
  final Uri libclangDylib;

  @override
  final Uri output;

  @override
  final Uri outputObjC;

  @override
  final SymbolFile? symbolFile;

  @override
  final Language language;

  @override
  final List<Uri> entryPoints;

  @override
  bool shouldIncludeHeader(Uri header) => shouldIncludeHeaderFunc(header);
  final bool Function(Uri header) shouldIncludeHeaderFunc;

  @override
  final List<String> compilerOpts;

  @override
  final Map<String, List<VarArgFunction>> varArgFunctions;

  @override
  final Declaration functionDecl;

  @override
  final Declaration structDecl;

  @override
  final Declaration unionDecl;

  @override
  final Declaration enumClassDecl;

  @override
  final Declaration unnamedEnumConstants;

  @override
  final Declaration globals;

  @override
  final Declaration macroDecl;

  @override
  final Declaration typedefs;

  @override
  final Declaration objcInterfaces;

  @override
  final Declaration objcProtocols;

  @override
  final bool includeUnusedTypedefs;

  @override
  final bool generateForPackageObjectiveC;

  @override
  final bool sort;

  @override
  final bool useSupportedTypedefs;

  @override
  final Map<String, LibraryImport> libraryImports;

  @override
  final Map<String, ImportedType> usrTypeMappings;

  @override
  final Map<String, ImportedType> typedefTypeMappings;

  @override
  final Map<String, ImportedType> structTypeMappings;

  @override
  final Map<String, ImportedType> unionTypeMappings;

  @override
  final Map<String, ImportedType> nativeTypeMappings;

  @override
  final CommentType commentType;

  @override
  final CompoundDependencies structDependencies;

  @override
  final CompoundDependencies unionDependencies;

  @override
  PackingValue? structPackingOverride(String name) =>
      structPackingOverrideFunc(name);
  final PackingValue? Function(String name) structPackingOverrideFunc;

  @override
  String applyInterfaceModulePrefix(String interfaceName) =>
      applyInterfaceModulePrefixFunc(interfaceName);
  final String Function(String interfaceName) applyInterfaceModulePrefixFunc;

  @override
  String applyProtocolModulePrefix(String protocolName) =>
      applyProtocolModulePrefixFunc(protocolName);
  final String Function(String protocolName) applyProtocolModulePrefixFunc;

  @override
  final String wrapperName;

  @override
  final String? wrapperDocComment;

  @override
  final String? preamble;

  @override
  final bool useDartHandle;

  @override
  final bool silenceEnumWarning;

  @override
  bool shouldExposeFunctionTypedef(String name) =>
      shouldExposeFunctionTypedefFunc(name);
  final bool Function(String name) shouldExposeFunctionTypedefFunc;

  @override
  bool isLeafFunction(String name) => isLeafFunctionFunc(name);
  final bool Function(String name) isLeafFunctionFunc;

  @override
  bool enumShouldBeInt(String name) => enumShouldBeIntFunc(name);
  final bool Function(String name) enumShouldBeIntFunc;

  @override
  bool unnamedEnumsShouldBeInt(String name) =>
      unnamedEnumsShouldBeIntFunc(name);
  final bool Function(String name) unnamedEnumsShouldBeIntFunc;

  @override
  final FfiNativeConfig ffiNativeConfig;

  @override
  final bool ignoreSourceErrors;

  @override
  final bool formatOutput;

  ConfigImpl({
    required this.filename,
    required this.packageConfig,
    required this.libclangDylib,
    required this.output,
    required this.outputObjC,
    required this.symbolFile,
    required this.language,
    required this.entryPoints,
    required this.shouldIncludeHeaderFunc,
    required this.compilerOpts,
    required this.varArgFunctions,
    required this.functionDecl,
    required this.structDecl,
    required this.unionDecl,
    required this.enumClassDecl,
    required this.unnamedEnumConstants,
    required this.globals,
    required this.macroDecl,
    required this.typedefs,
    required this.objcInterfaces,
    required this.objcProtocols,
    required this.includeUnusedTypedefs,
    required this.generateForPackageObjectiveC,
    required this.sort,
    required this.useSupportedTypedefs,
    required this.libraryImports,
    required this.usrTypeMappings,
    required this.typedefTypeMappings,
    required this.structTypeMappings,
    required this.unionTypeMappings,
    required this.nativeTypeMappings,
    required this.commentType,
    required this.structDependencies,
    required this.unionDependencies,
    required this.structPackingOverrideFunc,
    required this.applyInterfaceModulePrefixFunc,
    required this.applyProtocolModulePrefixFunc,
    required this.wrapperName,
    required this.wrapperDocComment,
    required this.preamble,
    required this.useDartHandle,
    required this.silenceEnumWarning,
    required this.shouldExposeFunctionTypedefFunc,
    required this.isLeafFunctionFunc,
    required this.enumShouldBeIntFunc,
    required this.unnamedEnumsShouldBeIntFunc,
    required this.ffiNativeConfig,
    required this.ignoreSourceErrors,
    required this.formatOutput,
  });
}

class DeclarationImpl implements Declaration {
  @override
  String rename(String name) => renameFunc(name);
  final String Function(String name) renameFunc;

  @override
  String renameMember(String declaration, String member) =>
      renameMemberFunc(declaration, member);
  final String Function(String declaration, String member) renameMemberFunc;

  @override
  bool shouldInclude(String name) => shouldIncludeFunc(name);
  final bool Function(String name) shouldIncludeFunc;

  @override
  bool shouldIncludeSymbolAddress(String name) =>
      shouldIncludeSymbolAddressFunc(name);
  final bool Function(String name) shouldIncludeSymbolAddressFunc;

  DeclarationImpl({
    required this.renameFunc,
    required this.renameMemberFunc,
    required this.shouldIncludeFunc,
    required this.shouldIncludeSymbolAddressFunc,
  });
}
