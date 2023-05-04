// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import '../tool/tool.dart';
import '../tool/tool_instance.dart';
import '../tool/tool_resolver.dart';
import 'apple_clang.dart';
import 'clang.dart';
import 'gcc.dart';
import 'msvc.dart';

class CompilerRecognizer implements ToolResolver {
  final Uri uri;

  CompilerRecognizer(this.uri);

  @override
  Future<List<ToolInstance>> resolve({required Logger? logger}) async {
    final os = Target.current.os;
    logger?.finer('Trying to recognize $uri.');
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-gcc')) {
      tool = gcc;
    } else if (filePath.endsWith(os.executableFileName('clang'))) {
      final stdout = await CliFilter.executeCli(uri,
          arguments: ['--version'], logger: logger);
      if (stdout.contains('Apple clang')) {
        tool = appleClang;
      } else {
        tool = clang;
      }
    } else if (filePath.endsWith('cl.exe')) {
      tool = cl;
    }

    if (tool != null) {
      logger?.fine('Tool instance $uri is likely $tool.');
      final toolInstance = ToolInstance(tool: tool, uri: uri);
      return [
        await CliVersionResolver.lookupVersion(
          toolInstance,
          logger: logger,
          arguments: [
            if (tool != cl) '--version',
          ],
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
  Future<List<ToolInstance>> resolve({required Logger? logger}) async {
    final os = Target.current.os;
    logger?.finer('Trying to recognize $uri.');
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-ld')) {
      tool = gnuLinker;
    } else if (filePath.endsWith(os.executableFileName('ld.lld'))) {
      tool = lld;
    } else if (filePath.endsWith(os.executableFileName('ld'))) {
      tool = appleLd;
    } else if (filePath.endsWith('link.exe')) {
      tool = link;
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
      if (tool == link) {
        return [
          await CliVersionResolver.lookupVersion(
            toolInstance,
            logger: logger,
            arguments: ['/help'],
            expectedExitCode: 1100,
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
  Future<List<ToolInstance>> resolve({required Logger? logger}) async {
    logger?.finer('Trying to recognize $uri.');
    final os = Target.current.os;
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-gcc-ar')) {
      tool = gnuArchiver;
    } else if (filePath.endsWith(os.executableFileName('llvm-ar'))) {
      tool = llvmAr;
    } else if (filePath.endsWith(os.executableFileName('ar'))) {
      tool = appleAr;
    } else if (filePath.endsWith('lib.exe')) {
      tool = lib;
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
