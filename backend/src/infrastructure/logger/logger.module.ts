import { Module } from "@nestjs/common";
import { LoggerModule as PinoLoggerModule } from "nestjs-pino";
import { randomUUID } from "node:crypto";

@Module({
  imports: [
    PinoLoggerModule.forRoot({
      pinoHttp: {
        level: process.env.LOG_LEVEL ?? "info",
        genReqId: (req) => (req.headers["x-request-id"] as string) || randomUUID(),
        // El log lleva quién y de qué tenant: sin eso, un incidente en un cliente
        // obliga a cruzar a mano contra la base.
        customProps: (req) => {
          const u = (req as { user?: { sub?: string; tenant_id?: string } }).user;
          return { userId: u?.sub, tenantId: u?.tenant_id };
        },
        redact: {
          paths: [
            "req.headers.authorization",
            "req.headers.cookie",
            "req.body.password",
            "req.body.passwordNueva",
            "req.body.passwordActual",
          ],
          remove: true,
        },
        transport:
          process.env.LOG_PRETTY === "true"
            ? {
                target: "pino-pretty",
                options: { singleLine: true, translateTime: "SYS:HH:MM:ss" },
              }
            : undefined,
      },
    }),
  ],
})
export class LoggerModule {}
