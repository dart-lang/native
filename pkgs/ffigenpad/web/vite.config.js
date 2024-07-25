import { defineConfig } from 'vite'
import solid from 'vite-plugin-solid'

export default defineConfig({
  plugins: [solid()],
  server: {
    fs: {
      // Allow serving files from one level up to the project root
      allow: [".."],
    },
  },
})
