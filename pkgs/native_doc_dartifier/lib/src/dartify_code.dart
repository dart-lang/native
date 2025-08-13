// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'code_processor.dart';
import 'context.dart';
import 'prompts.dart';

Future<String> dartifyNativeCode(String sourceCode, Context context) async {
  final apiKey = Platform.environment['GEMINI_API_KEY'];

  if (apiKey == null) {
    stderr.writeln(r'No $GEMINI_API_KEY environment variable');
    exit(1);
  }

  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 0,
      topK: 64,
      topP: 0.95,
      maxOutputTokens: 8192,
      responseMimeType: 'application/json',
    ),
  );

  final translatePrompt = TranslatePrompt(
    sourceCode,
    context.toDartLikeRepresentation(),
  );

  final chatSession = model.startChat();

  final response = await chatSession.sendMessage(
    Content.text(translatePrompt.prompt),
  );
  var mainCode = translatePrompt.getParsedResponse(response.text ?? '');
  var helperCode = '';

  final codeProcessor = CodeProcessor();

  print('imported pkgs: ${context.importedPackages.join(', ')}');
  print('bindings file: ${context.bindingsFileAbsolutePath}');
  mainCode = codeProcessor.addImports(mainCode, [
    ...context.importedPackages,
    context.bindingsFileAbsolutePath,
  ]);

  for (var i = 0; i < 3; i++) {
    final errorMessage = await codeProcessor.analyzeCode(mainCode, helperCode);
    if (errorMessage.isEmpty) {
      break;
    }
    stderr.writeln('Dart analysis found issues: $errorMessage');
    final fixPrompt = FixPrompt(mainCode, helperCode, errorMessage);
    final fixResponse = await chatSession.sendMessage(
      Content.text(fixPrompt.prompt),
    );
    final fixedCode = fixPrompt.getParsedResponse(fixResponse.text ?? '');

    mainCode = fixedCode.mainCode;
    helperCode = fixedCode.helperCode;
  }
  mainCode = codeProcessor.removeHelperCodeImport(mainCode);
  return mainCode;
}
