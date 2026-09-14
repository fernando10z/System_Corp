import { Module } from "@nestjs/common";
import { ConfiguracionController } from "./configuracion.controller";
import { ConfiguracionService } from "./configuracion.service";
import { ConfiguracionRepository } from "./configuracion.repository";

@Module({
  controllers: [ConfiguracionController],
  providers: [ConfiguracionService, ConfiguracionRepository],
})
export class ConfiguracionModule {}
