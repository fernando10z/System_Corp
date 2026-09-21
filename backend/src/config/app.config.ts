import { registerAs } from "@nestjs/config";
export default registerAs("app", () => ({
  env: process.env.NODE_ENV ?? "development",
  port: Number(process.env.PORT ?? 3200),
  apiPrefix: process.env.API_PREFIX ?? "api",
  corsOrigins: (process.env.CORS_ORIGINS ?? "http://localhost:5180")
    .split(",")
    .map((s) => s.trim()),
  bodyLimitBytes: Number(process.env.BODY_LIMIT_BYTES ?? 52428800),
  rateLimitMax: Number(process.env.RATE_LIMIT_MAX ?? 100),
  rateLimitTtlMs: Number(process.env.RATE_LIMIT_TTL_MS ?? 60000),
}));
