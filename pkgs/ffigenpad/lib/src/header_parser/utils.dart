// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:logging/logging.dart';
import 'package:ffigenpad/src/header_parser/calloc.dart';
import 'clang_bindings/clang_types.dart' as clang_types;
import 'clang_bindings/clang_bindings.dart' as clang;
import 'dart:convert' as convert;
import 'dart:js_interop';

import 'package:ffigen/src/header_parser/utils.dart' show commentPrefix;

export 'package:ffigen/src/header_parser/utils.dart'
    show
        commentPrefix,
        nesting,
        removeRawCommentMarkups,
        Stack,
        IncrementalNamer,
        Macro;

/// dart interop for emscripten's addFunction
@JS()
external int addFunction(JSExportedDartFunction func, String signature);

final _logger = Logger('ffigen.header_parser.utils');

const exceptionalVisitorReturn =
    clang_types.CXChildVisitResult.CXChildVisit_Break;

/// Logs the warnings/errors returned by clang for a translation unit.
void logTuDiagnostics(
    clang_types.CXTranslationUnit tu, Logger logger, String header,
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
      // TODO
      // hasSourceErrors = true;
    }
    final cxstring = clang.clang_formatDiagnostic_wrap(
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

extension CXSourceRangeExt on clang_types.CXSourceRange {
  void dispose() {
    calloc.free(this);
  }
}

extension CXCursorExt on clang_types.CXCursor {
  String usr() {
    var res = clang.clang_getCursorUSR_wrap(this).toStringAndDispose();
    if (isAnonymousRecordDecl()) {
      res += '@offset:${sourceFileOffset()}';
    }
    return res;
  }

  /// Returns the kind int from [clang.CXCursorKind].
  int kind() {
    return clang.clang_getCursorKind_wrap(this);
  }

  /// Name of the cursor (E.g function name, Struct name, Parameter name).
  String spelling() {
    return clang.clang_getCursorSpelling_wrap(this).toStringAndDispose();
  }

  /// Spelling for a [clang.CXCursorKind], useful for debug purposes.
  String kindSpelling() {
    return clang
        .clang_getCursorKindSpelling_wrap(clang.clang_getCursorKind_wrap(this))
        .toStringAndDispose();
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
  /// [clang.CXTypeKind.CXType_Invalid] otherwise.
  Pointer<clang.CXType> type() {
    return clang.clang_getCursorType_wrap(this);
  }

  /// Determine whether the given cursor
  /// represents an anonymous record declaration.
  bool isAnonymousRecordDecl() {
    return clang.clang_Cursor_isAnonymousRecordDecl_wrap(this) == 1;
  }

  /// Only valid for [clang.CXCursorKind.CXCursor_FunctionDecl]. Type will have
  /// kind [clang.CXTypeKind.CXType_Invalid] otherwise.
  Pointer<clang.CXType> returnType() {
    return clang.clang_getResultType_wrap(type());
  }

  /// Returns the file name of the file that the cursor is inside.
  String sourceFileName() {
    final cxsource = clang.clang_getCursorLocation_wrap(this);
    final cxfilePtr = calloc<Pointer<Void>>();

    // Puts the values in these pointers.
    clang.clang_getFileLocation_wrap(
        cxsource, cxfilePtr, nullptr, nullptr, nullptr);
    final s =
        clang.clang_getFileName_wrap(cxfilePtr.value).toStringAndDispose();

    calloc.free(cxfilePtr);
    return s;
  }

  int sourceFileOffset() {
    final cxsource = clang.clang_getCursorLocation_wrap(this);
    final cxOffset = calloc<Uint32>();

    // Puts the values in these pointers.
    clang.clang_getFileLocation_wrap(
        cxsource, nullptr, nullptr, nullptr, cxOffset);
    final offset = cxOffset.value;
    calloc.free(cxOffset);
    return offset;
  }

  /// Returns whether the file that the cursor is inside is a system header.
  bool isInSystemHeader() {
    final location = clang.clang_getCursorLocation_wrap(this);
    return clang.clang_Location_isInSystemHeader_wrap(location) != 0;
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
    int visitorWrapper(int childAddress, int parentAddress, int _) {
      final child = Pointer<clang.CXCursor>.fromAddress(childAddress);
      final parent = Pointer<clang.CXCursor>.fromAddress(parentAddress);
      return callback(child, parent);
    }

    final visitorIndex = addFunction(visitorWrapper.toJS, 'iiii');
    final result = clang.clang_visitChildren_wrap(this, visitorIndex);
    removeFunction(visitorIndex);
    return result == 0;
  }
}

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
  final currentCommentRange = clang.clang_Cursor_getCommentRange_wrap(cursor);

  // See if this comment and the last comment both point to the same source
  // range.
  if (lastCommentRange != null &&
      clang.clang_equalRanges_wrap(lastCommentRange!, currentCommentRange) !=
          0) {
    formattedDocComment = null;
  } else {
    // TODO: add config object
    // switch (config.commentType.length) {
    //   case CommentLength.full:
    //     formattedDocComment = removeRawCommentMarkups(
    //         clang.clang_Cursor_getRawCommentText_wrap(cursor).toStringAndDispose());
    //     break;
    //   case CommentLength.brief:
    //     formattedDocComment = _wrapNoNewLineString(
    //         clang.clang_Cursor_getBriefCommentText_wrap(cursor).toStringAndDispose(),
    //         80 - indent);
    //     break;
    //   default:
    //     formattedDocComment = null;
    // }
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

extension CXStringExt on clang_types.CXString {
  void dispose() {
    clang.clang_disposeString_wrap(this);
  }

  /// Converts CXString to dart string and disposes CXString.
  String toStringAndDispose() {
    final codeUnits = clang.clang_getCString_wrap(this);
    List<int> output = [];
    int length = 0;
    while (codeUnits[length] != 0) {
      output.add(codeUnits[length]);
      length++;
    }
    dispose();
    return convert.utf8.decode(output);
  }
}

extension CXTypeExt on clang_types.CXType {
  /// Spelling for a [clang_types.CXTypeKind], useful for debug purposes.
  String spelling() {
    return clang.clang_getTypeSpelling_wrap(this).toStringAndDispose();
  }

  /// Returns the typeKind int from [clang_types.CXTypeKind].
  int kind() {
    return clang.getCXTypeKind(this);
  }

  String kindSpelling() {
    return clang.clang_getTypeKindSpelling_wrap(kind()).toStringAndDispose();
  }

  int alignment() {
    return clang.clang_Type_getAlignOf_wrap(this);
  }

  /// For debugging: returns [spelling] [kind] [kindSpelling].
  String completeStringRepr() {
    final s = '(Type) spelling: ${spelling()}, kind: ${kind()}, '
        'kindSpelling: ${kindSpelling()}';
    return s;
  }

  bool get isConstQualified {
    return clang.clang_isConstQualifiedType_wrap(this) != 0;
  }
}

extension StringUtf8Pointer on String {
  /// Converts string into an array of bytes and allocates it in WASM memory
  Pointer<Uint8> toNativeUint8() {
    final units = convert.utf8.encode(this);
    final result = calloc<Uint8>(units.length + 1);
    for (int i = 0; i < units.length; i++) {
      result[i] = units[i];
    }
    result[units.length] = 0;
    return result;
  }
}

/// Converts a [List<String>] to [Pointer<Pointer<Uint8>>].
Pointer<Pointer<Uint8>> createDynamicStringArray(List<String> list) {
  final nativeCmdArgs = calloc<Pointer<Uint8>>(list.length);

  for (var i = 0; i < list.length; i++) {
    nativeCmdArgs[i] = list[i].toNativeUint8();
  }

  return nativeCmdArgs;
}

extension DynamicCStringArray on Pointer<Pointer<Uint8>> {
  // Properly disposes a Pointer<Pointer<Uint8>, ensure that sure length is
  // correct.
  void dispose(int length) {
    for (var i = 0; i < length; i++) {
      calloc.free(this[i]);
    }
    calloc.free(this);
  }
}

class CursorIndex {
  final _usrCursorDefinition = <String, clang_types.CXCursor>{};

  /// Returns the Cursor definition (if found) or itself.
  Pointer<clang.CXCursor> getDefinition(clang_types.CXCursor cursor) {
    final cursorDefinition = clang.clang_getCursorDefinition_wrap(cursor);
    if (clang.clang_Cursor_isNull_wrap(cursorDefinition) == 0) {
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
    switch (cursor.kind()) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
      case clang_types.CXCursorKind.CXCursor_EnumDecl:
        final usr = cursor.usr();
        if (!_usrCursorDefinition.containsKey(usr)) {
          final cursorDefinition = clang.clang_getCursorDefinition_wrap(cursor);
          if (clang.clang_Cursor_isNull_wrap(cursorDefinition) == 0) {
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
