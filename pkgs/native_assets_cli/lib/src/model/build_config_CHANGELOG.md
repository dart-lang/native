## 1.6.0

- `BuildConfig.outputDirectoryShared` for sharing between hook invocations.
  Compatibility with older SDKs: Create a sibling dir next to the output
  directory. This does not facilitate caching, but should not break the hook.
  Compatibility with older hooks: These will not read this field.

## 1.5.0

- No changes, but rev version due to BuildOutput change.

## 1.4.0

- Link hooks are not always run. `BuildConfig.linkingEnabled` communicates
  whether link hooks are run.
  Compatibility with older SDKs: the `linkingEnabled` is false with v1.2.0 and
  older, and true with v1.3.0.
  
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
