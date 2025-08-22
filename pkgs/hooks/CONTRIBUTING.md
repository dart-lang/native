## Dartdoc Comments Code Blocks

Every code block must have a language.

Every Dart code block must have an HTML comment pointing to its source.

Correct:

```
    <!-- file://./CONTRIBUTING.md -->
    ```dart
    void main() {}
    ```
```

```
    ```yaml
    foo: bar
    ```
```

Incorrect:

```
    ```
    void main() {}
    ```
```

```
    ```dart
    void main() {}
    ```
```

This is enforced by `pkgs/hooks/tool/update_snippets.dart`.
