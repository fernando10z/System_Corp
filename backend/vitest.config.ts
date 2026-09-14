import { defineConfig } from "vitest/config";

// A diferencia del proyecto hermano, aquí esto está configurado de verdad y no
// es un stub: los tests de integración necesitan la BD levantada, por eso el
// timeout generoso y la ejecución en un solo hilo (comparten el esquema).
export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    include: ["test/**/*.{spec,e2e-spec}.ts", "src/**/*.spec.ts"],
    testTimeout: 30_000,
    hookTimeout: 30_000,
    pool: "threads",
    poolOptions: { threads: { singleThread: true } },
    coverage: { provider: "v8", reporter: ["text", "html"], reportsDirectory: "./coverage" },
  },
});
