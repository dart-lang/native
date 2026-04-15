#!/bin/bash
set -e
cd $(dirname $0)
echo "--- Running flutter clean ---"
flutter clean
echo "--- Running flutter pub get ---"
flutter pub get
echo "--- Running JNIgen ---"
dart run tool/generate_bindings.dart

echo "--- Checking generated file ---"
if [ -f lib/maven_libs_bindings.dart ]; then
    echo "SUCCESS: Generated bindings found."
    # Check if Gson is in the generated file
    if grep -q "Gson" lib/maven_libs_bindings.dart; then
        echo "SUCCESS: Gson bindings found."
    else
        echo "FAILURE: Gson bindings NOT found."
        exit 1
    fi
    # Check if OkHttpClient is in the generated file
    if grep -q "OkHttpClient" lib/maven_libs_bindings.dart; then
        echo "SUCCESS: OkHttpClient bindings found."
    else
        echo "FAILURE: OkHttpClient bindings NOT found."
        exit 1
    fi
else
    echo "FAILURE: Generated bindings NOT found."
    exit 1
fi
