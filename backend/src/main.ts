import { NestFactory } from "@nestjs/core";
import { FastifyAdapter, type NestFastifyApplication } from "@nestjs/platform-fastify";
import { ConfigService } from "@nestjs/config";
import { BadRequestException, ValidationPipe } from "@nestjs/common";
import { Logger as PinoLogger } from "nestjs-pino";
import fastifyCookie from "@fastify/cookie";
import fastifyCors from "@fastify/cors";
import fastifyHelmet from "@fastify/helmet";
import fastifyMultipart from "@fastify/multipart";

import { AppModule } from "./app.module";
import { mensajesValidacionES } from "./common/validation-messages";

async function bootstrap() {
  const bodyLimit = Number(process.env.BODY_LIMIT_BYTES ?? 52428800);

  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({ logger: false, trustProxy: true, bodyLimit }),
    { bufferLogs: true },
  );

  app.useLogger(app.get(PinoLogger));
  const config = app.get(ConfigService);

  // Cada plugin de Fastify aumenta FastifyInstance por su cuenta (cookie añade
  // signCookie, multipart añade multipartErrors...). Al combinarlos, TypeScript
  // ve instancias mutuamente incompatibles aunque en ejecución sean la misma.
  // La conversión se concentra AQUÍ, explicada, en lugar de repartir cuatro
  // `as any` sueltos por el arranque.
  type PluginFastify = Parameters<NestFastifyApplication["register"]>[0];
  const registrar = (plugin: unknown, opciones?: unknown) =>
    app.register(plugin as PluginFastify, opciones as never);

  await registrar(fastifyHelmet, {
    contentSecurityPolicy: false,
    crossOriginResourcePolicy: { policy: "cross-origin" },
  });
  await registrar(fastifyCookie, { secret: config.get<string>("COOKIE_SECRET") });
  await registrar(fastifyMultipart, { limits: { fileSize: bodyLimit } });
  await registrar(fastifyCors, {
    origin: (config.get<string>("CORS_ORIGINS") ?? "http://localhost:5180").split(",").map((s) => s.trim()),
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
      // Los mensajes salen en español, como el resto de la interfaz.
      exceptionFactory: (errores) => {
        const mensajes = mensajesValidacionES(errores);
        return new BadRequestException({
          code: "VALIDATION",
          message: mensajes[0] ?? "Datos inválidos",
          detail: mensajes,
        });
      },
    }),
  );

  app.setGlobalPrefix(config.get<string>("API_PREFIX") ?? "api");
  app.enableShutdownHooks();

  const port = Number(config.get("PORT") ?? 3100);
  await app.listen(port, "0.0.0.0");

  const log = app.get(PinoLogger);
  log.log(`MIP API escuchando en http://0.0.0.0:${port}/${config.get("API_PREFIX") ?? "api"}`);
}

void bootstrap();
