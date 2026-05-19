## 0.2.0

- Fix [a bug](https://github.com/dart-lang/native/issues/2666) where generated
  initializers were private.
- Add support for enums.
- Add support for operator overloading.
- Generate implicit constructors for structs.
- Add support for inout parameters.
- Add support for optional primitives.
- Fix [a bug](https://github.com/dart-lang/native/issues/3172) where nested
  types were generated incorrectly.
- Add support for tuples.
- Add support for generic referred types (e.g. `Array<T>`, `Dictionary<K, V>`,
  `Set<T>`) and preserve generic arguments in generated wrappers.
- Add support for extensions.

## 0.1.0

- MVP version.
