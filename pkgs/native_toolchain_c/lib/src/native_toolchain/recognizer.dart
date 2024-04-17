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
import 'msvc.dart' as msvc;

class CompilerRecognizer implements ToolResolver {
  final Uri uri;

  CompilerRecognizer(this.uri);

  @override
  Future<List<ToolInstance>> resolve({required Logger? logger}) async {
    final os = OS.current;
    logger?.finer('Trying to recognize $uri.');
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-gcc')) {
      tool = gcc;
    } else if (filePath.endsWith(os.executableFileName('clang'))) {
      tool = await _whichClang(uri, logger, tool);
    } else if (filePath.endsWith('cl.exe')) {
      tool = msvc.cl;
    }

    if (tool != null) {
      logger?.fine('Tool instance $uri is likely $tool.');
      final toolInstance = ToolInstance(tool: tool, uri: uri);
      return [
        await CliVersionResolver.lookupVersion(
          toolInstance,
          logger: logger,
          arguments: [
            if (tool != msvc.cl) '--version',
          ],
        ),
      ];
    }

    logger?.severe('Tool instance $uri not recognized.');
    return [];
  }
}

Future<Tool?> _whichClang(Uri uri, Logger? logger, Tool? tool) async {
  final stdout =
      await CliFilter.executeCli(uri, arguments: ['--version'], logger: logger);
  if (stdout.contains('Apple clang')) {
    tool = appleClang;
  } else {
    tool = clang;
  }
  return tool;
}

class LinkerRecognizer implements ToolResolver {
  final Uri uri;
  final OS os;

  LinkerRecognizer(this.uri, this.os);

  @override
  Future<List<ToolInstance>> resolve({required Logger? logger}) async {
    final os = OS.current;
    logger?.finer('Trying to recognize $uri.');
    final filePath = uri.toFilePath();
    Tool? tool;

    //TODO: Make this logic more correct
    if (filePath.endsWith(os.executableFileName('clang'))) {
      tool = await _whichClang(uri, logger, tool);
    } else if (filePath.endsWith(os.executableFileName('ld.lld'))) {
      tool = lld;
    } else if (filePath.endsWith('ld')) {
      if (os == OS.macOS) {
        tool = appleLd;
      } else {
        tool = gnuLinker;
      }
    } else if (os == OS.windows && filePath.endsWith('link.exe')) {
      tool = msvc.link;
    }

    if (tool != null) {
      logger?.fine('Tool instance $uri is likely $tool.');
      final toolInstance = ToolInstance(tool: tool, uri: uri);
      if (tool == clang) {
        return [
          await CliVersionResolver.lookupVersion(
            toolInstance,
            logger: logger,
            arguments: ['--version'],
          ),
        ];
      }
      if (tool == lld) {
        return [
          await CliVersionResolver.lookupVersion(
            toolInstance,
            logger: logger,
          ),
        ];
      }
      if (tool == msvc.link) {
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
    final os = OS.current;
    final filePath = uri.toFilePath();
    Tool? tool;
    if (filePath.contains('-gcc-ar')) {
      tool = gnuArchiver;
    } else if (filePath.endsWith(os.executableFileName('llvm-ar'))) {
      tool = llvmAr;
    } else if (filePath.endsWith(os.executableFileName('ar'))) {
      tool = appleAr;
    } else if (filePath.endsWith('lib.exe')) {
      tool = msvc.lib;
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
