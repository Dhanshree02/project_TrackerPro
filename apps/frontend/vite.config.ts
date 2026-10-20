import { defineConfig, loadEnv } from "vite";
import tailwindcss from "@tailwindcss/vite";
import tsConfigPaths from "vite-tsconfig-paths";
import { tanstackStart } from "@tanstack/react-start/plugin/vite";
import viteReact from "@vitejs/plugin-react";
import { cloudflare } from "@cloudflare/vite-plugin";

export default defineConfig(({ command, mode }) => {
  const loadedEnv = loadEnv(mode, process.cwd(), "VITE_");
  const envDefine: Record<string, string> = {};
  for (const [key, value] of Object.entries(loadedEnv)) {
    envDefine[`import.meta.env.${key}`] = JSON.stringify(value);
  }

  return {
    define: envDefine,
    resolve: {
      alias: {
        "@": `${process.cwd()}/src`,
      },
      dedupe: [
        "react",
        "react-dom",
        "react/jsx-runtime",
        "react/jsx-dev-runtime",
        "@tanstack/react-query",
        "@tanstack/query-core",
      ],
    },
    plugins: [
      tailwindcss(),
      tsConfigPaths({ projects: ["./tsconfig.json"] }),
      ...(command === "build"
        ? [cloudflare({ viteEnvironment: { name: "ssr" } })]
        : []),
      tanstackStart({
        importProtection: {
          behavior: "error",
          client: {
            files: ["**/server/**"],
            specifiers: ["server-only"],
          },
        },
      }),
      viteReact(),
    ],
    server: {
      host: true,
      port: 3000,
      strictPort: true,
      allowedHosts: true,
      origin: process.env.VITE_DEV_ORIGIN || undefined,
      hmr: {
        // Docker publishes 3000 as 39107. LAN browsers must use the host port,
        // not the container port, or the page looks unreachable over IP.
        clientPort: Number(process.env.VITE_HMR_CLIENT_PORT || process.env.UAT_CLEAN_FRONTEND_PORT || 39107),
      },
      watch: {
        usePolling: true,
        awaitWriteFinish: {
          stabilityThreshold: 1000,
          pollInterval: 100,
        },
      },
      proxy: {
        "/api": {
          target: process.env.VITE_BACKEND_URL || "http://localhost:5194",
          changeOrigin: true,
        },
      },
    },
  };
});
