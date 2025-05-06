# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  channel = "stable-24.11";
  # Use https://search.nixos.org/packages to find packages.
  packages = [
    # pkgs.android-tools # Not needed. The Flutter environment already has ~/.androidsdkroot/
    pkgs.clang
    pkgs.gcc
    pkgs.jdk17
    pkgs.llvm
    pkgs.llvmPackages.bintools
    # pkgs.pkgsCross.aarch64-android-prebuilt.stdenv.cc # Takes forever to build
    # pkgs.pkgsCross.aarch64-multiplatform.gcc # Takes forever to build
  ];
  env = { };
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id".
    extensions = [
      "Dart-Code.dart-code"
      "mhutchie.git-graph"
      "rangav.vscode-thunder-client"
    ];
    workspace = {
      onCreate = {
        dart-install = "dart pub get";
      };
    };
  };
}
