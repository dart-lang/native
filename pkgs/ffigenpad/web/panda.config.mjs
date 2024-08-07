import { defineConfig } from '@pandacss/dev'
import { createPreset } from '@park-ui/panda-preset'

export default defineConfig({
  preflight: true,
  presets: [
    '@pandacss/preset-base',
    createPreset({
      accentColor: 'neutral',
      grayColor: 'neutral',
      borderRadius: 'sm',
    }),
  ],
  include: ['./src/**/*.{js,jsx,ts,tsx,vue}'],
  jsxFramework: 'solid',
  outdir: 'styled-system',
})
