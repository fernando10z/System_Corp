import { BadRequestException, Body, Controller, Get, Param, ParseUUIDPipe, Post, Query, Req } from "@nestjs/common";
import { AdjuntosService } from "./adjuntos.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { AuthenticatedRequest } from "../../common/types/authenticated-request.type";

/**
 * @fastify/multipart aumenta FastifyRequest con `file()`, pero esa ampliación no
 * llega al tipo de Nest. Se declara aquí usando el tipo real del plugin en lugar
 * de inventar una forma propia que podría desalinearse con la librería.
 */
type PeticionMultipart = AuthenticatedRequest & {
  file: () => Promise<
    | {
        filename: string;
        mimetype: string;
        toBuffer: () => Promise<Buffer>;
        fields: Record<string, unknown>;
      }
    | undefined
  >;
};

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

    // Los campos del formulario llegan como objetos { value }; se extrae con
    // cuidado porque un campo ausente es undefined, no un objeto vacío.
    const campo = (n: string): string | undefined => {
      const f = parte.fields?.[n] as { value?: unknown } | undefined;
      return typeof f?.value === "string" ? f.value : undefined;
    };
    const entidadTipo = campo("entidadTipo");
    const entidadId = campo("entidadId");
    const etapa = campo("etapa");

    if (!entidadTipo || !entidadId || !etapa) {
      throw new BadRequestException({
        code: "VALIDATION",
        message: "Un adjunto necesita entidadTipo, entidadId y etapa: no se admiten archivos sin contexto",
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

  @Get("descarga")
  async descarga(@Query("storageKey") storageKey: string) {
    if (!storageKey) {
      throw new BadRequestException({ code: "VALIDATION", message: "Falta storageKey" });
    }
    return { ok: true, data: { url: await this.adjuntos.urlDescarga(storageKey) } };
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
