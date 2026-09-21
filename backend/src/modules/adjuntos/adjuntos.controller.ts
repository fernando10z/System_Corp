import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  Req,
} from "@nestjs/common";
import { AdjuntosService } from "./adjuntos.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import { campoDe, type PeticionMultipart } from "../../common/types/peticion-multipart.type";

@Controller("adjuntos")
export class AdjuntosController {
  constructor(private readonly adjuntos: AdjuntosService) {}

  @Get()
  async listar(
    @CurrentUser() u: JwtPayload,
    @Query("entidadTipo") entidadTipo?: string,
    @Query("entidadId") entidadId?: string,
    @Query("otId") otId?: string,
  ) {
    return { ok: true, data: await this.adjuntos.listar(u, entidadTipo, entidadId, otId) };
  }

  /**
   * Multipart. Los metadatos viajan como campos del formulario junto al archivo,
   * porque un adjunto sin entidad, etapa y autor no debe existir (regla 23.1).
   */
  @Post()
  async subir(@CurrentUser() u: JwtPayload, @Req() req: PeticionMultipart) {
    const parte = await req.file();
    if (!parte) {
      throw new BadRequestException({ code: "VALIDATION", message: "Se esperaba un archivo" });
    }

    const campo = (n: string) => campoDe(parte, n);
    const entidadTipo = campo("entidadTipo");
    const entidadId = campo("entidadId");
    const etapa = campo("etapa");

    if (!entidadTipo || !entidadId || !etapa) {
      throw new BadRequestException({
        code: "VALIDATION",
        message:
          "Un adjunto necesita entidadTipo, entidadId y etapa: no se admiten archivos sin contexto",
      });
    }

    return {
      ok: true,
      data: await this.adjuntos.subir(
        u,
        { buffer: await parte.toBuffer(), filename: parte.filename, mimetype: parte.mimetype },
        {
          entidadTipo,
          entidadId,
          etapa,
          otId: campo("otId") ?? null,
          visibilidad: campo("visibilidad") ?? "canal",
        },
      ),
    };
  }

  /**
   * URL temporal para abrir o descargar un adjunto.
   *
   * Se pide por id, no por clave de almacén: así es la base la que comprueba
   * que el archivo pertenece al cliente que pregunta y que la OT de la que
   * cuelga está dentro de su alcance. La clave nunca llega al navegador.
   */
  @Get(":id/descarga")
  async descarga(@CurrentUser() u: JwtPayload, @Param("id", ParseUUIDPipe) id: string) {
    return { ok: true, data: await this.adjuntos.urlDescarga(u, id) };
  }

  @Post(":id/retirar")
  async retirar(
    @CurrentUser() u: JwtPayload,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() body: { motivo: string },
  ) {
    return { ok: true, data: await this.adjuntos.retirar(u, id, body.motivo) };
  }
}
