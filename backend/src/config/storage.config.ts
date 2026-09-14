import { registerAs } from "@nestjs/config";
export default registerAs("storage", () => ({
  endpoint: process.env.STORAGE_ENDPOINT ?? "localhost",
  port: Number(process.env.STORAGE_PORT ?? 9110),
  useSsl: process.env.STORAGE_USE_SSL === "true",
  accessKey: process.env.STORAGE_ACCESS_KEY ?? "minioadmin",
  secretKey: process.env.STORAGE_SECRET_KEY ?? "minioadmin",
  bucket: process.env.STORAGE_BUCKET ?? "mip-adjuntos",
  region: process.env.STORAGE_REGION ?? "us-east-1",
  urlTtlMin: Number(process.env.STORAGE_URL_TTL_MIN ?? 15),
}));
