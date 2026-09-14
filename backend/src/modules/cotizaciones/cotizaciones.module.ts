import { Module } from "@nestjs/common";
import { CotizacionesController } from "./cotizaciones.controller";
import { CotizacionesService } from "./cotizaciones.service";
import { CotizacionesRepository } from "./cotizaciones.repository";

@Module({
  controllers: [CotizacionesController],
  providers: [CotizacionesService, CotizacionesRepository],
})
export class CotizacionesModule {}
