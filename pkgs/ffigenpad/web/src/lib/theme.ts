import { Compartment } from "@codemirror/state";
import { oneDark } from "@codemirror/theme-one-dark";
import { EditorView } from "codemirror";
import { createMemo, createRoot, createSignal } from "solid-js";

const editorLightTheme = EditorView.baseTheme({});
const editorDarkTheme = oneDark;

export const editorThemeConfig = new Compartment();

const themeSignal = () => {
  const darkMode = createSignal(
    window.matchMedia("(prefers-color-scheme: dark)").matches,
  );
  const editorTheme = createMemo(() =>
    darkMode[0]() ? editorDarkTheme : editorLightTheme,
  );

  const editorThemeTransaction = createMemo(() => ({
    effects: editorThemeConfig.reconfigure([editorTheme()]),
  }));

  return { darkMode, editorTheme, editorThemeTransaction };
};

export const $theme = createRoot(themeSignal);
