import { BadRequestException, Injectable } from "@nestjs/common";
import { createHash } from "node:crypto";
import { AdjuntosRepository, type RegistrarAdjuntoArgs } from "./adjuntos.repository";
import { MinioService } from "../../infrastructure/storage/minio.service";
import type { JwtPayload } from "../../common/types/jwt-payload.type";
import type { SpContext } from "../../common/types/sp-result.type";

/**
 * Deducción del tipo funcional a partir del MIME, según los formatos que el
 * cap. 28.3 declara admitidos. Cualquier otro entra como 'otro' y lo filtra la
 * política del tenant.
 */
const TIPOS: Array<[RegExp, string]> = [
  [/^application\/pdf$/, "pdf"],
  [/^image\/(jpeg|jpg|png|webp)$/, "imagen"],
  [/^video\/(mp4|quicktime|webm)$/, "video"],
  [
    /^(application\/(msword|vnd\.openxmlformats-officedocument\.\w+|vnd\.ms-excel)|text\/plain)$/,
    "documento",
  ],
];

@Injectable()
export class AdjuntosService {
  constructor(
    private readonly repo: AdjuntosRepository,
    private readonly storage: MinioService,
  ) {}

  private ctx(u: JwtPayload): SpContext {
    return { userId: u.sub, tenantId: u.tenant_id, isSuperAdmin: u.is_super_admin };
  }

  private tipoDe(mime?: string): string {
    if (!mime) return "otro";
    return TIPOS.find(([re]) => re.test(mime))?.[1] ?? "otro";
  }

  /**
   * Sube primero al almacén y registra después.
   *
   * Si el registro falla —por ejemplo porque el SP rechaza el tamaño según la
   * configuración del tenant— se borra el objeto recién subido: mejor un intento
   * fallido limpio que un archivo huérfano sin fila que lo explique.
   */
  async subir(
    u: JwtPayload,
    archivo: { buffer: Buffer; filename: string; mimetype?: string },
    meta: Omit<
      RegistrarAdjuntoArgs,
      "storageKey" | "nombre" | "tipo" | "tamanoBytes" | "mimeType" | "checksum"
    >,
  ) {
    if (!archivo?.buffer?.length) {
      throw new BadRequestException({
        code: "VALIDATION",
        message: "No se recibió ningún archivo",
      });
    }

    const tenantId = u.tenant_id ?? "sin-tenant";
    const clave = this.storage.construirClave(tenantId, meta.otId ?? null, archivo.filename);
    await this.storage.subir(clave, archivo.buffer, archivo.mimetype);

    try {
      return await this.repo.registrar(this.ctx(u), {
        ...meta,
        nombre: archivo.filename,
        storageKey: clave,
        tipo: this.tipoDe(archivo.mimetype),
        mimeType: archivo.mimetype,
        tamanoBytes: archivo.buffer.length,
        checksum: createHash("sha256").update(archivo.buffer).digest("hex").slice(0, 64),
      });
    } catch (e) {
      await this.storage.eliminar(clave).catch(() => undefined);
      throw e;
    }
  }

  listar(u: JwtPayload, entidadTipo?: string, entidadId?: string, otId?: string) {
    return this.repo.listar(this.ctx(u), entidadTipo, entidadId, otId);
  }

  /**
   * URL temporal: el almacén nunca se expone directamente al navegador y la
   * clave del objeto tampoco. La base resuelve el id y comprueba el tenant; si
   * el adjunto no es visible, ni se llega a firmar nada.
   */
  async urlDescarga(u: JwtPayload, adjuntoId: string) {
    const a = (await this.repo.obtener(this.ctx(u), adjuntoId)) as {
      nombre?: string;
      mime?: string;
      storage_key?: string;
    };
    return {
      nombre: a.nombre,
      mime: a.mime,
      url: await this.storage.urlDescarga(String(a.storage_key)),
    };
  }

  retirar(u: JwtPayload, id: string, motivo: string) {
    return this.repo.retirar(this.ctx(u), id, motivo);
  }
}
