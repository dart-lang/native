# Examples

The following complete examples use link hooks (`hook/link.dart`) and
`package:record_use` to tree-shake native C libraries
(`LinkerOptions.treeshake`):

| Example | Description | Used Features |
| :--- | :--- | :--- |
| [`mini_audio`](../../code_assets/example/mini_audio) | Play audio. | - Tree-shaking C library built from source with `package:native_toolchain_c` based on recorded Dart calls.<br/>- Link hook (`hook/link.dart`) with `LinkerOptions.treeshake`. |
| [`sqlite`](../../code_assets/example/sqlite) | Database access. | - Tree-shaking C library built from source with `package:native_toolchain_c` based on recorded Dart calls.<br/>- Link hook (`hook/link.dart`) with `LinkerOptions.treeshake`. |
| [`stb_image`](../../code_assets/example/stb_image) | Read image metadata. | - Tree-shaking C library built from source with `package:native_toolchain_c` based on recorded Dart calls.<br/>- Link hook (`hook/link.dart`) with `LinkerOptions.treeshake`. |
