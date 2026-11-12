# Spelling Checker

A tool and library for spell-checking documentation comments and markdown files in the `dart-lang/native` repository.

## Features

- Extracts comments (`///`, `//`, `/* ... */`) from Dart source files using `package:analyzer`.
- Extracts natural text from `.md` files.
- Automatically ignores code blocks, inline backticks, doc symbol references (`[ClassName]`), and URLs.
- Compares text against base dictionaries and a repository allowlist (`tool/spelling_allowlist.txt`).
- Exits with a non-zero code on CI when spelling issues are detected.
