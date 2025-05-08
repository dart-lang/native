`package:hooks_runner` is used in [`package:dartdev`] and [`package:flutter_tools`].

Dartdev and Flutter Tools are the commandline interfaces for `dart ...` and `flutter ...` commands.

## Downstream builds

Both Dartdev and Flutter Tools are built in open source, and inside g3.

* Dartdev as part of the Dart SDK build on the [Dart CI].
* Dartdev as part of the g3 build (see CBuild comments on CLs on [Gerrit]).
* Flutter Tools as part of the workflows on GitHub.

The versions used in these different places are as follows:

* The Dart SDK uses pinned dependencies in [DEPS], the current hash is in `native_rev`.
* The Flutter build on GitHub ussed published dependencies in [its `pubspec.yaml`].

## Rolling

The above means the following.

Breaking changes to `hooks`, `code_assets`, `data_assets`,
`hooks_runner`, and `native_toolchain_c` have to be rolled into the
Dart SDK with a CL that runs all the `pkg` bots:
```
Cq-Include-Trybots: luci.dart.try:pkg-win-release-try,pkg-win-release-arm64-try,pkg-mac-release-try,pkg-mac-release-arm64-try,pkg-linux-release-try,pkg-linux-release-arm64-try,pkg-linux-debug-try
```
The CI on this repo runs with path dependencies between these packages
which corresponds to the path dependencies used in the DEPS file in the Dart
SDK.

Breaking changes to `hooks`, `code_assets`, `data_assets`, and
`hooks_runner` have to be rolled into the packages/flutter_tools in the
flutter/flutter repo. This package uses published dependencies. So this
requires:

1. Land a commit that sets the packages to a stable version.
2. Publish the packages on pub.dev.
3. Make a roll to flutter/flutter.

The roll status can be seen on internal corp links only:

* Dart roll to g3: https://dart-in-g3-qa-prod.corp.google.com/dg3/Home#/cbuild

[`package:dartdev`]: https://github.com/dart-lang/sdk/tree/main/pkg/dartdev
[`package:flutter_tools`]: https://github.com/flutter/flutter/tree/master/packages/flutter_tools
[Dart CI]: https://ci.chromium.org/p/dart/g/be/console?reload=300
[Gerrit]: https://dart-review.googlesource.com/
[DEPS]: https://github.com/dart-lang/sdk/blob/main/DEPS
[its `pubspec.yaml`]: https://github.com/flutter/flutter/blob/master/packages/flutter_tools/pubspec.yaml
