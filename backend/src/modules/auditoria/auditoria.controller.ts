import { Controller, Get, Query } from "@nestjs/common";
import { AuditoriaService } from "./auditoria.service";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Roles } from "../../common/decorators/roles.decorator";
import type { JwtPayload } from "../../common/types/jwt-payload.type";

/**
 * La auditoría técnica es de CONSULTA RESTRINGIDA (cap. 33). El historial
 * operativo en lenguaje de negocio se sirve desde GET /ot/:id/historial y lo ve
 * cualquiera que pueda ver la OT.
 */
@Controller("auditoria")
export class AuditoriaController {
  constructor(private readonly auditoria: AuditoriaService) {}

  @Roles("administrador")
  @Get()
  async listar(
    @CurrentUser() u: JwtPayload,
    @Query("entidad") entidad?: string,
    @Query("entidadId") entidadId?: string,
    @Query("actorId") actorId?: string,
    @Query("accion") accion?: string,
    @Query("desde") desde?: string,
    @Query("hasta") hasta?: string,
    @Query("page") page?: string,
    @Query("pageSize") pageSize?: string,
  ) {
    const r = await this.auditoria.listar(
      u,
      { entidad, entidadId, actorId, accion, desde, hasta },
      page ? Number(page) : 1,
      pageSize ? Number(pageSize) : 50,
    );
    return { ok: true, data: r?.data ?? [], meta: r?.meta };
  }
}
