// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

const usage = '''
Usage: dart run tool/detect_classes.dart <path-to-binary>

Inspects a Mach-O binary (dylib, framework, or executable) using `nm` and
`swift demangle` to detect Objective-C and Swift classes and their associated
Swift modules.
''';

/// Represents a detected class and its enclosing Swift module (if any).
class DetectedClass {
  /// The Swift module containing the class, or `null` for plain Objective-C
  /// classes.
  final String? module;

  /// The unqualified class name.
  final String className;

  /// The raw symbol name extracted from the binary.
  final String rawSymbol;

  const DetectedClass({
    this.module,
    required this.className,
    required this.rawSymbol,
  });

  /// The fully-qualified runtime class name (e.g. `MyModule.MyClass` or
  /// `MyClass`).
  String get qualifiedName => module != null ? '$module.$className' : className;

  @override
  String toString() => qualifiedName;

  @override
  bool operator ==(Object other) =>
      other is DetectedClass &&
      other.module == module &&
      other.className == className &&
      other.rawSymbol == rawSymbol;

  @override
  int get hashCode => Object.hash(module, className, rawSymbol);
}

/// Regular expression matching `_OBJC_CLASS_$_<SymbolName>` in `nm` output.
final _objcClassRegex = RegExp(r'_OBJC_CLASS_\$_(.+)$');

/// Extracts unique class symbols from raw `nm` output.
Set<String> extractClassSymbols(String nmOutput) {
  final symbols = <String>{};
  for (final line in const LineSplitter().convert(nmOutput)) {
    final match = _objcClassRegex.firstMatch(line.trim());
    if (match != null) {
      final symbol = match.group(1)!.trim();
      if (symbol.isNotEmpty) {
        symbols.add(symbol);
      }
    }
  }
  return symbols;
}

/// Parses a demangled symbol output line from `swift demangle` or fallback
/// parser.
DetectedClass parseDemangledSymbol(String line, String rawSymbol) {
  var demangled = line.trim();
  // `swift demangle` may output `mangled ---> demangled` or just `demangled`.
  if (demangled.contains(' ---> ')) {
    demangled = demangled.split(' ---> ').last.trim();
  }

  if (demangled.contains('.')) {
    final dotIndex = demangled.lastIndexOf('.');
    final module = demangled.substring(0, dotIndex);
    final className = demangled.substring(dotIndex + 1);
    return DetectedClass(
      module: module,
      className: className,
      rawSymbol: rawSymbol,
    );
  }

  return DetectedClass(
    module: null,
    className: demangled,
    rawSymbol: rawSymbol,
  );
}

/// Fallback parser for standard Swift class mangling format:
/// `_TtC<module_length><module><class_length><class>`
DetectedClass? parseMangledSwiftClass(String symbol) {
  if (!symbol.startsWith('_TtC')) return null;

  var index = 4; // Skip '_TtC'

  int? readLength() {
    var lenStr = '';
    while (index < symbol.length &&
        symbol.codeUnitAt(index) >= 48 &&
        symbol.codeUnitAt(index) <= 57) {
      lenStr += symbol[index];
      index++;
    }
    return int.tryParse(lenStr);
  }

  final moduleLen = readLength();
  if (moduleLen == null || index + moduleLen > symbol.length) return null;
  final module = symbol.substring(index, index + moduleLen);
  index += moduleLen;

  final classLen = readLength();
  if (classLen == null || index + classLen > symbol.length) return null;
  final className = symbol.substring(index, index + classLen);

  return DetectedClass(module: module, className: className, rawSymbol: symbol);
}

/// Demangles a collection of raw symbols using `swift demangle` if available,
/// falling back to [parseMangledSwiftClass] or treating as Objective-C names.
Future<List<DetectedClass>> demangleSymbols(
  Iterable<String> rawSymbols, {
  Future<ProcessResult> Function(String executable, List<String> arguments)?
  runProcess,
  Future<Process> Function(String executable, List<String> arguments)?
  startProcess,
}) async {
  if (rawSymbols.isEmpty) return const [];

  final symbolList = rawSymbols.toList();

  // Attempt to use `swift demangle` via process piping.
  try {
    startProcess ??= Process.start;
    final process = await startProcess('swift', ['demangle']);
    process.stdin.writeln(symbolList.join('\n'));
    await process.stdin.close();

    final lines = await process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .toList();

    if (lines.length == symbolList.length) {
      final results = <DetectedClass>[];
      for (var i = 0; i < symbolList.length; i++) {
        results.add(parseDemangledSymbol(lines[i], symbolList[i]));
      }
      return results;
    }
  } catch (_) {
    // If `swift demangle` fails or is not found in PATH, use fallback parser.
  }

  // Fallback: parse mangled Swift names directly or treat as Objective-C.
  return symbolList.map((symbol) {
    return parseMangledSwiftClass(symbol) ??
        DetectedClass(module: null, className: symbol, rawSymbol: symbol);
  }).toList();
}

/// Groups detected classes by module name.
/// Plain Objective-C classes (without module) are keyed under `null`.
Map<String?, List<DetectedClass>> groupClassesByModule(
  Iterable<DetectedClass> classes,
) {
  final grouped = <String?, List<DetectedClass>>{};
  for (final cls in classes) {
    grouped.putIfAbsent(cls.module, () => []).add(cls);
  }
  for (final list in grouped.values) {
    list.sort((a, b) => a.className.compareTo(b.className));
  }
  return grouped;
}

/// Formats the detection results into a user-readable string report.
String formatReport(String binaryPath, List<DetectedClass> classes) {
  if (classes.isEmpty) {
    return 'No Objective-C or Swift class symbols found in $binaryPath.';
  }

  final buffer = StringBuffer();
  final countStr = classes.length == 1
      ? '1 class'
      : '${classes.length} classes';
  buffer.writeln('Detected $countStr in $binaryPath:\n');

  final grouped = groupClassesByModule(classes);
  final sortedModules = grouped.keys.toList()
    ..sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });

  var hasSwiftModule = false;

  for (final module in sortedModules) {
    final list = grouped[module]!;
    if (module != null) {
      hasSwiftModule = true;
      buffer.writeln("Module '$module':");
      for (final cls in list) {
        buffer.writeln('  - ${cls.className} (${cls.qualifiedName})');
      }
    } else {
      buffer.writeln('Objective-C (no Swift module):');
      for (final cls in list) {
        buffer.writeln('  - ${cls.className}');
      }
    }
    buffer.writeln();
  }

  if (hasSwiftModule) {
    buffer.writeln(
      'To configure a class from a specific module in swiftgen, use an '
      'FfiGenerator visitor:',
    );
    buffer.writeln('  fg.Visitor(');
    buffer.writeln('    objCInterface: (node) {');
    buffer.writeln("      if (node.name == '<ClassName>') {");
    buffer.writeln("        node.module = '<ModuleName>';");
    buffer.writeln('      }');
    buffer.writeln('    },');
    buffer.writeln('  )');
  }

  return buffer.toString().trimRight();
}

/// Inspects a binary at [binaryPath] and detects all Objective-C and Swift
/// classes.
Future<List<DetectedClass>> detectClasses(
  String binaryPath, {
  Future<ProcessResult> Function(String executable, List<String> arguments)?
  runProcess,
  Future<Process> Function(String executable, List<String> arguments)?
  startProcess,
}) async {
  runProcess ??= Process.run;
  ProcessResult nmResult;
  try {
    nmResult = await runProcess('nm', [binaryPath]);
  } on ProcessException {
    throw const ProcessException(
      'nm',
      [],
      'Could not execute "nm". Ensure Xcode Command Line Tools are installed '
          'and "nm" is in your PATH.',
    );
  }

  if (nmResult.exitCode != 0) {
    throw ProcessException(
      'nm',
      [binaryPath],
      nmResult.stderr.toString(),
      nmResult.exitCode,
    );
  }

  final symbols = extractClassSymbols(nmResult.stdout.toString());
  return await demangleSymbols(
    symbols,
    runProcess: runProcess,
    startProcess: startProcess,
  );
}

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('-h') || args.contains('--help')) {
    print(usage);
    exit(args.isEmpty ? 64 : 0);
  }

  final binaryPath = args.first;
  final file = File(binaryPath);
  if (!file.existsSync()) {
    stderr.writeln('Error: Binary file not found at "$binaryPath".');
    exit(66);
  }

  try {
    final classes = await detectClasses(binaryPath);
    print(formatReport(binaryPath, classes));
  } on ProcessException catch (e) {
    stderr.writeln('Error running ${e.executable}: ${e.message}');
    exit(e.errorCode != 0 ? e.errorCode : 1);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
