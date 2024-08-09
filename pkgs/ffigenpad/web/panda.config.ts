import { defineConfig } from "@pandacss/dev";
import { createPreset } from "@park-ui/panda-preset";

export default defineConfig({
  preflight: true,
  presets: [
    "@pandacss/preset-base",
    createPreset({
      accentColor: "neutral",
      grayColor: "neutral",
      borderRadius: "sm",
    }),
  ],
  include: ["./src/**/*.{js,jsx,ts,tsx,vue}"],
  jsxFramework: "solid",
  outdir: "styled-system",
  theme: {
    extend: {
      slotRecipes: {
        treeView: {
          base: {
            tree: { gap: "0.5" },
          },
        },
        tabs: {
          base: {
            root: { height: "full", flexGrow: 1, gap: "1" },
            content: { height: "full", flexGrow: 1, overflow: "auto" },
          },
          compoundVariants: [
            {
              size: "md",
              variant: "enclosed",
              css: { content: { p: "unset" } },
            },
          ],
        },
      },
    },
  },
});
