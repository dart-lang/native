// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains all the neccesary classes required by config.
library;

import 'dart:io';

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
class YamlDeclarationFilters implements DeclarationFilters {
  final YamlIncluder _includer;
  final YamlRenamer _renamer;
  final YamlMemberRenamer _memberRenamer;
  final YamlIncluder _symbolAddressIncluder;
  final bool excludeAllByDefault;

  YamlDeclarationFilters({
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
  String rename(Declaration declaration) =>
      _renamer.rename(declaration.originalName);

  /// Applies member renaming and returns the result.
  @override
  String renameMember(Declaration declaration, String member) =>
      _memberRenamer.rename(declaration.originalName, member);

  /// Checks if a name is allowed by a filter.
  @override
  bool shouldInclude(Declaration declaration) =>
      _includer.shouldInclude(declaration.originalName, excludeAllByDefault);

  /// Checks if the symbol address should be included for this name.
  @override
  bool shouldIncludeSymbolAddress(Declaration declaration) =>
      _symbolAddressIncluder.shouldInclude(declaration.originalName);
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

List<String> defaultCompilerOpts({bool macIncludeStdLib = true}) => [
      if (Platform.isMacOS && macIncludeStdLib)
        ...getCStandardLibraryHeadersForMac(),
      if (Platform.isMacOS) '-Wno-nullability-completeness',
    ];

/// Handles config for automatically added compiler options.
class CompilerOptsAuto {
  final bool macIncludeStdLib;

  CompilerOptsAuto({bool? macIncludeStdLib})
      : macIncludeStdLib = macIncludeStdLib ?? true;

  /// Extracts compiler options based on OS and config.
  List<String> extractCompilerOpts() {
    return defaultCompilerOpts(macIncludeStdLib: macIncludeStdLib);
  }
}

class _ObjCModuleEntry {
  final RegExp pattern;
  final String moduleName;

  _ObjCModuleEntry(this.pattern, this.moduleName);
}

/// Handles applying module prefixes to ObjC classes.
class ObjCModules {
  final _prefixes = <_ObjCModuleEntry>[];

  ObjCModules(Map<String, String> prefixes) {
    for (final entry in prefixes.entries) {
      _prefixes.add(_ObjCModuleEntry(RegExp(entry.key), entry.value));
    }
  }

  /// If any of the prefixing patterns match, returns the corresponding module.
  /// Otherwise returns null.
  String? getModule(String className) {
    for (final entry in _prefixes) {
      if (quiver.matchesFull(entry.pattern, className)) {
        return entry.moduleName;
      }
    }
    return null;
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

class Declaration {
  String usr;
  String originalName;
  Declaration({
    required this.usr,
    required this.originalName,
  });
}

class VersionTriple {
  final int major;
  final int minor;
  final int patch;
  const VersionTriple(this.major, [this.minor = 0, this.patch = 0]);

  static VersionTriple? parse(String? versionString) {
    if (versionString == null) {
      return null;
    }
    final match = _regex.firstMatch(versionString);
    if (match == null) {
      return null;
    }
    return VersionTriple(_toInt(match[1]), _toInt(match[2]), _toInt(match[3]));
  }

  static final _regex = RegExp(r'^([0-9]+)(?:\.([0-9]+)(?:\.([0-9]+))?)?$');
  static int _toInt(String? s) => s == null ? 0 : int.tryParse(s) ?? 0;

  @override
  String toString() => '$major.$minor.$patch';

  bool operator >=(VersionTriple? other) {
    if (other == null) {
      return false;
    }
    if (major != other.major) {
      return major >= other.major;
    }
    if (minor != other.minor) {
      return minor >= other.minor;
    }
    return patch >= other.patch;
  }
}

class ObjCTargetVersion {
  final VersionTriple? ios;
  final VersionTriple? macos;
  const ObjCTargetVersion({this.ios, this.macos});
}
