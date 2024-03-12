// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library that contains the argument and file formats for implementing a
/// native assets CLI, e.g. a `build.dart` script.
library native_assets_cli;

export 'src/api/architecture.dart' show Architecture;
export 'src/api/asset.dart'
    show
        Asset,
        BundledDylib,
        LookupInExecutable,
        LookupInProcess,
        NativeCodeAsset,
        SystemDylib;
export 'src/api/build.dart';
export 'src/api/build_config.dart' show BuildConfig, CCompilerConfig;
export 'src/api/build_mode.dart' show BuildMode;
export 'src/api/build_output.dart' show BuildOutput;
export 'src/api/ios_sdk.dart' show IOSSdk;
export 'src/api/link_mode.dart' show LinkMode;
export 'src/api/link_mode_preference.dart' show LinkModePreference;
export 'src/api/os.dart' show OS;
