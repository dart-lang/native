---
name: refactor-dart-dot-shorthands
description: Refactor Dart code to use modern language features, specifically dot shorthands (member access shorthands) introduced in Dart 3.7. Use this when you want to make code more concise by removing redundant type names in enum or static member access when the context type is known.
---

# Refactor Dart Dot Shorthands

Apply Dart 3.7+ dot shorthands (member access shorthands) to simplify code where the context type is already known.

## Constraints

*   **Single Package Focus**: Only apply changes to a single package in `pkgs/` at a time. Do not spread changes across multiple packages in a single operation.
*   **CI Usage**: Only run `dart tool/ci.dart --all --fast` if changes are made to packages that are part of the top-level pub workspace (as defined in the root `pubspec.yaml`). If the package is not in the workspace, use local validation (`dart analyze`, `dart test`) within that package's directory.
*   **No `.new` Shorthand**: Do not use `.new` as a shorthand for constructors (e.g., keep `MyClass()` or `MyClass.new()` if explicit, but do not refactor to just `.new()`).
*   **Immediate Clarity**: Only use dot shorthands if the type is immediately clear from the line itself (e.g., in a typed variable declaration, a switch on a variable with a clear type, or a collection with an explicit type argument). Do not use them if identifying the type requires scrolling or searching elsewhere in the file.
*   **No Explicit Typing for Shorthands**: DO NOT add explicit type arguments to collections (e.g., changing `const x = [...]` to `const x = <Type>[...]`) or explicit types to variables just to enable the use of dot shorthands. Shorthands should only be used where the context type is already explicitly defined in the existing code.
*   **Variable/Parameter Naming**: Only use shorthands if the variable or parameter name contains the type name (or a very clear abbreviation). Avoid renaming variables or parameters solely to enable shorthands, especially if they are part of a public API or used in many locations.
*   **Avoid Complex Contexts**: Avoid using shorthands in complex contexts where inference might be brittle, such as inside nested tuples in switch statements, unless the analysis tool confirms it's valid.
*   **Maintain Formatting**: When refactoring lists or collections, preserve the original formatting (e.g., multiline lists with trailing commas). Do not squash them into a single line.
*   **No Redundant Shorthands**: Do not use dot shorthands if the member is already accessible without any qualifier (e.g., inside the class where the static member is defined). Prefer `member` over `.member` if both work.
*   **Iterative Progress Tracking**: You MUST update `SHORTHAND_PROGRESS.md` after processing each file (or a small batch of no more than 3 files). This ensures progress is visible and prevents losing work if the session is interrupted. Do not wait until the end of the package to update the progress file.

## Workflow

1.  **Select Target Package**: Choose a single package in `pkgs/` to refactor.
2.  **Initialize Progress**:
    *   Recursively list all `.dart` files in the package.
    *   Create a temporary markdown file (e.g., `SHORTHAND_PROGRESS.md`) containing a checklist of all files.
3.  **Iterative Refactoring**: Work through the files in small batches (1-3 files):
    *   **Identify**: Search for shorthand opportunities within the files that meet the **Constraints**.
    *   **Apply**: Replace `TypeName.memberName` with `.memberName`.
    *   **Validate**: Run `dart analyze` on the affected files/package.
    *   **Record**: Immediately update the checklist in `SHORTHAND_PROGRESS.md` to mark the processed files as completed. **Do not skip this step.**
4.  **Final Verification**:
    *   Once all files are processed, perform the final validation step as described in the **Verification** section.
5.  **Cleanup**: Delete the temporary progress file.

## Examples

### Arguments and named parameter default values

```dart
// Before
super.language = Language.c,
```

```dart
// After
super.language = .c,
```

Only do the refactoring if the receiver or parameter name contains the type modulo spacing.

```dart
// Before
super(type: OutputType.library);
```

```dart
// After, bad. (Type not clear from 'type' parameter)
super(type: .library);
```

If not part of the public API, consider renaming the named parameter to match the type name.

```dart
// After
super(outputType: .library);
```

However, only do this if the code quality doesn't suffer.

### Collections and Lists

Maintain multiline formatting for better readability.

```dart
// Before
const targets = [
  Architecture.arm,
  Architecture.arm64,
  Architecture.ia32,
  Architecture.x64,
];
```

```dart
// After
const targets = <Architecture>[
  .arm,
  .arm64,
  .ia32,
  .x64,
];
```

### Variable assignments and function calls

```dart
// Before
logger.level = Level.INFO;
```

```dart
// After
logger.level = .INFO;
```

If the type is contained in the name it is fine:

```dart
// Before
hostOS = hostOS ?? OS.current,
```

```dart
// After
hostOS = hostOS ?? .current,
```

Avoid shorthands if the context is lost:

```dart
// Before
await expectMachineArchitecture(libUri, target, OS.android);
```

```dart
// After, bad. (What is .android? Architecture? OS?)
await expectMachineArchitecture(libUri, target, .android);
```

### Equality checks

```dart
// Before
'/INCLUDE:${targetArch == Architecture.ia32 ? '_' : ''}$symbol'
```

```dart
// After, not great
'/INCLUDE:${targetArch == .ia32 ? '_' : ''}$symbol'
```

If variable names are not part of the public API, refactor variable name to match the type name.

```dart
// After
'/INCLUDE:${targetArchitecture == .ia32 ? '_' : ''}$symbol'
```

However only do this if it keeps the code understandable.

**Note**: Shorthands are most effective for enums and static constants used as values.

## Verification

After applying changes, run the following in the package directory:
```bash
dart analyze
```

If the package is part of the top-level workspace, run from the project root:
```bash
dart tool/ci.dart --all --fast
```
Otherwise, run tests locally in the package directory:
```bash
dart test
```
