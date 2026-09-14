import { Module } from "@nestjs/common";
import { NotificacionesController } from "./notificaciones.controller";
import { NotificacionesService } from "./notificaciones.service";
import { NotificacionesRepository } from "./notificaciones.repository";

@Module({
  controllers: [NotificacionesController],
  providers: [NotificacionesService, NotificacionesRepository],
  exports: [NotificacionesService],
})
export class NotificacionesModule {}
