import { registerAs } from "@nestjs/config";
export default registerAs("redis", () => ({
  url: process.env.REDIS_URL ?? "redis://localhost:6383",
  prefix: process.env.REDIS_PREFIX ?? "mip:",
}));
