# JSON Syntax Generator

`package:json_syntax_generator` provides a powerful and flexible way to generate
Dart code from JSON schemas. It simplifies the process of working with JSON data
by automatically creating Dart classes that represent the structure of your JSON
data, including support for complex schema features.

## Features

This package is designed to handle a wide range of JSON schema features, including:

*   **Naming Conventions:** Converts snake-cased keys from JSON schemas to
    camel-cased Dart names, following Effective Dart guidelines.
*   **Optional and Required Fields:** Generates Dart constructors and getters
    with correct nullability based on the `required` property in the JSON
    schema.
*   **Subclassing:** Automatically recognizes and generates Dart subclasses from
    JSON schemas that use `allOf` to reference other definitions.
*   **Tagged Unions:** Handles tagged unions defined using `if`, `properties`,
    `type`, `const`, and `then` in the schema, generating appropriate Dart class
    hierarchies.
*   **Open Enums:** Interprets JSON schemas with `anyOf` containing `const`
    values and `type: string` as open enums, generating Dart classes with
    `static const` members for known values and support for unknown values.

## How It Works

`package:json_syntax_generator` operates as a pipeline with two steps:

1.  **Schema Analysis:** The `SchemaAnalyzer` class analyzes a JSON schema and
    extracts relevant information. It makes decisions about how code should be
    generated and encodes them in a `SchemaInfo` object. This includes
    determining class names, property types, inheritance relationships, and
    other schema features.
2.  **Code Generation:** The `SyntaxGenerator` class takes the `SchemaInfo`
    object and generates the corresponding Dart code. This code includes class
    definitions, constructors, getters, and setters, all tailored to the
    specific structure and requirements of the JSON schema.

