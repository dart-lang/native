> [!CAUTION]
> This is an experimental package, and it's API can break at any time. Use at
> your own discretion.

This package provides the data classes for the usage recording feature in the
Dart SDK.

Dart objects with the `@RecordUse` annotation are being recorded at compile 
time, providing the user with information. The information depends on the object
being recorded.

- If placed on a static method, the annotation means that arguments passed to
the method will be recorded, as far as they can be inferred at compile time.
- If placed on a class with a constant constructor, the annotation means that
any constant instance of the class will be recorded.

> [!NOTE]
> The `@RecordUse` annotation is only allowed on definitions within a package's
> `lib/` directory. This includes definitions that are members of a class, such
> as static methods.

## Example

<!-- file://./example/api/usage.dart#usage -->
```dart
void main() {
  PirateTranslator.speak('Hello');
  print(const PirateShip('Black Pearl', 50));
}

abstract class PirateTranslator {
  @RecordUse()
  static String speak(String english) => 'Ahoy $english';
}

@RecordUse()
class PirateShip {
  final String name;
  final int cannons;

  const PirateShip(this.name, this.cannons);
}
```
This code will generate a data file that contains both the field values of
the `PirateShip` instances, as well as the arguments for the `speak`
method annotated with `@RecordUse()`.

This information can then be accessed in a link hook as follows:
<!-- file://./example/api/usage_link.dart#link -->
```dart
void main(List<String> arguments) {
  link(arguments, (input, output) async {
    final usesUri = input.recordedUsagesFile;
    if (usesUri == null) return;
    final usesJson = await File.fromUri(usesUri).readAsString();
    final uses = RecordedUsages.fromJson(
      jsonDecode(usesJson) as Map<String, Object?>,
    );

    final args = uses.constArgumentsFor(methodId);
    for (final arg in args) {
      if (arg.positional[0] case StringConstant(value: final english)) {
        print('Translating to pirate: $english');
        // Shrink a translations file based on all the different translation
        // keys.
      }
    }

    final ships = uses.constantsOf(classId);
    for (final ship in ships) {
      if (ship.fields['name'] case StringConstant(value: final name)) {
        print('Pirate ship found: $name');
        // Include the 3d model for this ship in the application but not
        // bundle the other ships.
      }
    }
  });
}
```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request.
