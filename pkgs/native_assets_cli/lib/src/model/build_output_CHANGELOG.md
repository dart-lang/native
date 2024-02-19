## 1.1.0

- Assets now have a `type`.
  Backwards compatibility: assets without a type are interpreted as `c_code` assets.
- Assets now have an optional `file`.
  Backwards compatibility: assets that have an `AssetAbsolutePath` will have that path used as `file`.
- Assets now have a `dynamic_loading` field instead of `path_type`.
  The `absolute` path_type is renamed to `bundled` as dynamic loading type.
  Backwards compatibility: `path` is parsed as `dynamic_linking`.
  Backwards compatibility: the nested `path_type` is parsed as `type`.

## 1.0.0

- Initial version.
