import { registerAs } from "@nestjs/config";
export default registerAs("jwt", () => ({
  accessSecret: process.env.JWT_ACCESS_SECRET,
  refreshSecret: process.env.JWT_REFRESH_SECRET,
  accessTtl: process.env.JWT_ACCESS_TTL ?? "15m",
  refreshTtl: process.env.JWT_REFRESH_TTL ?? "7d",
  issuer: process.env.JWT_ISSUER ?? "mip",
  audience: process.env.JWT_AUDIENCE ?? "mip-app",
}));
