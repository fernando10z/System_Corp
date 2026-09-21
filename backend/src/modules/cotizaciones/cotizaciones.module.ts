import { Module } from "@nestjs/common";
import { CotizacionesController } from "./cotizaciones.controller";
import { CotizacionesService } from "./cotizaciones.service";
import { CotizacionesRepository } from "./cotizaciones.repository";
import { LecturaCotizacionService } from "./lectura-cotizacion.service";

@Module({
  controllers: [CotizacionesController],
  providers: [CotizacionesService, CotizacionesRepository, LecturaCotizacionService],
})
export class CotizacionesModule {}
