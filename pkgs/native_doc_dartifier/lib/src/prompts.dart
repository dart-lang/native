// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

abstract class Prompt {
  String get prompt;
  dynamic getParsedResponse(String response);
}

class TranslatePrompt implements Prompt {
  final String sourceCode;
  final String bindingsSummary;
  TranslatePrompt(this.sourceCode, this.bindingsSummary);

  // TODO: Add few-shot examples for better translation quality.
  // Use examples from https://github.com/dart-lang/native/issues/2343
  String _fewShotExamples() => '';

  // Change this will require changing the getParsedResponse() method.
  final String _schema = '''
Output the response in JSON format:
{
  "dartCode": "Dart code here"
}
''';

  @override
  String get prompt => '''
You are an expert translator specializing in converting Java/Kotlin code to equivalent Dart code, leveraging provided JNI bindings. Your output must be *only* the Dart code snippet without any additional comments or explanations.

Your primary goal is to accurately translate the given Java/Kotlin code snippet into idiomatic Dart snippet, adhering to Dart conventions.

## JNIgen Naming Conventions and Structural Mappings:

JNIgen handles various syntactic and semantic differences between Java/Kotlin and Dart by applying specific naming conventions and structural mappings in the generated Dart bindings. It is crucial to understand these mappings to correctly use the provided bindings in your Dart code.

* **Method Overloading:**
    * Java allows methods with the same name but different signatures (overloading). Dart does not.
    * JNIgen resolves this by appending a dollar sign (`\$`) and a numeric suffix (e.g., `methodName\$1`, `methodName\$2`) to overloaded methods in the Dart bindings.
    * **Always refer to overloaded methods using their JNIgen-generated, dollar-suffixed names as found in the provided `Bindings Summary`.**

* **Fields and Methods with Same Name:**
    * Java allows a field and a method to have the same name. Dart does not.
    * JNIgen resolves this by keeping the field name as-is, and appending a dollar sign (`\$`) and a numeric suffix to the method name (e.g., `fieldName` for the field, `methodName\$1` for the method).
    * **Prioritize using the JNIgen-generated names for both fields and methods as defined in the `Bindings Summary`

* **Identifiers Containing Dollar Signs (`\$`):**
    * Java identifiers can contain dollar signs, while JNIgen uses them for its own renaming.
    * To prevent collision, JNIgen replaces each single dollar sign in original Java identifiers with two dollar signs (e.g., `original\$name` becomes `original\$\$name`).
    * **Use the double-dollar sign convention for Java identifiers that originally contained a single dollar sign, as reflected in the `Bindings Summary`.**

* **Identifiers Starting with Underscore (`_`):**
    * Dart identifiers starting with an underscore are private to their library.
    * To keep public Java identifiers starting with an underscore accessible in Dart, JNIgen prepends them with an additional dollar sign (e.g., `_javaMethod` becomes `\$_javaMethod`).
    * **Ensure to use the `\$`-prepended name for Java public identifiers that start with an underscore, as seen in the `Bindings Summary`.**

* **Inner Classes:**
    * Java has inner classes; Dart does not.
    * JNIgen converts Java inner classes into separate top-level Dart classes. Their names are formed by concatenating the outer class name, a dollar sign (`\$`), and the inner class name (e.g., `Outer\$Inner`).
    * **When referencing inner classes, use their JNIgen-generated flattened name (e.g., `Outer\$Inner`) as provided in the `Bindings Summary`.**

## Key Translation Rules:

* **String Conversion (Dart to JNI):** Use `'DartValue'.toJString()` when converting a Dart string to a JString for JNI calls.
* **String Conversion (JNI to Dart):** Use `JStringValue.toDartString()` when converting a JString received from JNI into a Dart string.
* **Method Calls:** Ensure the correct method name is used, matching the parameters of the original Java/Kotlin method.
* **Variable Naming:** Maintain variable names similar to the original Java/Kotlin code for clarity.
* **Variable Declaration:** Use `final` for variables that are not reassigned.
* **String Literals:** Use single quotes for all string literals in Dart.

* **Implementing Java Interfaces (General):** When translating Java/Kotlin code that involves implementing a Java interface (e.g., `Runnable`), follow the JNIgen-generated Dart patterns.
    * **Inline/Anonymous Class Implementation:**
        * Translate Java/Kotlin anonymous class implementations or lambdas into the Dart `InterfaceName.implement(\$InterfaceName(...))` syntax.
        * Pass each interface method as a named closure argument within the `\$InterfaceName` factory constructor.
        * Example: `InterfaceName.implement(\$InterfaceName(method1: (param1) { /* ... */ }))`
    * **Reusable Implementations:**
        * If the Java/Kotlin code defines a class that `implements` an interface, translate it to a Dart `final class` that `with` (mixes in) the corresponding `\$`-prefixed interface (e.g., `final class MyPrinter with \$Runnable`).
        * The Dart class should override the interface methods as required.
        * Instantiate and pass this class to the `implement` factory: `InterfaceName.implement(MyClassImplementingInterface(...))`
    * **Asynchronous Listener Methods:**
        * For `void`-returning methods in implemented interfaces that should be non-blocking (listeners), explicitly set the `<methodName>\$async` parameter to `true` when using the inline implementation (e.g., `run\$async: true`).
        * If using a reusable class (mixin), override the `<methodName>\$async` getter to return `true` (e.g., `bool get run\$async => true;`).
    * **Multiple Interface Implementations:**
        * When a single Java/Kotlin object implements multiple interfaces, use the `JImplementer` from `package:jni`.
        * For each interface, call `InterfaceName.implementIn(implementer, \$InterfaceName(...))` to register its implementation with the `JImplementer`.
        * Finally, call `implementer.implement(InterfaceType.type)` to get the composite object.

---

**Input:**

Here are the Bindings Summary (classes, fields, and methods):
```dart
$bindingsSummary
```

Here is the Java/Kotlin code to be converted:
```
$sourceCode
```

${_fewShotExamples()}

$_schema
''';

  @override
  String getParsedResponse(String response) {
    print('Response: $response');
    final json = jsonDecode(response) as Map<String, dynamic>;
    if (!json.containsKey('dartCode')) {
      return '';
    }
    final dartCode = json['dartCode'].toString();
    print('Dart Code: $dartCode');
    return dartCode;
  }
}

class FixPrompt implements Prompt {
  final String mainDartCode;
  final String helperDartCode;
  final String analysisResult;

  FixPrompt(this.mainDartCode, this.helperDartCode, this.analysisResult);

  // Change this will require changing the getParsedResponse() method.
  final String _schema = '''
Output the response in JSON format:
{
  "mainDartCode": "Dart code here",
  "helperDartCode": "Dart code here"
}
  ''';

  @override
  String get prompt => '''
  You are an expert Dart code fixer. Your task is to fix the provided main Dart code based on the analysis results.
  Here is the main Dart file code that needs fixing:
  $mainDartCode
  Here is the helper Dart file that you can use to add initialization code or other necessary imports to fix the issues in the main Dart code file:
  $helperDartCode
  Here are the issues found in the main Dart code:
  $analysisResult

  $_schema

  try to add initialization or imports or whatever in the helper Dart file to fix the errors as the main Dart file import this helper Dart file.
  change the main Dart file only if you can't fix the issues by adding code to the helper Dart file.
  do not make a full initializaiton or completed code in the helper Dart file, just add the necessary code to fix the issues in the main Dart file even if not complete.

  Make sure to not use a backslash (`\\`) before Dollar sign ('\$') in the Dart code, as it is not a valid Dart.
  ''';

  @override
  FixResponse getParsedResponse(String response) {
    print('Response: $response');
    final json = jsonDecode(response) as Map<String, dynamic>;
    var mainDartCode = '';
    var tempDartCode = '';
    if (json.containsKey('mainDartCode')) {
      mainDartCode = json['mainDartCode'].toString();
    }
    if (json.containsKey('helperDartCode')) {
      tempDartCode = json['helperDartCode'].toString();
    }
    return FixResponse(mainCode: mainDartCode, helperCode: tempDartCode);
  }
}

class FixResponse {
  final String mainCode;
  final String helperCode;

  FixResponse({required this.mainCode, required this.helperCode});
}
