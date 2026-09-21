import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Req,
} from "@nestjs/common";
import { Throttle } from "@nestjs/throttler";
import { CotizacionesService } from "./cotizaciones.service";
import { LecturaCotizacionService } from "./lectura-cotizacion.service";
import type { PeticionMultipart } from "../../common/types/peticion-multipart.type";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { CargarCotizacionDto } from "./dto/cargar-cotizacion.dto";

@Controller()
export class CotizacionesController {
  constructor(
    private readonly cotizaciones: CotizacionesService,
    private readonly lectura: LecturaCotizacionService,
  ) {}

  @Get("ot/:otId/cotizaciones")
  async listar(@CurrentUser() u: JwtPayload, @Param("otId", ParseUUIDPipe) otId: string) {
    return { ok: true, data: await this.cotizaciones.listar(u, otId) };
  }

  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("ot/:otId/cotizaciones")
  async cargar(
    @CurrentUser() u: JwtPayload,
    @Param("otId", ParseUUIDPipe) otId: string,
    @Body() dto: CargarCotizacionDto,
  ) {
    return { ok: true, data: await this.cotizaciones.cargar(u, otId, dto) };
  }

  /**
   * Lee el PDF del proveedor y devuelve lo que entendió. NO guarda nada: es un
   * borrador para que una persona lo confirme o lo corrija antes de cargar la
   * cotización. Se limita el ritmo porque abrir un PDF cuesta CPU.
   */
  @Roles("coordinador", "abastecimiento", "administrador")
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @Post("cotizaciones/leer-pdf")
  async leerPdf(@CurrentUser() u: JwtPayload, @Req() req: PeticionMultipart) {
    const parte = await req.file();
    if (!parte) {
      throw new BadRequestException({ code: "VALIDATION", message: "Se esperaba un archivo" });
    }
    return {
      ok: true,
      data: await this.lectura.leerPdf(u, {
        buffer: await parte.toBuffer(),
        filename: parte.filename,
        mimetype: parte.mimetype,
      }),
    };
  }

  @Roles("coordinador", "abastecimiento", "administrador")
  @Post("cotizaciones/:id/invalidar")
  async invalidar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() body: { motivo: string },
  ) {
    return { ok: true, data: await this.cotizaciones.invalidar(u, id, body.motivo) };
  }
}
