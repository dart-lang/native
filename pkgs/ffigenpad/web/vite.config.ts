import { defineConfig } from "vite";
import monacoEditorPlugin from "vite-plugin-monaco-editor";
import solid from "vite-plugin-solid";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [
    monacoEditorPlugin({
      languageWorkers: [],
    }),
    solid(),
    tsconfigPaths(),
  ],
  server: {
    fs: {
      // Allow serving files from one level up to the project root
      allow: [".."],
    },
  },
});
