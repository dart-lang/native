# Use cases for `package:record_use`

This directory contains documents describing various use cases for the
`record_use` package. Each document outlines a specific scenario where the
package can be used to gather information about code for purposes like
tree-shaking, code generation, or analysis.

## Use Cases

- [Icon Font Tree-Shaking](./icon_data.md): Reducing the size of icon fonts in
  Flutter applications by tree-shaking unused icons.
- [ICU4X Data Tree-Shaking](./icu4x.md): Tree-shaking native code in the `icu4x`
  library to reduce binary size.
- [Jaspr Widget Trees](./jaspr.md): Extracting information from Jaspr widget
  trees to generate CSS, similar to Tailwind CSS.
- [JNIgen ProGuard Rules](./jnigen.md): Generating ProGuard rules for
  Java/Kotlin code used via `jnigen` to enable code shrinking.
- [Message Translation Tree-Shaking](./messages.md): Shrinking translation
  files by removing unused messages.
