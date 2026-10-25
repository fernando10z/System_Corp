import { Global, Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { AlmacenArchivos } from "./almacen-archivos.port";
import { ArchivosController } from "./archivos.controller";
import { DiscoService } from "./disco.service";
import { MinioService } from "./minio.service";

/**
 * STORAGE_DRIVER elige el adaptador: `minio` (por defecto, cualquier S3) o `fs`
 * (disco local). Ningún módulo de negocio sabe cuál es.
 */
@Global()
@Module({
  imports: [ConfigModule],
  controllers: [ArchivosController],
  providers: [
    {
      provide: AlmacenArchivos,
      inject: [ConfigService],
      useFactory: (config: ConfigService) =>
        config.get<string>("STORAGE_DRIVER") === "fs"
          ? new DiscoService(config)
          : new MinioService(config),
    },
  ],
  exports: [AlmacenArchivos],
})
export class StorageModule {}
