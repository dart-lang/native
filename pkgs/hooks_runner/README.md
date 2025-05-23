[![dart](https://github.com/dart-lang/native/actions/workflows/native.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/native.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/hooks_runner.svg)](https://pub.dev/packages/hooks_runner)
[![package publisher](https://img.shields.io/pub/publisher/hooks_runner.svg)](https://pub.dev/packages/hooks_runner/publisher)

This package contains the shared logic for invoking [native assets CLI]s.

## Audience

This package is not intended for users, rather it is shared logic for Dart
launchers to invoke the native assets CLIs of packages.
Known Dart launchers using this shared logic: [dartdev] and [flutter_tools].

For more information on how to use native assets as a user see 
package [native assets CLI].

[native assets CLI]: https://github.com/dart-lang/native/tree/main/pkgs/hooks
[dartdev]: https://github.com/dart-lang/sdk/tree/main/pkg/dartdev
[flutter_tools]: https://github.com/flutter/flutter/tree/master/packages/flutter_tools
