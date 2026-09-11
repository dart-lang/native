// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as p;

import 'code_buffer.dart';
import 'path_resolver.dart';

/// Emits output target redirection and the `Output(...)` configuration.
class OutputEmitter {
  final Map<dynamic, dynamic> yamlMap;
  final PathResolver pathResolver;

  late final String rawDartOutput;
  late final String? rawObjcOutput;
  late final String? rawSymbolOutput;
  late final String? rawSymbolImport;

  late final bool hasObjc;
  late final bool hasCpp;

  OutputEmitter({required this.yamlMap, required this.pathResolver}) {
    hasObjc = yamlMap['language'] == 'objc';
    hasCpp = yamlMap.containsKey('cpp');

    final output = yamlMap['output'];
    if (output is String) {
      rawDartOutput = output;
      rawObjcOutput = hasObjc ? '$output.m' : null;
      rawSymbolOutput = null;
      rawSymbolImport = null;
    } else if (output is Map) {
      rawDartOutput = output['bindings'] as String;
      if (output.containsKey('objc-bindings')) {
        rawObjcOutput = output['objc-bindings'] as String;
      } else if (hasObjc) {
        rawObjcOutput = '$rawDartOutput.m';
      } else {
        rawObjcOutput = null;
      }

      if (output.containsKey('symbol-file')) {
        final sym = output['symbol-file'] as Map;
        rawSymbolOutput = sym['output'] as String;
        rawSymbolImport = sym['import-path'] as String;
      } else {
        rawSymbolOutput = null;
        rawSymbolImport = null;
      }
    } else {
      throw ArgumentError('Invalid output configuration: $output');
    }
  }

  /// Emits path redirection variables before the `FfiGenerator` constructor.
  void emitPathRedirections(CodeBuffer buffer) {
    final dartFileName = p.basename(rawDartOutput);
    final normalDartExpr = pathResolver.emitPath(rawDartOutput);
    buffer.writeln(
      'final dartPath = outputDir != null ? '
      "outputDir.resolve('$dartFileName') : $normalDartExpr;",
    );

    if (rawObjcOutput != null) {
      final objcFileName = p.basename(rawObjcOutput!);
      final normalObjcExpr = pathResolver.emitPath(rawObjcOutput!);
      buffer.writeln(
        'final objcPath = outputDir != null ? '
        "outputDir.resolve('$objcFileName') : $normalObjcExpr;",
      );
    }

    if (hasCpp) {
      final cppFileName = '${p.basename(rawDartOutput)}.cpp';
      final normalCppExpr = pathResolver.emitPath('$rawDartOutput.cpp');
      buffer.writeln(
        'final cppPath = outputDir != null ? '
        "outputDir.resolve('$cppFileName') : $normalCppExpr;",
      );
    }

    if (rawSymbolOutput != null) {
      final symFileName = p.basename(rawSymbolOutput!);
      final normalSymExpr = pathResolver.emitPath(rawSymbolOutput!);
      buffer.writeln(
        'final symbolFilePath = outputDir != null ? '
        "outputDir.resolve('$symFileName') : $normalSymExpr;",
      );
    }
  }

  /// Emits the `Output(...)` object argument.
  void emitOutput(CodeBuffer buffer) {
    buffer.writeln('output: Output(');
    buffer.indent();

    buffer.writeln('dart: DartOutput(path: dartPath),');

    if (rawObjcOutput != null) {
      buffer.writeln('objectiveCFile: objcPath,');
    }

    if (hasCpp) {
      buffer.writeln('cppFile: cppPath,');
    }

    if (rawSymbolOutput != null) {
      buffer.writeln(
        'symbolFile: '
        "SymbolFile(Uri.parse('$rawSymbolImport'), symbolFilePath),",
      );
    }

    _emitStyle(buffer);
    _emitCommentType(buffer);
    _emitPreamble(buffer);
    _emitFormat(buffer);

    buffer.dedent();
    buffer.writeln('),');
  }

  void _emitStyle(CodeBuffer buffer) {
    if (yamlMap.containsKey('ffi-native')) {
      final ffiNative = yamlMap['ffi-native'];
      if (ffiNative is Map) {
        final assetId = ffiNative['asset-id'] ?? ffiNative['assetId'];
        if (assetId != null) {
          buffer.writeln(
            "style: const NativeExternalBindings(assetId: '$assetId'),",
          );
          return;
        }
      }
      buffer.writeln('style: const NativeExternalBindings(),');
    } else {
      final name = yamlMap['name'] as String?;
      final description = yamlMap['description'] as String?;
      if (name != null || description != null) {
        buffer.writeln('style: const DynamicLibraryBindings(');
        buffer.indent();
        if (name != null) {
          buffer.writeln("wrapperName: '$name',");
        }
        if (description != null) {
          buffer.writeln(
            'wrapperDocComment: ${CodeBuffer.escapeString(description)},',
          );
        }
        buffer.dedent();
        buffer.writeln('),');
      }
    }
  }

  void _emitCommentType(CodeBuffer buffer) {
    final comments = yamlMap['comments'];
    if (comments == false) {
      buffer.writeln('commentType: const CommentType.none(),');
    } else if (comments is Map) {
      final length = comments['length'];
      final style = comments['style'];
      if (length == 'none') {
        buffer.writeln('commentType: const CommentType.none(),');
      } else if (length == 'brief') {
        buffer.writeln(
          'commentType: const CommentType('
          "CommentStyle.${style ?? 'doxygen'}, CommentLength.brief),",
        );
      } else if (style == 'any') {
        buffer.writeln(
          'commentType: const CommentType('
          'CommentStyle.any, CommentLength.full),',
        );
      }
    }
  }

  void _emitPreamble(CodeBuffer buffer) {
    final preamble = yamlMap['preamble'] as String?;
    if (preamble != null && preamble.isNotEmpty) {
      buffer.writeln('preamble: ${CodeBuffer.escapeString(preamble)},');
    }
  }

  void _emitFormat(CodeBuffer buffer) {
    if (yamlMap['format'] == false) {
      buffer.writeln('format: false,');
    }
  }
}
