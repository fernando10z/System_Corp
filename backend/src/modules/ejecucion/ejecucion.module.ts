import { Module } from "@nestjs/common";
import { EjecucionController } from "./ejecucion.controller";
import { EjecucionService } from "./ejecucion.service";
import { EjecucionRepository } from "./ejecucion.repository";

@Module({
  controllers: [EjecucionController],
  providers: [EjecucionService, EjecucionRepository],
})
export class EjecucionModule {}
