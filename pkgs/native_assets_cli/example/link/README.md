The examples in this folder illustrate how to use information from the Dart
treeshaking to "link" assets.

* [app_with_asset_treeshaking/](app_with_asset_treeshaking/) calls some methods
  from `package_with_assets`.
* [package_with_assets/](package_with_assets/) contains a library with two
  assets and code which uses these assets. It declares these assets in a
  `build.dart` hook, and treeshakes them based on the "resources" collected
  during the kernel compilation.
