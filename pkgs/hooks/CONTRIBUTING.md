## Dartdoc Comments Code Blocks

Every code block must have a language.

Every Dart code block must have an HTML comment pointing to its source.

Examples:

(See source of this file!)

<!-- file://./example/api/config_snippet_1.dart -->
```dart
import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    output.assets.code.add(
      CodeAsset(
        name: 'my_code',
        file: Uri.file('path/to/file'),
        package: input.packageName,
        linkMode: DynamicLoadingBundled(),
      ),
    );
    output.assets.data.add(
      DataAsset(
        name: 'my_data',
        file: Uri.file('path/to/file'),
        package: input.packageName,
      ),
    );
  });
}
```

```yaml
foo: bar
```

This is enforced by `pkgs/hooks/tool/update_snippets.dart`.
