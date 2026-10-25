import { createHmac, timingSafeEqual } from "node:crypto";

/**
 * Enlace temporal firmado para el almacén en disco: el equivalente de una URL
 * prefirmada de S3. El token lleva la clave, el nombre, el MIME y la caducidad,
 * y una firma HMAC-SHA256 que impide cambiar cualquiera de ellos.
 *
 * La autorización ya ocurrió antes de firmar: app.fn_adjunto_obtener comprobó
 * tenant y alcance. El enlace sólo prueba que esa comprobación pasó hace menos
 * de STORAGE_URL_TTL_MIN minutos.
 */
export interface ContenidoEnlace {
  /** storage_key */
  k: string;
  /** nombre original del archivo */
  n?: string;
  /** MIME registrado */
  m?: string;
  /** caducidad, en segundos epoch */
  e: number;
}

const firma = (secreto: string, cuerpo: string) =>
  createHmac("sha256", secreto).update(cuerpo).digest("base64url");

export function firmarEnlace(secreto: string, contenido: ContenidoEnlace): string {
  const cuerpo = Buffer.from(JSON.stringify(contenido)).toString("base64url");
  return `${cuerpo}.${firma(secreto, cuerpo)}`;
}

/** Devuelve el contenido si la firma es válida y no caducó; null en cualquier otro caso. */
export function verificarEnlace(
  secreto: string,
  token: string,
  ahora = Math.floor(Date.now() / 1000),
): ContenidoEnlace | null {
  const [cuerpo, recibida, sobra] = String(token ?? "").split(".");
  if (!cuerpo || !recibida || sobra !== undefined) return null;

  const esperada = Buffer.from(firma(secreto, cuerpo));
  const dada = Buffer.from(recibida);
  if (esperada.length !== dada.length || !timingSafeEqual(esperada, dada)) return null;

  try {
    const c = JSON.parse(Buffer.from(cuerpo, "base64url").toString("utf8")) as ContenidoEnlace;
    if (typeof c.k !== "string" || typeof c.e !== "number" || c.e < ahora) return null;
    return c;
  } catch {
    return null;
  }
}
