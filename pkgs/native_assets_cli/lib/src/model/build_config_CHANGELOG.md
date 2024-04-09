## 1.3.0

- Rev version to know whether the Dart/Flutter SDK can consume
  `BuildOutput.assetsForLinking`. In earlier versions the key will not be read
  and the list of assets to be linked will be empty.

## 1.2.0

- Changed default encoding to JSON.
  Backwards compatibility: JSON is parsable as YAML.
- Changed default filename.
  Compatibility: The filename is explicitly passed in with --config.

## 1.1.0

- Added supported asset types.
  Backwards compatibility: Defaults to a list with a single element: `native_code`.

## 1.0.0

- Initial version.
