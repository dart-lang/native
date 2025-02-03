## 1.9.0

- `CCompilerConfig` now nests the Windows config under
  `.windows.developerCommandPrompt`.
  Compatibility with older hooks: Previous JSON structure is still emitted.
  Compatibility with older SDKs: Still parse the old JSON.

## 1.8.0

- Add `BuildInput.outputFile` to specify the outfile. This means the out file 
  can be outside the `outputDirectory` and avoid potential conflicts.
  Compatibility with older hooks: If the file doesn't exist, try the previous
  location.
  Compatibility with older SDKs: Default the location to where it was.

## 1.7.0

- Complete rewrite of JSON
  Compatibility with older hooks: also emit old structure.
  Compatibility with older SDKs: keep parsing old structure.

## 1.6.0

- `BuildConfig.supportedAssetTypes` renamed to `BuildConfig.buildAssetTypes`.
  Compatibility with older SDKs: Look for the old key. Compatibility with older
  hooks: Also provide the old hook in the config.
- `BuildConfig.targetOS` is now only provided if `buildAssetTypes` contains the
  code asset.
  Compatibility with older SDKs: Fine, they always provide it.
  Compatibility with older hooks: Currently, no embedders call hooks without
  support for code assets. Once they do (data assets on web), existing hooks
  will break. Mitigation: Update existing hooks to check for `buildAssetTypes`
  and/or change `CBuilder` to be a no-op if `buildAssetTypes` does not contain
  code assets.
- `BuildConfig.outputDirectoryShared` for sharing between hook invocations.
  Compatibility with older SDKs: Create a sibling dir next to the output
  directory. This does not facilitate caching, but should not break the hook.
  Compatibility with older hooks: These will not read this field.
- `BuildConfig.buildMode` is removed. Instead it is specified by hook writers
  in the `CBuilder` constructors.
  Compatibility with older SDKs: The new hooks will not read the field.
  Compatibility with older hooks: The field is now always passed as 'release'
  until we can bump the SDK constraint in `package:native_assets_cli`.

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
