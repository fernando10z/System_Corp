import { Injectable, Logger, OnModuleInit } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Client } from "minio";
import { randomUUID } from "node:crypto";

/**
 * Almacén de adjuntos. La base guarda la `storage_key`; los bytes viven aquí.
 *
 * Los LÍMITES de tamaño no se comprueban en este servicio: los valida el SP
 * app.sp_adjunto_registrar leyendo la configuración del tenant, porque el
 * cap. 28.3 exige que sean configurables sin tocar la lógica de OT.
 */
@Injectable()
export class MinioService implements OnModuleInit {
  private readonly logger = new Logger(MinioService.name);
  private readonly client: Client;
  private readonly bucket: string;
  private readonly urlTtl: number;

  constructor(private readonly config: ConfigService) {
    this.bucket = config.get<string>("STORAGE_BUCKET") ?? "mip-adjuntos";
    this.urlTtl = Number(config.get("STORAGE_URL_TTL_MIN") ?? 15) * 60;
    this.client = new Client({
      endPoint: config.get<string>("STORAGE_ENDPOINT") ?? "localhost",
      port: Number(config.get("STORAGE_PORT") ?? 9110),
      useSSL: config.get("STORAGE_USE_SSL") === "true",
      accessKey: config.get<string>("STORAGE_ACCESS_KEY") ?? "minioadmin",
      secretKey: config.get<string>("STORAGE_SECRET_KEY") ?? "minioadmin",
      region: config.get<string>("STORAGE_REGION") ?? "us-east-1",
    });
  }

  async onModuleInit() {
    try {
      if (!(await this.client.bucketExists(this.bucket))) {
        await this.client.makeBucket(this.bucket);
        this.logger.log(`Bucket ${this.bucket} creado`);
      }
    } catch (e) {
      this.logger.warn(
        `No se pudo verificar el bucket ${this.bucket}: ${(e as Error).message}. La carga de adjuntos fallará hasta que el almacén esté disponible.`,
      );
    }
  }

  /**
   * La clave se construye por tenant y OT para que el almacén sea navegable y
   * para poder aplicar políticas de retención por cliente sin buscar en la base.
   */
  construirClave(tenantId: string, otId: string | null, nombre: string): string {
    const limpio = nombre.replace(/[^\w.\-]+/g, "_").slice(-120);
    return `${tenantId}/${otId ?? "sin-ot"}/${randomUUID()}-${limpio}`;
  }

  async subir(clave: string, buffer: Buffer, mimeType?: string): Promise<void> {
    await this.client.putObject(this.bucket, clave, buffer, buffer.length, {
      "Content-Type": mimeType ?? "application/octet-stream",
    });
  }

  /** URL temporal de descarga. Nunca se expone el almacén directamente. */
  async urlDescarga(clave: string): Promise<string> {
    return this.client.presignedGetObject(this.bucket, clave, this.urlTtl);
  }

  async eliminar(clave: string): Promise<void> {
    await this.client.removeObject(this.bucket, clave);
  }

  async disponible(): Promise<boolean> {
    try {
      return await this.client.bucketExists(this.bucket);
    } catch {
      return false;
    }
  }
}
