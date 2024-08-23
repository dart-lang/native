# FFIgenPad Web Interface

## Setup

Make sure you build *libclang.wasm* and *ffigenpad.wasm* and they are present in `<project_root>/bin`.

```bash
$ pnpm install
```

You can then run the dev server with the following command, any changes you make to the website while dev mode is active will be hot-reloaded to the preview.

```bash
$ pnpm dev
```

## Developing

FFIgenPad's online interface uses the [SolidJS](https://www.solidjs.com/) framework, [codemirror](https://codemirror.net/) for the code editors and [park-ui](https://park-ui.com/) for the UI components.
