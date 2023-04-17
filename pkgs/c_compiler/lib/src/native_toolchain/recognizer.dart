// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import 'clang.dart';
import 'gcc.dart';

class CompilerRecognizer implements ToolResolver {
  final Uri uri;

  CompilerRecognizer(this.uri);

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    logger?.finer('Trying to recognize $uri.');
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-gcc')) {
      tool = gcc;
    } else if (filePath.contains('clang')) {
      tool = clang;
    }

    if (tool != null) {
      logger?.fine('Tool instance $uri is likely $tool.');
      final toolInstance = ToolInstance(tool: tool, uri: uri);
      return [
        await CliVersionResolver.lookupVersion(
          toolInstance,
          logger: logger,
        ),
      ];
    }

    logger?.severe('Tool instance $uri not recognized.');
    return [];
  }
}

class LinkerRecognizer implements ToolResolver {
  final Uri uri;

  LinkerRecognizer(this.uri);

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    logger?.finer('Trying to recognize $uri.');
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-ld')) {
      tool = gnuLinker;
    } else if (filePath.contains('ld.lld')) {
      tool = lld;
    }

    if (tool != null) {
      logger?.fine('Tool instance $uri is likely $tool.');
      final toolInstance = ToolInstance(tool: tool, uri: uri);
      if (tool == lld) {
        return [
          await CliVersionResolver.lookupVersion(
            toolInstance,
            logger: logger,
          ),
        ];
      }
      return [toolInstance];
    }

    logger?.severe('Tool instance $uri not recognized.');
    return [];
  }
}

class ArchiverRecognizer implements ToolResolver {
  final Uri uri;

  ArchiverRecognizer(this.uri);

  @override
  Future<List<ToolInstance>> resolve({Logger? logger}) async {
    logger?.finer('Trying to recognize $uri.');
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-gcc-ar')) {
      tool = gnuArchiver;
    } else if (filePath.contains('llvm-ar')) {
      tool = llvmAr;
    }

    if (tool != null) {
      logger?.fine('Tool instance $uri is likely $tool.');
      final toolInstance = ToolInstance(tool: tool, uri: uri);
      if (tool == llvmAr) {
        return [
          await CliVersionResolver.lookupVersion(
            toolInstance,
            logger: logger,
          ),
        ];
      }
      return [toolInstance];
    }

    logger?.severe('Tool instance $uri not recognized.');
    return [];
  }
}
