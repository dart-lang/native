// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_buffer.dart';
import 'path_resolver.dart';

/// Emits the `Input(...)` configuration.
class InputEmitter {
  final Map<dynamic, dynamic> yamlMap;
  final PathResolver pathResolver;

  InputEmitter({required this.yamlMap, required this.pathResolver});

  void emitInput(CodeBuffer buffer) {
    buffer.writeln('input: Input(');
    buffer.indent();

    _emitEntryPoints(buffer);
    _emitInclude(buffer);
    _emitCompilerOptions(buffer);
    _emitIgnoreSourceErrors(buffer);

    buffer.dedent();
    buffer.writeln('),');
  }

  void _emitEntryPoints(CodeBuffer buffer) {
    final headers = yamlMap['headers'] as Map?;
    if (headers == null) return;

    final entryPoints = headers['entry-points'] as List?;
    if (entryPoints == null || entryPoints.isEmpty) return;

    buffer.writeln('entryPoints: [');
    buffer.indent();
    for (final ep in entryPoints) {
      buffer.writeln('${pathResolver.emitPath(ep.toString())},');
    }
    buffer.dedent();
    buffer.writeln('],');
  }

  void _emitInclude(CodeBuffer buffer) {
    final headers = yamlMap['headers'] as Map?;
    if (headers == null) return;

    final includeDirectives = headers['include-directives'] as List?;
    if (includeDirectives == null || includeDirectives.isEmpty) return;

    final conditions = <String>[];
    for (final dir in includeDirectives) {
      final pattern = dir.toString();
      if (pattern.startsWith('**')) {
        final suffix = pattern.substring(2);
        conditions.add("uri.path.endsWith('$suffix')");
      } else if (pattern.startsWith('*')) {
        final suffix = pattern.substring(1);
        conditions.add("uri.path.endsWith('$suffix')");
      } else if (pattern.contains('*')) {
        final regex = _globToRegex(pattern);
        conditions.add("RegExp(r'$regex').hasMatch(uri.path)");
      } else {
        conditions.add("uri.path.endsWith('$pattern')");
      }
    }

    buffer.writeln('include: (uri) => ${conditions.join(' || ')},');
  }

  void _emitCompilerOptions(CodeBuffer buffer) {
    final compilerOpts = yamlMap['compiler-opts'];
    if (compilerOpts == null) return;

    final List<String> opts;
    if (compilerOpts is String) {
      opts = _splitCompilerOpts(compilerOpts);
    } else if (compilerOpts is List) {
      opts = compilerOpts.map((e) => e.toString()).toList();
    } else {
      return;
    }

    if (opts.isEmpty) return;

    final auto = yamlMap['compiler-opts-automatic'] as Map?;
    final macAuto = auto?['macos'] as Map?;
    final includeMacStdLib = macAuto?['include-c-standard-library'] != false;

    final hasSysroot = opts.any(
      (o) => o.contains('-isysroot') || o.contains('MacOSX.sdk'),
    );

    buffer.writeln('compilerOptions: [');
    buffer.indent();
    for (final opt in opts) {
      buffer.writeln('${pathResolver.emitCompilerOption(opt)},');
    }
    if (includeMacStdLib && !hasSysroot) {
      buffer.writeln("if (Platform.isMacOS) ...['-isysroot', macSdkPath],");
    }
    buffer.dedent();
    buffer.writeln('],');
  }

  void _emitIgnoreSourceErrors(CodeBuffer buffer) {
    if (yamlMap['ignore-source-errors'] == true) {
      buffer.writeln('ignoreSourceErrors: true,');
    }
  }

  static List<String> _splitCompilerOpts(String str) {
    return str
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static String _globToRegex(String glob) {
    final buffer = StringBuffer();
    for (var i = 0; i < glob.length; i++) {
      final c = glob[i];
      if (c == '*') {
        if (i + 1 < glob.length && glob[i + 1] == '*') {
          buffer.write('.*');
          i++;
        } else {
          buffer.write('[^/]*');
        }
      } else if (c == '?') {
        buffer.write('[^/]');
      } else if (r'\.+^$()[]{}|'.contains(c)) {
        buffer.write(r'\');
        buffer.write(c);
      } else {
        buffer.write(c);
      }
    }
    return buffer.toString();
  }
}
