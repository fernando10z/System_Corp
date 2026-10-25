import { Injectable, Logger, OnModuleInit } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createReadStream, type ReadStream } from "node:fs";
import { access, constants, mkdir, rename, rm, stat, writeFile } from "node:fs/promises";
import { randomUUID } from "node:crypto";
import { dirname, isAbsolute, resolve, sep } from "node:path";
import { AlmacenArchivos } from "./almacen-archivos.port";
import { firmarEnlace, verificarEnlace, type ContenidoEnlace } from "./url-firmada";

/**
 * Almacén en disco local (STORAGE_DRIVER=fs), para servidores de un solo nodo
 * donde levantar un servicio S3 aparte no compensa.
 *
 * El navegador nunca recibe una ruta del disco: recibe un enlace firmado y
 * temporal hacia GET /archivos, que vuelve a verificar la firma antes de leer.
 */
@Injectable()
export class DiscoService extends AlmacenArchivos implements OnModuleInit {
  private readonly logger = new Logger(DiscoService.name);
  private readonly raiz: string;
  private readonly secreto: string;
  private readonly urlTtl: number;
  private readonly urlBase: string;

  constructor(config: ConfigService) {
    super();
    const raiz = config.get<string>("STORAGE_FS_ROOT") ?? "";
    const secreto = config.get<string>("STORAGE_URL_SECRET") ?? "";
    // Mismo criterio que env.validation: si falta algo, el proceso no levanta.
    if (!isAbsolute(raiz)) {
      throw new Error("STORAGE_FS_ROOT debe ser una ruta absoluta cuando STORAGE_DRIVER=fs");
    }
    if (secreto.length < 32) {
      throw new Error(
        "STORAGE_URL_SECRET debe tener al menos 32 caracteres cuando STORAGE_DRIVER=fs",
      );
    }
    this.raiz = resolve(raiz);
    this.secreto = secreto;
    this.urlTtl = Number(config.get("STORAGE_URL_TTL_MIN") ?? 15) * 60;
    this.urlBase =
      config.get<string>("STORAGE_FS_URL_BASE") ?? `/${config.get("API_PREFIX") ?? "api"}`;
  }

  async onModuleInit() {
    await mkdir(this.raiz, { recursive: true, mode: 0o750 });
    this.logger.log(`Adjuntos en disco: ${this.raiz}`);
  }

  /** La clave nunca puede salir de la raíz, venga de donde venga. */
  private ruta(clave: string): string {
    const ruta = resolve(this.raiz, clave);
    if (!ruta.startsWith(this.raiz + sep)) throw new Error("Clave de almacén fuera de la raíz");
    return ruta;
  }

  /** Se escribe a un temporal y se renombra: nunca queda un archivo a medias con el nombre final. */
  async subir(clave: string, buffer: Buffer): Promise<void> {
    const destino = this.ruta(clave);
    await mkdir(dirname(destino), { recursive: true, mode: 0o750 });
    const temporal = `${destino}.${randomUUID()}.tmp`;
    try {
      await writeFile(temporal, buffer, { mode: 0o640, flag: "wx" });
      await rename(temporal, destino);
    } catch (e) {
      await rm(temporal, { force: true });
      throw e;
    }
  }

  async urlDescarga(clave: string, archivo?: { nombre?: string; mime?: string }): Promise<string> {
    const token = firmarEnlace(this.secreto, {
      k: clave,
      n: archivo?.nombre,
      m: archivo?.mime,
      e: Math.floor(Date.now() / 1000) + this.urlTtl,
    });
    return `${this.urlBase}/archivos?t=${token}`;
  }

  /** Lo usa el controlador de /archivos. null si el enlace no vale o el archivo no está. */
  async abrir(
    token: string,
  ): Promise<{ contenido: ContenidoEnlace; flujo: ReadStream; bytes: number } | null> {
    const contenido = verificarEnlace(this.secreto, token);
    if (!contenido) return null;
    try {
      const ruta = this.ruta(contenido.k);
      const { size } = await stat(ruta);
      return { contenido, flujo: createReadStream(ruta), bytes: size };
    } catch {
      return null;
    }
  }

  async eliminar(clave: string): Promise<void> {
    await rm(this.ruta(clave), { force: true });
  }

  async disponible(): Promise<boolean> {
    try {
      await access(this.raiz, constants.W_OK);
      return true;
    } catch {
      return false;
    }
  }
}
