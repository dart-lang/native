`package:native_assets_builder` and `package:native_assets_cli/native_assets_cli_internal.dart` are used in [`package:dartdev`] and [`package:flutter_tools`].

Dartdev and Flutter Tools are the commandline interfaces for `dart ...` and `flutter ...` commands.

## Downstream builds

Both Dartdev and Flutter Tools are built in open source, and inside g3.

* Dartdev as part of the Dart SDK build on the [Dart CI].
* Dartdev as part of the g3 build (see CBuild comments on CLs on [Gerrit]).
* Flutter Tools as part of the workflows on GitHub.
* Flutter Tools as part of the g3 build (see the "Google testing" workflow on PRs on GitHub).

The versions used in these different places are as follows:

* The Dart SDK uses pinned dependencies in [DEPS], the current hash is in `native_rev`.
* The Flutter build on GitHub ussed published dependencies in [its `pubspec.yaml`].
* The g3 build uses the pinned dependencies that are rolled in from the Dart SDK. **Both for Dartdev _and_ Flutter Tools**.

## Rolling

The above means the following.

1. The DEPS in the Dart SDK can only be rolled forward as much as is still compatible with the published deps currently used in Flutter Tools.
2. Flutter Tools can only be rolled forward as much as is still compatible with with the deps pinned in the Dart SDK.

So, any breaking change must be done in the following way:

1. Introduce a new API.
2. Release a new version to pub (minor version).
3. Roll that version into Dart SDK, and migrate uses in the Dart SDK.
4. Wait for that Dart version to roll into g3.
5. Update the dependencies to Flutter Tools, and migrate uses.
6. Get the Flutter PR reviewed.
7. Wait for the Flutter PR to roll into g3.
8. Only then, remove the old API.
9. Release a new version to pub (major version, old API removed).
10. Roll both in to Dart/Flutter.

The roll status can be seen on internal corp links only:

* Dart roll to g3: https://dart-in-g3-qa-prod.corp.google.com/dg3/Home#/cbuild
* Flutter roll to g3: https://frob.corp.google.com/

[`package:dartdev`]: https://github.com/dart-lang/sdk/tree/main/pkg/dartdev
[`package:flutter_tools`]: https://github.com/flutter/flutter/tree/master/packages/flutter_tools
[Dart CI]: https://ci.chromium.org/p/dart/g/be/console?reload=300
[Gerrit]: https://dart-review.googlesource.com/
[DEPS]: https://github.com/dart-lang/sdk/blob/main/DEPS
[its `pubspec.yaml`]: https://github.com/flutter/flutter/blob/master/packages/flutter_tools/pubspec.yaml
