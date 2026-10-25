import { randomUUID } from "node:crypto";

/**
 * Puerto del almacén de adjuntos. La base guarda la `storage_key`; los bytes
 * viven detrás de este contrato, y el resto del backend sólo conoce esto.
 *
 * Es una clase abstracta y no una interfaz porque así sirve también de token de
 * inyección: los módulos piden `AlmacenArchivos` y `StorageModule` decide, según
 * STORAGE_DRIVER, qué adaptador lo cumple (MinIO/S3 o disco local).
 *
 * Los LÍMITES de tamaño no se comprueban aquí: los valida el SP
 * app.sp_adjunto_registrar leyendo la configuración del tenant (cap. 28.3).
 */
export abstract class AlmacenArchivos {
  /**
   * La clave se construye por tenant y OT para que el almacén sea navegable y
   * para poder aplicar políticas de retención por cliente sin buscar en la base.
   */
  construirClave(tenantId: string, otId: string | null, nombre: string): string {
    const limpio = nombre.replace(/[^\w.\-]+/g, "_").slice(-120);
    return `${tenantId}/${otId ?? "sin-ot"}/${randomUUID()}-${limpio}`;
  }

  abstract subir(clave: string, buffer: Buffer, mimeType?: string): Promise<void>;

  /**
   * URL temporal de descarga. Nunca se expone el almacén directamente. El nombre
   * y el MIME los usa el adaptador que entrega el archivo él mismo; uno S3 puede
   * ignorarlos.
   */
  abstract urlDescarga(
    clave: string,
    archivo?: { nombre?: string; mime?: string },
  ): Promise<string>;

  abstract eliminar(clave: string): Promise<void>;

  abstract disponible(): Promise<boolean>;
}
