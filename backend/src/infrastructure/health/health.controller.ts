import { Controller, Get, Inject } from "@nestjs/common";
import { Pool } from "pg";
import { Public } from "../../common/decorators/public.decorator";
import { PG_POOL } from "../database/database.constants";
import { RedisService } from "../cache/redis.service";
import { MinioService } from "../storage/minio.service";

@Controller("health")
export class HealthController {
  constructor(
    @Inject(PG_POOL) private readonly pool: Pool,
    private readonly redis: RedisService,
    private readonly storage: MinioService,
  ) {}

  @Public()
  @Get()
  async check() {
    const [bd, redis, almacen] = await Promise.all([
      this.pool
        .query("SELECT 1")
        .then(() => true)
        .catch(() => false),
      this.redis.ping(),
      this.storage.disponible(),
    ]);

    // Sólo la base es crítica: sin ella no hay lógica de negocio. Redis y el
    // almacén degradan funcionalidad concreta, pero la aplicación sigue en pie.
    return {
      ok: bd,
      data: {
        estado: bd ? "operativo" : "degradado",
        servicios: { base_datos: bd, redis, almacenamiento: almacen },
        version: process.env.npm_package_version ?? "1.0.0",
        instante: new Date().toISOString(),
      },
    };
  }
}
