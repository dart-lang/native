// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:ffigenpad/src/header_parser/malloc.dart';
import 'clang_bindings/clang_bindings.dart' as clang;
import 'dart:convert' as convert;
import 'dart:js_interop';

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

extension CXSourceRangeExt on Pointer<clang.CXSourceRange> {
  void dispose() {
    malloc.free(this);
  }
}

extension CXCursorExt on Pointer<clang.CXCursor> {
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
    final cxfilePtr = malloc<Pointer<Void>>();

    // Puts the values in these pointers.
    clang.clang_getFileLocation_wrap(
        cxsource, cxfilePtr, nullptr, nullptr, nullptr);
    final s =
        clang.clang_getFileName_wrap(cxfilePtr.value).toStringAndDispose();

    malloc.free(cxfilePtr);
    return s;
  }

  int sourceFileOffset() {
    final cxsource = clang.clang_getCursorLocation_wrap(this);
    final cxOffset = malloc<Uint32>();

    // Puts the values in these pointers.
    clang.clang_getFileLocation_wrap(
        cxsource, nullptr, nullptr, nullptr, cxOffset);
    final offset = cxOffset.value;
    malloc.free(cxOffset);
    return offset;
  }

  /// Returns whether the file that the cursor is inside is a system header.
  bool isInSystemHeader() {
    final location = clang.clang_getCursorLocation_wrap(this);
    return clang.clang_Location_isInSystemHeader_wrap(location) != 0;
  }
}

extension CXStringExt on Pointer<clang.CXString> {
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

extension CXTypeExt on Pointer<clang.CXType> {
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
    final result = malloc<Uint8>(units.length + 1);
    for (int i = 0; i < units.length; i++) {
      result[i] = units[i];
    }
    result[units.length] = 0;
    return result;
  }
}

/// Converts a [List<String>] to [Pointer<Pointer<Uint8>>].
Pointer<Pointer<Uint8>> createDynamicStringArray(List<String> list) {
  final nativeCmdArgs = malloc<Pointer<Uint8>>(list.length);

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
      malloc.free(this[i]);
    }
    malloc.free(this);
  }
}

class CursorIndex {
  final _usrCursorDefinition = <String, Pointer<clang.CXCursor>>{};

  /// Returns the Cursor definition (if found) or itself.
  Pointer<clang.CXCursor> getDefinition(Pointer<clang.CXCursor> cursor) {
    final cursorDefinition = clang.clang_getCursorDefinition_wrap(cursor);
    if (clang.clang_Cursor_isNull_wrap(cursorDefinition) == 0) {
      return cursorDefinition;
    } else {
      final usr = cursor.usr();
      if (_usrCursorDefinition.containsKey(usr)) {
        return _usrCursorDefinition[cursor.usr()]!;
      } else {
        // _logger.warning('No definition found for declaration -'
        //     '${cursor.completeStringRepr()}');
        return cursor;
      }
    }
  }

  /// Saves cursor definition based on its kind.
  void saveDefinition(Pointer<clang.CXCursor> cursor) {
    switch (cursor.kind()) {
      case clang.CXCursorKind.CXCursor_StructDecl:
      case clang.CXCursorKind.CXCursor_UnionDecl:
      case clang.CXCursorKind.CXCursor_EnumDecl:
        final usr = cursor.usr();
        if (!_usrCursorDefinition.containsKey(usr)) {
          final cursorDefinition = clang.clang_getCursorDefinition_wrap(cursor);
          if (clang.clang_Cursor_isNull_wrap(cursorDefinition) == 0) {
            _usrCursorDefinition[usr] = cursorDefinition;
          } else {
            // _logger.finest(
            //     'Missing cursor definition in current translation unit: '
            //     '${cursor.completeStringRepr()}');
          }
        }
    }
  }
}
