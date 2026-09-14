/**
 * Topología de producción: dos procesos PM2, sin Docker.
 * Delante va nginx con TLS (infra/nginx/sites-available/).
 */
const ROOT = process.env.MIP_ROOT || "/srv/mip/repo/System_Corp";

module.exports = {
  apps: [
    {
      name: "mip-api",
      cwd: `${ROOT}/backend`,
      script: "dist/main.js",
      instances: 1,
      exec_mode: "fork",
      autorestart: true,
      max_memory_restart: "700M",
      env: { NODE_ENV: "production" },
      out_file: "/var/log/mip/api-out.log",
      error_file: "/var/log/mip/api-err.log",
      merge_logs: true,
      time: true,
    },
    {
      name: "mip-web",
      script: "serve",
      env: {
        // SPA: todas las rutas caen en index.html y las resuelve vue-router.
        PM2_SERVE_PATH: `${ROOT}/frontend/dist`,
        PM2_SERVE_PORT: "5180",
        PM2_SERVE_SPA: "true",
        PM2_SERVE_HOMEPAGE: "/index.html",
      },
      out_file: "/var/log/mip/web-out.log",
      error_file: "/var/log/mip/web-err.log",
      merge_logs: true,
      time: true,
    },
  ],
};
