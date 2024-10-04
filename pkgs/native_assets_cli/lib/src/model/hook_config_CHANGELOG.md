## 1.6.0

- No changes, but rev version due to BuildConfig change.
- **Breaking change** Link hooks now have to explicitly add any file contents
  they rely on via `output.addDependency()` to ensure they re-run if the
  content of those files changes. (Previously if a linker script obtained code
  or data assets, the files referred to by those assets were implicitly added as
  a dependency, but adding custom asset types changed this behavior)
  NOTE: Newer Dart & Flutter SDKs will no longer add those dependencies
  implicitly which may make some older linker implementations that do not add
  dependencies explicitly not work correctly anymore: The linker scripts have
  to be updated to add those dependencies explicitly.

## 1.5.0

- BuildOutput.dependencies no longer have to list Dart dependencies.
  Backwards compatibility older SDKs: The caching will break.
  Backwards compatibility older hooks: The Dart sources will be both in the
  dependencies and in the native_assets_builder dependencies, which is fine.

## 1.4.0

- No changes, but rev version due to BuildConfig change.

## 1.3.0

- Add key for assets to be linked.  
  Backwards compatibility older build hooks: The key can be omitted.  
  Backwards compatibility older SDKs: These are ignored on older SDKs.  

## 1.2.0

- Changed default encoding to JSON.
  Backwards compatibility: JSON is parsable as YAML.
- Changed filename from `build_output.yaml` to `build_output.json`.
  Backwards compatibility older SDKs: write to the old file name if an older BuildConfig was passed in.
  Backwards compatibility: Try to read yaml file if json doesn't exist.

## 1.1.0

- Assets now have a `type`.
  Backwards compatibility: assets without a type are interpreted as `native_code` assets.
- Assets now have an optional `file`.
  Backwards compatibility: assets that have an `AssetAbsolutePath` will have that path used as `file`.
- **Breaking change** Assets now have a `dynamic_loading` field instead of `path_type`.
  The `absolute` path_type is renamed to `bundled` as dynamic loading type.
  Backwards compatibility: `path` is parsed as `dynamic_linking`.
  Backwards compatibility: the nested `path_type` is parsed as `type`.
  Backwards compatibility older SDKs: emit the old format if an older BuildConfig was passed in.
- Added `DataAsset`s.
  Backwards compatibility: These are ignored on older SDKs.
- `architecture` is optional.
  Backwards compatibility older SDKs: expand the assets to include all architectures.

## 1.0.0

- Initial version.
