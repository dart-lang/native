// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library that contains the argument and file formats for implementing a
/// build hook (`hook/build.dart`).
library native_assets_cli;

export 'src/api/asset.dart'
    show Asset, DataAsset, NativeCodeAsset, OSLibraryNaming;
export 'src/api/build.dart' show build;
export 'src/api/build_config.dart' show BuildConfig, CCompilerConfig;
export 'src/api/build_output.dart' show BuildOutput, LinkOutput;
export 'src/api/builder.dart' show Builder;
export 'src/api/hook_config.dart' show HookConfig;
export 'src/api/link.dart' show link;
export 'src/api/link_config.dart' show LinkConfig;
export 'src/api/linker.dart' show Linker;
export 'src/architecture.dart' show Architecture;
export 'src/build_mode.dart' show BuildMode;
export 'src/ios_sdk.dart' show IOSSdk;
export 'src/link_mode.dart'
    show
        DynamicLoadingBundled,
        DynamicLoadingSystem,
        LinkMode,
        LookupInExecutable,
        LookupInProcess,
        StaticLinking;
export 'src/link_mode_preference.dart' show LinkModePreference;
export 'src/os.dart' show OS;
