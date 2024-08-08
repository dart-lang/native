// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';

import '../code_generator.dart';
import '../config_provider/config_types.dart';
import 'clang_bindings/clang_bindings.dart' as clang_types;
import 'data.dart';
import 'type_extractor/extractor.dart';

final _logger = Logger('ffigen.header_parser.utils');

const exceptionalVisitorReturn =
    clang_types.CXChildVisitResult.CXChildVisit_Break;

typedef _CursorVisitorCallback = Int32 Function(
    clang_types.CXCursor, clang_types.CXCursor, Pointer<Void>);

/// Logs the warnings/errors returned by clang for a translation unit.
void logTuDiagnostics(
    Pointer<clang_types.CXTranslationUnitImpl> tu, Logger logger, String header,
    {Level logLevel = Level.SEVERE}) {
  final total = clang.clang_getNumDiagnostics(tu);
  if (total == 0) {
    return;
  }
  logger.log(logLevel, 'Header $header: Total errors/warnings: $total.');
  for (var i = 0; i < total; i++) {
    final diag = clang.clang_getDiagnostic(tu, i);
    if (clang.clang_getDiagnosticSeverity(diag) >=
        clang_types.CXDiagnosticSeverity.CXDiagnostic_Warning) {
      hasSourceErrors = true;
    }
    final cxstring = clang.clang_formatDiagnostic(
      diag,
      clang_types
              .CXDiagnosticDisplayOptions.CXDiagnostic_DisplaySourceLocation |
          clang_types.CXDiagnosticDisplayOptions.CXDiagnostic_DisplayColumn |
          clang_types
              .CXDiagnosticDisplayOptions.CXDiagnostic_DisplayCategoryName,
    );
    logger.log(logLevel, '    ${cxstring.toStringAndDispose()}');
    clang.clang_disposeDiagnostic(diag);
  }
}

extension CXSourceRangeExt on Pointer<clang_types.CXSourceRange> {
  void dispose() {
    calloc.free(this);
  }
}

extension CXCursorExt on clang_types.CXCursor {
  String usr() {
    var res = clang.clang_getCursorUSR(this).toStringAndDispose();
    if (isAnonymousRecordDecl()) {
      res += '@offset:${sourceFileOffset()}';
    }
    return res;
  }

  /// Returns the kind int from [clang_types.CXCursorKind].
  int kind() {
    return clang.clang_getCursorKind(this);
  }

  /// Name of the cursor (E.g function name, Struct name, Parameter name).
  String spelling() {
    return clang.clang_getCursorSpelling(this).toStringAndDispose();
  }

  /// Spelling for a [clang_types.CXCursorKind], useful for debug purposes.
  String kindSpelling() {
    return clang
        .clang_getCursorKindSpelling(clang.clang_getCursorKind(this))
        .toStringAndDispose();
  }

  /// Get code_gen [Type] representation of [clang_types.CXType].
  Type toCodeGenType() {
    return getCodeGenType(type(), originalCursor: this);
  }

  /// for debug: returns [spelling] [kind] [kindSpelling] type typeSpelling.
  String completeStringRepr() {
    final cxtype = type();
    final s = '(Cursor) spelling: ${spelling()}, kind: ${kind()}, '
        'kindSpelling: ${kindSpelling()}, type: ${cxtype.kind}, '
        'typeSpelling: ${cxtype.spelling()}, usr: ${usr()}';
    return s;
  }

  /// Type associated with the pointer if any. Type will have kind
  /// clang.CXTypeKind.CXType_Invalid otherwise.
  clang_types.CXType type() {
    return clang.clang_getCursorType(this);
  }

  /// Determine whether the given cursor
  /// represents an anonymous record declaration.
  bool isAnonymousRecordDecl() {
    return clang.clang_Cursor_isAnonymousRecordDecl(this) == 1;
  }

  /// Only valid for clang.CXCursorKind.CXCursor_FunctionDecl. Type will have
  /// kind clang.CXTypeKind.CXType_Invalid otherwise.
  clang_types.CXType returnType() {
    return clang.clang_getResultType(type());
  }

  /// Returns the file name of the file that the cursor is inside.
  String sourceFileName() {
    final cxsource = clang.clang_getCursorLocation(this);
    final cxfilePtr = calloc<Pointer<Void>>();

    // Puts the values in these pointers.
    clang.clang_getFileLocation(cxsource, cxfilePtr, nullptr, nullptr, nullptr);
    final s = clang.clang_getFileName(cxfilePtr.value).toStringAndDispose();

    calloc.free(cxfilePtr);
    return s;
  }

  int sourceFileOffset() {
    final cxsource = clang.clang_getCursorLocation(this);
    final cxOffset = calloc<UnsignedInt>();

    // Puts the values in these pointers.
    clang.clang_getFileLocation(cxsource, nullptr, nullptr, nullptr, cxOffset);
    final offset = cxOffset.value;
    calloc.free(cxOffset);
    return offset;
  }

  /// Returns whether the file that the cursor is inside is a system header.
  bool isInSystemHeader() {
    final location = clang.clang_getCursorLocation(this);
    return clang.clang_Location_isInSystemHeader(location) != 0;
  }

  /// Visits all the direct children of this cursor.
  ///
  /// [callback] is called with the child cursor. The iteration continues until
  /// completion. The only way it can be interrupted is if the [callback]
  /// throws, in which case this method also throws.
  void visitChildren(void Function(clang_types.CXCursor child) callback) {
    final completed = visitChildrenMayBreak((clang_types.CXCursor child) {
      callback(child);
      return true;
    });
    if (!completed) {
      throw Exception('Exception thrown in a dart function called via C, '
          'use --verbose to see more details');
    }
  }

  /// Visits all the direct children of this cursor.
  ///
  /// [callback] is called with the child cursor. If [callback] returns true,
  /// the iteration will continue. Otherwise, if [callback] returns false, the
  /// iteration will stop.
  ///
  /// Returns whether the iteration completed.
  bool visitChildrenMayBreak(
          bool Function(clang_types.CXCursor child) callback) =>
      visitChildrenMayRecurse(
          (clang_types.CXCursor child, clang_types.CXCursor parent) =>
              callback(child)
                  ? clang_types.CXChildVisitResult.CXChildVisit_Continue
                  : clang_types.CXChildVisitResult.CXChildVisit_Break);

  /// Visits all the direct children of this cursor.
  ///
  /// [callback] is called with the child cursor and parent cursor. If
  /// [callback] returns CXChildVisit_Continue, the iteration continues. If it
  /// returns CXChildVisit_Break the iteration stops. If it returns
  /// CXChildVisit_Recurse, the iteration recurses into the node.
  ///
  /// Returns whether the iteration completed.
  bool visitChildrenMayRecurse(
      int Function(clang_types.CXCursor child, clang_types.CXCursor parent)
          callback) {
    final visitor = NativeCallable<_CursorVisitorCallback>.isolateLocal(
        (clang_types.CXCursor child, clang_types.CXCursor parent,
                Pointer<Void> clientData) =>
            callback(child, parent),
        exceptionalReturn: exceptionalVisitorReturn);
    final result =
        clang.clang_visitChildren(this, visitor.nativeFunction.cast(), nullptr);
    visitor.close();
    return result == 0;
  }

  /// Returns the first child with the given CXCursorKind, or null if there
  /// isn't one.
  clang_types.CXCursor? findChildWithKind(int kind) {
    clang_types.CXCursor? result;
    visitChildrenMayBreak((child) {
      if (child.kind == kind) {
        result = child;
        return false;
      }
      return true;
    });
    return result;
  }

  /// Returns whether there is a child with the given CXCursorKind.
  bool hasChildWithKind(int kind) => findChildWithKind(kind) != null;

  /// Recursively print the AST, for debugging.
  void printAst([int maxDepth = 3]) => _printAst(maxDepth, 0);
  void _printAst(int maxDepth, int depth) {
    if (depth > maxDepth) {
      return;
    }
    print(('  ' * depth) + completeStringRepr());
    visitChildren((child) => child._printAst(maxDepth, depth + 1));
  }
}

const commentPrefix = '/// ';
const nesting = '  ';

/// Stores the [clang_types.CXSourceRange] of the last comment.
clang_types.CXSourceRange? lastCommentRange;

/// Returns a cursor's associated comment.
///
/// The given string is wrapped at line width = 80 - [indent]. The [indent] is
/// [commentPrefix].length by default because a comment starts with
/// [commentPrefix].
String? getCursorDocComment(clang_types.CXCursor cursor,
    [int indent = commentPrefix.length]) {
  String? formattedDocComment;
  final currentCommentRange = clang.clang_Cursor_getCommentRange(cursor);

  // See if this comment and the last comment both point to the same source
  // range.
  if (lastCommentRange != null &&
      clang.clang_equalRanges(lastCommentRange!, currentCommentRange) != 0) {
    formattedDocComment = null;
  } else {
    switch (config.commentType.length) {
      case CommentLength.full:
        formattedDocComment = removeRawCommentMarkups(
            clang.clang_Cursor_getRawCommentText(cursor).toStringAndDispose());
        break;
      case CommentLength.brief:
        formattedDocComment = _wrapNoNewLineString(
            clang.clang_Cursor_getBriefCommentText(cursor).toStringAndDispose(),
            80 - indent);
        break;
      default:
        formattedDocComment = null;
    }
  }
  lastCommentRange = currentCommentRange;
  return formattedDocComment;
}

/// Wraps [string] according to given [lineWidth].
///
/// Wrapping will work properly only when String has no new lines
/// characters(\n).
String? _wrapNoNewLineString(String? string, int lineWidth) {
  if (string == null || string.isEmpty) {
    return null;
  }
  final sb = StringBuffer();

  final words = string.split(' ');

  sb.write(words[0]);
  var trackLineWidth = words[0].length;
  for (var i = 1; i < words.length; i++) {
    final word = words[i];
    if (trackLineWidth + word.length < lineWidth) {
      sb.write(' ');
      sb.write(word);
      trackLineWidth += word.length + 1;
    } else {
      sb.write('\n');
      sb.write(word);
      trackLineWidth = word.length;
    }
  }
  return sb.toString();
}

/// Removes /*, */ and any *'s in the beginning of a line.
String? removeRawCommentMarkups(String? string) {
  if (string == null || string.isEmpty) {
    return null;
  }
  final sb = StringBuffer();

  // Remove comment identifiers (`/** * */`, `///`, `//`) from lines.
  if (string.contains(RegExp(r'^\s*\/\*+'))) {
    string = string.replaceFirst(RegExp(r'^\s*\/\*+\s*'), '');
    string = string.replaceFirst(RegExp(r'\s*\*+\/$'), '');
    string.split('\n').forEach((element) {
      element = element.replaceFirst(RegExp(r'^\s*\**\s*'), '');
      sb.writeln(element);
    });
  } else if (string.contains(RegExp(r'^\s*\/\/\/?\s*'))) {
    string.split('\n').forEach((element) {
      element = element.replaceFirst(RegExp(r'^\s*\/\/\/?\s*'), '');
      sb.writeln(element);
    });
  }

  return sb.toString().trim();
}

extension CXTypeExt on clang_types.CXType {
  /// Get code_gen [Type] representation of [clang_types.CXType].
  Type toCodeGenType({bool supportNonInlineArray = false}) {
    return getCodeGenType(this, supportNonInlineArray: supportNonInlineArray);
  }

  /// Spelling for a [clang_types.CXTypeKind], useful for debug purposes.
  String spelling() {
    return clang.clang_getTypeSpelling(this).toStringAndDispose();
  }

  /// Returns the typeKind int from [clang_types.CXTypeKind].
  int kind() {
    return this.kind;
  }

  String kindSpelling() {
    return clang.clang_getTypeKindSpelling(kind()).toStringAndDispose();
  }

  int alignment() {
    return clang.clang_Type_getAlignOf(this);
  }

  /// For debugging: returns [spelling] [kind] [kindSpelling].
  String completeStringRepr() {
    final s = '(Type) spelling: ${spelling()}, kind: ${kind()}, '
        'kindSpelling: ${kindSpelling()}';
    return s;
  }

  bool get isConstQualified {
    return clang.clang_isConstQualifiedType(this) != 0;
  }
}

extension CXStringExt on clang_types.CXString {
  /// Convert CXString to a Dart string
  ///
  /// Make sure to dispose CXstring using dispose method, or use the
  /// [toStringAndDispose] method.
  String string() {
    final cstring = clang.clang_getCString(this);
    if (cstring != nullptr) {
      return cstring.cast<Utf8>().toDartString();
    } else {
      return '';
    }
  }

  /// Converts CXString to dart string and disposes CXString.
  String toStringAndDispose() {
    // Note: clang_getCString_wrap returns a const char *, calling free will
    // result in error.
    final s = string();
    clang.clang_disposeString(this);
    return s;
  }

  void dispose() {
    clang.clang_disposeString(this);
  }
}

extension CXVersionExt on clang_types.CXVersion {
  VersionTriple? get triple {
    // -1 can appear in a CXVersion, and has various meanings.
    // Whenever one of the fields is -1, the subsequent fields are also -1 (eg
    // you can't have Minor=-1 and Subminor=4). If all 3 fields are -1, it means
    // "no version", and we return null. Otherwise, we treat a -1 in any field
    // as a 0.
    if (Major < 0) return null;
    return VersionTriple(
        Major, Minor < 0 ? 0 : Minor, Subminor < 0 ? 0 : Subminor);
  }

  String string() => '$Major.$Minor.$Subminor';
}

/// Converts a [List<String>] to [Pointer<Pointer<Utf8>>].
Pointer<Pointer<Utf8>> createDynamicStringArray(List<String> list) {
  final nativeCmdArgs = calloc<Pointer<Utf8>>(list.length);

  for (var i = 0; i < list.length; i++) {
    nativeCmdArgs[i] = list[i].toNativeUtf8();
  }

  return nativeCmdArgs;
}

extension DynamicCStringArray on Pointer<Pointer<Utf8>> {
  // Properly disposes a Pointer<Pointer<Utf8>, ensure that sure length is
  // correct.
  void dispose(int length) {
    for (var i = 0; i < length; i++) {
      calloc.free(this[i]);
    }
    calloc.free(this);
  }
}

class Stack<T> {
  final _stack = <T>[];

  T get top => _stack.last;
  T pop() => _stack.removeLast();
  void push(T item) => _stack.add(item);
}

class IncrementalNamer {
  final _incrementedStringCounters = <String, int>{};

  /// Appends `<int>` to base. <int> is incremented on every call.
  String name(String base) {
    var i = _incrementedStringCounters[base] ?? 0;
    i++;
    _incrementedStringCounters[base] = i;
    return '$base$i';
  }
}

class Macro {
  final String usr;
  final String? originalName;

  Macro(this.usr, this.originalName);
}

/// Tracks if a binding is 'seen' or not.
class BindingsIndex {
  // Tracks if bindings are already seen, Map key is USR obtained from libclang.
  final Map<String, Type> _declaredTypes = {};
  final Map<String, Func> _functions = {};
  final Map<String, Constant> _unnamedEnumConstants = {};
  final Map<String, String> _macros = {};
  final Map<String, Global> _globals = {};
  final Map<String, ObjCBlock> _objcBlocks = {};
  final Map<String, ObjCProtocol> _objcProtocols = {};

  /// Contains usr for typedefs which cannot be generated.
  final Set<String> _unsupportedTypealiases = {};

  /// Index for headers.
  final Map<String, bool> _headerCache = {};

  bool isSeenType(String usr) => _declaredTypes.containsKey(usr);
  void addTypeToSeen(String usr, Type type) => _declaredTypes[usr] = type;
  Type? getSeenType(String usr) => _declaredTypes[usr];
  bool isSeenFunc(String usr) => _functions.containsKey(usr);
  void addFuncToSeen(String usr, Func func) => _functions[usr] = func;
  Func? getSeenFunc(String usr) => _functions[usr];
  bool isSeenUnnamedEnumConstant(String usr) =>
      _unnamedEnumConstants.containsKey(usr);
  void addUnnamedEnumConstantToSeen(String usr, Constant enumConstant) =>
      _unnamedEnumConstants[usr] = enumConstant;
  Constant? getSeenUnnamedEnumConstant(String usr) =>
      _unnamedEnumConstants[usr];
  bool isSeenGlobalVar(String usr) => _globals.containsKey(usr);
  void addGlobalVarToSeen(String usr, Global global) => _globals[usr] = global;
  Global? getSeenGlobalVar(String usr) => _globals[usr];
  bool isSeenMacro(String usr) => _macros.containsKey(usr);
  void addMacroToSeen(String usr, String macro) => _macros[usr] = macro;
  String? getSeenMacro(String usr) => _macros[usr];
  bool isSeenUnsupportedTypealias(String usr) =>
      _unsupportedTypealiases.contains(usr);
  void addUnsupportedTypealiasToSeen(String usr) =>
      _unsupportedTypealiases.add(usr);
  bool isSeenHeader(String source) => _headerCache.containsKey(source);
  void addHeaderToSeen(String source, bool includeStatus) =>
      _headerCache[source] = includeStatus;
  bool? getSeenHeaderStatus(String source) => _headerCache[source];
  void addObjCBlockToSeen(String key, ObjCBlock t) => _objcBlocks[key] = t;
  ObjCBlock? getSeenObjCBlock(String key) => _objcBlocks[key];
  void addObjCProtocolToSeen(String usr, ObjCProtocol t) =>
      _objcProtocols[usr] = t;
  ObjCProtocol? getSeenObjCProtocol(String usr) => _objcProtocols[usr];
  bool isSeenObjCProtocol(String usr) => _objcProtocols.containsKey(usr);
}

class CursorIndex {
  final _usrCursorDefinition = <String, clang_types.CXCursor>{};

  /// Returns the Cursor definition (if found) or itself.
  clang_types.CXCursor getDefinition(clang_types.CXCursor cursor) {
    final cursorDefinition = clang.clang_getCursorDefinition(cursor);
    if (clang.clang_Cursor_isNull(cursorDefinition) == 0) {
      return cursorDefinition;
    } else {
      final usr = cursor.usr();
      if (_usrCursorDefinition.containsKey(usr)) {
        return _usrCursorDefinition[cursor.usr()]!;
      } else {
        _logger.warning('No definition found for declaration -'
            '${cursor.completeStringRepr()}');
        return cursor;
      }
    }
  }

  /// Saves cursor definition based on its kind.
  void saveDefinition(clang_types.CXCursor cursor) {
    switch (cursor.kind) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
      case clang_types.CXCursorKind.CXCursor_EnumDecl:
        final usr = cursor.usr();
        if (!_usrCursorDefinition.containsKey(usr)) {
          final cursorDefinition = clang.clang_getCursorDefinition(cursor);
          if (clang.clang_Cursor_isNull(cursorDefinition) == 0) {
            _usrCursorDefinition[usr] = cursorDefinition;
          } else {
            _logger.finest(
                'Missing cursor definition in current translation unit: '
                '${cursor.completeStringRepr()}');
          }
        }
    }
  }
}
