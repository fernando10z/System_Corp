import { Global, Inject, Module, OnApplicationShutdown } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { Pool } from "pg";
import { PG_POOL } from "./database.constants";
import { SpExecutorService } from "./sp-executor.service";

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: PG_POOL,
      inject: [ConfigService],
      useFactory: (config: ConfigService) =>
        new Pool({
          connectionString: config.get<string>("DATABASE_URL"),
          min: Number(config.get("DATABASE_POOL_MIN") ?? 2),
          max: Number(config.get("DATABASE_POOL_MAX") ?? 10),
          ssl:
            config.get("DATABASE_SSL") === "true" ? { rejectUnauthorized: false } : false,
          // El schema `app` es la única superficie; fijarlo aquí evita depender
          // del search_path por defecto del rol.
          options: "-c search_path=app,public",
        }),
    },
    SpExecutorService,
  ],
  exports: [PG_POOL, SpExecutorService],
})
export class DatabaseModule implements OnApplicationShutdown {
  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  async onApplicationShutdown() {
    await this.pool.end();
  }
}
