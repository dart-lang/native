import { Compartment } from "@codemirror/state";
import { oneDark } from "@codemirror/theme-one-dark";
import { EditorView } from "codemirror";
import { createMemo, createRoot, createSignal } from "solid-js";

const editorLightTheme = EditorView.baseTheme({});
const editorDarkTheme = oneDark;

const themeSignal = () => {
  const darkMode = createSignal(
    window.matchMedia("(prefers-color-scheme: dark)").matches,
  );
  const editorTheme = createMemo(() =>
    darkMode[0]() ? editorDarkTheme : editorLightTheme,
  );
  return { darkMode, editorTheme };
};

export const $theme = createRoot(themeSignal);

export const editorThemeConfig = new Compartment();
export const editorThemeTransaction = createMemo(() => ({
  effects: editorThemeConfig.reconfigure([$theme.editorTheme()]),
}));
