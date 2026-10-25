import { Controller, Get, Header, NotFoundException, Query, StreamableFile } from "@nestjs/common";
import { Public } from "../../common/decorators/public.decorator";
import { AlmacenArchivos } from "./almacen-archivos.port";
import { DiscoService } from "./disco.service";

/**
 * Sólo estos tipos se muestran en el navegador. Cualquier otro se fuerza a
 * descarga como binario: un archivo subido por un usuario no debe poder
 * renderizarse como HTML en el origen de la aplicación.
 */
const EN_LINEA =
  /^(application\/pdf|image\/(jpeg|png|webp)|video\/(mp4|webm|quicktime)|text\/plain)$/;

/**
 * Entrega de adjuntos cuando el almacén es el disco (STORAGE_DRIVER=fs).
 *
 * Es @Public porque lo abre window.open, que no manda el Bearer: la
 * autorización ya la hizo GET /adjuntos/:id/descarga al firmar el enlace. Un
 * enlace inválido, caducado o de un archivo inexistente responde lo mismo, 404,
 * sin decir cuál de las tres cosas pasó.
 */
@Controller("archivos")
export class ArchivosController {
  constructor(private readonly almacen: AlmacenArchivos) {}

  @Public()
  @Get()
  @Header("Cache-Control", "private, no-store")
  async entregar(@Query("t") token: string): Promise<StreamableFile> {
    const abierto = this.almacen instanceof DiscoService ? await this.almacen.abrir(token) : null;
    if (!abierto) {
      throw new NotFoundException({
        code: "NOT_FOUND",
        message: "El enlace no es válido o ya caducó",
      });
    }

    const { contenido, flujo, bytes } = abierto;
    const enLinea = !!contenido.m && EN_LINEA.test(contenido.m);
    const nombre = contenido.n || "archivo";
    const ascii = nombre.replace(/[^\x20-\x7e]|["\\]/g, "_");

    return new StreamableFile(flujo, {
      type: enLinea ? contenido.m : "application/octet-stream",
      length: bytes,
      disposition: `${enLinea ? "inline" : "attachment"}; filename="${ascii}"; filename*=UTF-8''${encodeURIComponent(nombre)}`,
    });
  }
}
