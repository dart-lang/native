// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'code_processor.dart';
import 'prompts.dart';
import 'public_abstractor.dart';

Future<String> dartifyNativeCode(String sourceCode, String bindingsPath) async {
  final bindingsFile = File(bindingsPath);

  if (!await bindingsFile.exists()) {
    stderr.writeln('File not found: $bindingsPath');
    exit(1);
  }

  final apiKey = Platform.environment['GEMINI_API_KEY'];

  if (apiKey == null) {
    stderr.writeln(r'No $GEMINI_API_KEY environment variable');
    exit(1);
  }

  final bindings = await bindingsFile.readAsString();

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
    generateBindingsSummary(bindings),
  );

  final chatSession = model.startChat();

  final response = await chatSession.sendMessage(
    Content.text(translatePrompt.prompt),
  );
  var mainCode = translatePrompt.getParsedResponse(response.text ?? '');
  var helperCode = '';

  final codeProcessor = CodeProcessor();
  mainCode = codeProcessor.addImports(mainCode, [
    'package:jni/jni.dart',
    bindingsFile.path,
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
  mainCode = codeProcessor.removeImports(mainCode);
  return mainCode;
}
