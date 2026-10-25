import { Injectable, Logger, OnModuleInit } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Client } from "minio";
import { AlmacenArchivos } from "./almacen-archivos.port";

/**
 * Adaptador MinIO / S3 del almacén de adjuntos (STORAGE_DRIVER=minio, el valor
 * por defecto). El contrato y las reglas comunes están en AlmacenArchivos.
 */
@Injectable()
export class MinioService extends AlmacenArchivos implements OnModuleInit {
  private readonly logger = new Logger(MinioService.name);
  private readonly client: Client;
  private readonly bucket: string;
  private readonly urlTtl: number;

  constructor(config: ConfigService) {
    super();
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
