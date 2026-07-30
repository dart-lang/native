#!/usr/bin/env bash
# Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set -euo pipefail

if [ "$#" -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: $0 <file_path>"
  echo "Compares the binding summary of a Dart file against its version on the main branch."
  exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File '$FILE_PATH' does not exist." >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Error: Not in a git repository." >&2
  exit 1
}

SUMMARIZE_SCRIPT="$REPO_ROOT/pkgs/ffigen/tool/summarize_bindings.dart"
if [ ! -f "$SUMMARIZE_SCRIPT" ]; then
  echo "Error: summarize_bindings.dart not found at '$SUMMARIZE_SCRIPT'." >&2
  exit 1
fi

REPO_RELATIVE_PATH="$(git ls-files --full-name "$FILE_PATH" 2>/dev/null)"
if [ -z "$REPO_RELATIVE_PATH" ]; then
  PREFIX="$(git rev-parse --show-prefix)"
  REPO_RELATIVE_PATH="${PREFIX}${FILE_PATH}"
fi

if git rev-parse --verify main >/dev/null 2>&1; then
  MAIN_REF="main"
elif git rev-parse --verify origin/main >/dev/null 2>&1; then
  MAIN_REF="origin/main"
else
  echo "Error: Could not find 'main' or 'origin/main' branch." >&2
  exit 1
fi

if ! git show "$MAIN_REF:$REPO_RELATIVE_PATH" >/dev/null 2>&1; then
  echo "Error: File '$REPO_RELATIVE_PATH' does not exist on '$MAIN_REF'." >&2
  exit 1
fi

PACKAGE_CONFIG="$REPO_ROOT/pkgs/ffigen/.dart_tool/package_config.json"
if [ -f "$PACKAGE_CONFIG" ]; then
  DART_CMD=(dart --packages="$PACKAGE_CONFIG" "$SUMMARIZE_SCRIPT")
else
  DART_CMD=(dart run "$SUMMARIZE_SCRIPT")
fi

if command -v colordiff >/dev/null 2>&1; then
  DIFF_CMD=(colordiff -u --label "main/$REPO_RELATIVE_PATH" --label "current/$REPO_RELATIVE_PATH")
else
  DIFF_CMD=(diff -u --label "main/$REPO_RELATIVE_PATH" --label "current/$REPO_RELATIVE_PATH")
fi

DIFF_OUTPUT=$("${DIFF_CMD[@]}" \
  <("${DART_CMD[@]}" <(git show "$MAIN_REF:$REPO_RELATIVE_PATH")) \
  <("${DART_CMD[@]}" "$FILE_PATH") || true)

if [ -z "$DIFF_OUTPUT" ]; then
  echo "No binding differences found between main and current branch."
else
  printf "%s\n" "$DIFF_OUTPUT"
fi
