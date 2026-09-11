// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Helper for generating formatted Dart code with imports, indentation,
/// and literals.
class CodeBuffer {
  final StringBuffer _buffer = StringBuffer();
  final Set<String> _dartImports = {};
  final Set<String> _packageImports = {};
  final Set<String> _relativeImports = {};

  int _indentLevel = 0;
  bool _atStartOfLine = true;

  void indent() {
    _indentLevel++;
  }

  void dedent() {
    if (_indentLevel > 0) _indentLevel--;
  }

  void addImport(String uri) {
    if (uri.startsWith('dart:')) {
      _dartImports.add(uri);
    } else if (uri.startsWith('package:')) {
      _packageImports.add(uri);
    } else {
      _relativeImports.add(uri);
    }
  }

  void write(String s) {
    if (_atStartOfLine && s.isNotEmpty) {
      _buffer.write('  ' * _indentLevel);
      _atStartOfLine = false;
    }
    _buffer.write(s);
  }

  void writeln([String s = '']) {
    if (s.isNotEmpty) {
      write(s);
    }
    _buffer.writeln();
    _atStartOfLine = true;
  }

  /// Formats all imports grouped by category:
  /// dart: imports, package: imports, and relative imports.
  String generateImports() {
    final buffer = StringBuffer();
    final groups = <List<String>>[
      _dartImports.toList()..sort(),
      _packageImports.toList()..sort(),
      _relativeImports.toList()..sort(),
    ];

    var firstGroup = true;
    for (final group in groups) {
      if (group.isEmpty) continue;
      if (!firstGroup) {
        buffer.writeln();
      }
      firstGroup = false;
      for (final importUri in group) {
        buffer.writeln("import '$importUri';");
      }
    }

    return buffer.toString();
  }

  @override
  String toString() => _buffer.toString();

  /// Escapes a string to be a Dart single-line or multi-line string literal.
  static String escapeString(String s) {
    if (s.contains('\n')) {
      final escaped = s
          .replaceAll(r'\', r'\\')
          .replaceAll("'''", r"\'\'\'")
          .replaceAll(r'$', r'\$');
      return "'''\n$escaped'''";
    }
    final escaped = s
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$');
    return "'$escaped'";
  }

  /// Converts a value to Dart literal representation.
  static String toLiteral(dynamic value) {
    if (value == null) return 'null';
    if (value is bool || value is num) return value.toString();
    if (value is String) return escapeString(value);
    if (value is List) {
      if (value.isEmpty) return '[]';
      return '[${value.map(toLiteral).join(', ')}]';
    }
    if (value is Set) {
      if (value.isEmpty) return '{}';
      return '{${value.map(toLiteral).join(', ')}}';
    }
    if (value is Map) {
      if (value.isEmpty) return '{}';
      final entries = value.entries.map(
        (e) => '${toLiteral(e.key)}: ${toLiteral(e.value)}',
      );
      return '{${entries.join(', ')}}';
    }
    return value.toString();
  }
}
