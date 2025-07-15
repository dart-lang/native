// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'prompts.dart';
import 'public_abstractor.dart';

Future<String> dartifyNativeCode(String sourceCode, String bindingsPath) async {
  final file = File(bindingsPath);

  if (!await file.exists()) {
    stderr.writeln('File not found: $bindingsPath');
    exit(1);
  }

  final apiKey = Platform.environment['GEMINI_API_KEY'];

  if (apiKey == null) {
    stderr.writeln(r'No $GEMINI_API_KEY environment variable');
    exit(1);
  }

  final bindings = await file.readAsString();

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

  print('Prompt:\n${translatePrompt.prompt}\n');

  final content = [Content.text(translatePrompt.prompt)];

  final response = await model.generateContent(content);
  final dartCode = translatePrompt.getParsedResponse(response.text ?? '');

  return dartCode;
}
