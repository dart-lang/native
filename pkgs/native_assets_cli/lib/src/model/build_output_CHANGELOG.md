## 1.1.0

- Assets now have a `type`.
  Backwards compatibility: assets without a type are interpreted as `c_code` assets.
- Assets now have an optional `file`.
  Backwards compatibility: assets that have an `AssetAbsolutePath` will have that path used as `file`.

## 1.0.0

- Initial version.
