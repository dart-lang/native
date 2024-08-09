import { StreamLanguage } from "@codemirror/language";
import { dart } from "@codemirror/legacy-modes/mode/clike";
import { EditorState } from "@codemirror/state";
import { useStore } from "@nanostores/solid";
import { basicSetup, EditorView } from "codemirror";
import { createEffect, onMount } from "solid-js";
import { Box } from "styled-system/jsx";
import { $bindings } from "~/lib/bindings";

export const BindingsViewer = () => {
  const bindings = useStore($bindings);

  let editorRef: HTMLDivElement;
  let editor: EditorView;

  onMount(() => {
    editor = new EditorView({
      doc: bindings(),
      extensions: [
        basicSetup,
        StreamLanguage.define(dart),
        EditorView.updateListener.of((viewUpdate) => {
          if (viewUpdate.docChanged) {
            console.log(viewUpdate.view.state.doc.toString());
          }
        }),
        EditorView.theme({
          "&": {
            height: "100%",
          },
        }),
        EditorState.readOnly.of(true),
      ],
      parent: editorRef!,
    });

    return () => {
      editor.destroy();
    };
  });

  createEffect(() => {
    if (editor) {
      editor.dispatch({
        changes: { from: 0, to: editor.state.doc.length, insert: bindings() },
      });
    }
  });

  return <Box ref={editorRef} />;
};
