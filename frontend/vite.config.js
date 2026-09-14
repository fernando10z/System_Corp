import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  server: {
    // 5180 es el puerto de MIP. El 5173 lo usa System_ERP y el 5174 el proyecto
    // veterinario, así que se elige uno claramente separado.
    port: 5180,
    // strictPort es deliberado: sin él, vite se mueve solo al siguiente puerto
    // libre y el portal carga pero falla en la primera llamada, porque el CORS
    // del backend sólo autoriza el puerto configurado. Es preferible que falle
    // al arrancar, de forma visible.
    strictPort: true,
    host: true,
  },
});
