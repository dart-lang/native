## 1.6.0

- BuildOutput.dependencies is no longer a flat list of uris. Instead it's
  two maps with asset dependencies and asset-type dependencies.
  Backwards compatibility older SDKs: The serializer will output a flat list of
  dependencies.
  Backwards compatibiility older hooks: The deserializer will add the flat list
  of dependencies to each asset type and each asset.
- Renamed `assetForLinking` to `asset_for_linking`
  Backwards compatibility for older SDKs: The serializer will output the old key.
  Backwards compatibility for older hooks: try both the old and new key.

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
