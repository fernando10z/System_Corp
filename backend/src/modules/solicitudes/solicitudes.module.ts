import { Module } from "@nestjs/common";
import { SolicitudesController } from "./solicitudes.controller";
import { SolicitudesService } from "./solicitudes.service";
import { SolicitudesRepository } from "./solicitudes.repository";

@Module({
  controllers: [SolicitudesController],
  providers: [SolicitudesService, SolicitudesRepository],
})
export class SolicitudesModule {}
