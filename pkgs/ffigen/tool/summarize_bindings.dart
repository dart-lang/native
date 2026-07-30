// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:args/args.dart';

class MemberSummary {
  final String sortName;
  final String formatted;

  MemberSummary({required this.sortName, required this.formatted});
}

class DeclarationSummary {
  final String sortName;
  final String formatted;
  final List<MemberSummary> members;

  DeclarationSummary({
    required this.sortName,
    required this.formatted,
    List<MemberSummary>? members,
  }) : members = members ?? [];
}

List<MemberSummary> _extractMembers(ClassMember member, String containerName) {
  final result = <MemberSummary>[];
  if (member is ConstructorDeclaration) {
    final name = member.name?.lexeme;
    if (name == null) {
      result.add(
        MemberSummary(sortName: containerName, formatted: containerName),
      );
    } else {
      final fullName = '$containerName.$name';
      result.add(MemberSummary(sortName: fullName, formatted: fullName));
    }
  } else if (member is MethodDeclaration) {
    final name = member.name.lexeme;
    if (member.isGetter) {
      result.add(MemberSummary(sortName: name, formatted: 'getter $name'));
    } else if (member.isSetter) {
      result.add(MemberSummary(sortName: name, formatted: 'setter $name='));
    } else {
      result.add(MemberSummary(sortName: name, formatted: 'method $name'));
    }
  } else if (member is FieldDeclaration) {
    final isConst = member.fields.isConst;
    for (final variable in member.fields.variables) {
      final name = variable.name.lexeme;
      if (isConst) {
        result.add(MemberSummary(sortName: name, formatted: 'constant $name'));
      } else {
        result.add(MemberSummary(sortName: name, formatted: 'field $name'));
      }
    }
  }
  return result;
}

String summarizeContent(String content) {
  final parseResult = parseString(
    content: content,
    featureSet: FeatureSet.latestLanguageVersion(),
    throwIfDiagnostics: false,
  );
  final unit = parseResult.unit;
  final declarations = <DeclarationSummary>[];

  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      final className = declaration.name.lexeme;
      final members = <MemberSummary>[];
      for (final member in declaration.members) {
        members.addAll(_extractMembers(member, className));
      }
      declarations.add(
        DeclarationSummary(
          sortName: className,
          formatted: 'class $className',
          members: members,
        ),
      );
    } else if (declaration is EnumDeclaration) {
      final enumName = declaration.name.lexeme;
      final members = <MemberSummary>[];
      for (final constant in declaration.constants) {
        final constName = constant.name.lexeme;
        members.add(
          MemberSummary(sortName: constName, formatted: 'constant $constName'),
        );
      }
      for (final member in declaration.members) {
        members.addAll(_extractMembers(member, enumName));
      }
      declarations.add(
        DeclarationSummary(
          sortName: enumName,
          formatted: 'enum $enumName',
          members: members,
        ),
      );
    } else if (declaration is ExtensionDeclaration) {
      final extName = declaration.name?.lexeme;
      final displayName = extName ?? '';
      final formattedHeader = extName != null
          ? 'extension $extName'
          : 'extension';
      final members = <MemberSummary>[];
      for (final member in declaration.members) {
        members.addAll(_extractMembers(member, extName ?? ''));
      }
      declarations.add(
        DeclarationSummary(
          sortName: displayName,
          formatted: formattedHeader,
          members: members,
        ),
      );
    } else if (declaration is ExtensionTypeDeclaration) {
      final extTypeName = declaration.name.lexeme;
      final members = <MemberSummary>[];
      final rep = declaration.representation;
      final repConstructorName = rep.constructorName;
      if (repConstructorName == null) {
        members.add(
          MemberSummary(sortName: extTypeName, formatted: extTypeName),
        );
      } else {
        final fullConstName = '$extTypeName.${repConstructorName.name.lexeme}';
        members.add(
          MemberSummary(sortName: fullConstName, formatted: fullConstName),
        );
      }
      final fieldName = rep.fieldName.lexeme;
      members.add(
        MemberSummary(sortName: fieldName, formatted: 'field $fieldName'),
      );

      for (final member in declaration.members) {
        members.addAll(_extractMembers(member, extTypeName));
      }
      declarations.add(
        DeclarationSummary(
          sortName: extTypeName,
          formatted: 'extension type $extTypeName',
          members: members,
        ),
      );
    } else if (declaration is MixinDeclaration) {
      final mixinName = declaration.name.lexeme;
      final members = <MemberSummary>[];
      for (final member in declaration.members) {
        members.addAll(_extractMembers(member, mixinName));
      }
      declarations.add(
        DeclarationSummary(
          sortName: mixinName,
          formatted: 'mixin $mixinName',
          members: members,
        ),
      );
    } else if (declaration is TypeAlias) {
      final aliasName = declaration.name.lexeme;
      declarations.add(
        DeclarationSummary(
          sortName: aliasName,
          formatted: 'typedef $aliasName',
        ),
      );
    } else if (declaration is FunctionDeclaration) {
      final funcName = declaration.name.lexeme;
      if (declaration.isGetter) {
        declarations.add(
          DeclarationSummary(sortName: funcName, formatted: 'getter $funcName'),
        );
      } else if (declaration.isSetter) {
        declarations.add(
          DeclarationSummary(
            sortName: funcName,
            formatted: 'setter $funcName=',
          ),
        );
      } else {
        declarations.add(
          DeclarationSummary(
            sortName: funcName,
            formatted: 'function $funcName',
          ),
        );
      }
    } else if (declaration is TopLevelVariableDeclaration) {
      for (final variable in declaration.variables.variables) {
        final varName = variable.name.lexeme;
        declarations.add(
          DeclarationSummary(sortName: varName, formatted: 'field $varName'),
        );
      }
    }
  }

  declarations.sort((a, b) {
    final nameComp = a.sortName.compareTo(b.sortName);
    if (nameComp != 0) return nameComp;
    return a.formatted.compareTo(b.formatted);
  });

  final buffer = StringBuffer();
  for (final decl in declarations) {
    buffer.writeln(decl.formatted);
    decl.members.sort((a, b) {
      final nameComp = a.sortName.compareTo(b.sortName);
      if (nameComp != 0) return nameComp;
      return a.formatted.compareTo(b.formatted);
    });
    for (final member in decl.members) {
      buffer.writeln('  ${member.formatted}');
    }
  }

  return buffer.toString();
}

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Path to write summary output to. Prints to stdout if omitted.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints usage instructions.',
    );

  late final ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    print('Error: $e\n');
    _printUsage(parser);
    exit(1);
  }

  if (results['help'] == true || results.rest.isEmpty) {
    _printUsage(parser);
    if (results['help'] != true && results.rest.isEmpty) {
      exit(1);
    }
    return;
  }

  final inputFilePath = results.rest.first;
  final String content;
  if (inputFilePath == '-') {
    content = await stdin.transform(utf8.decoder).join();
  } else {
    if (!File(inputFilePath).existsSync()) {
      print('Error: Input file "$inputFilePath" does not exist.');
      exit(1);
    }
    content = File(inputFilePath).readAsStringSync();
  }

  final summary = summarizeContent(content);

  final outputPath = results['output'] as String?;
  if (outputPath != null) {
    File(outputPath).writeAsStringSync(summary);
  } else {
    stdout.write(summary);
  }
}

void _printUsage(ArgParser parser) {
  print('Usage: dart run tool/summarize_bindings.dart [options] <file_path>');
  print(parser.usage);
}
