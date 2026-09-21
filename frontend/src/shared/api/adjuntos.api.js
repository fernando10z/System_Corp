import { API_BASE_URL, ACCESS_TOKEN_KEY } from "../config/api.config.js";
import { apiFetch } from "./client.js";

/**
 * Subida de adjuntos. Va aparte del cliente general porque es multipart: el
 * navegador tiene que poner el boundary en el Content-Type, así que NO se puede
 * fijar la cabecera a mano.
 */
export async function subirAdjunto({ archivo, entidadTipo, entidadId, etapa, descripcion }) {
  const cuerpo = new FormData();
  cuerpo.append("entidadTipo", entidadTipo);
  cuerpo.append("entidadId", entidadId);
  cuerpo.append("etapa", etapa);
  if (descripcion) cuerpo.append("descripcion", descripcion);
  cuerpo.append("archivo", archivo, archivo.name);

  const res = await fetch(`${API_BASE_URL}/adjuntos`, {
    method: "POST",
    headers: { Authorization: `Bearer ${localStorage.getItem(ACCESS_TOKEN_KEY)}` },
    body: cuerpo,
  });
  const payload = await res.json().catch(() => null);
  if (!res.ok || payload?.ok === false) {
    throw new Error(payload?.error?.message ?? `No se pudo subir ${archivo.name}`);
  }
  return payload.data;
}

/**
 * Sube varios y devuelve cuántos entraron. Un adjunto que falla NO tumba la
 * operación de negocio: la solicitud ya existe y perderla por una foto de 40 MB
 * sería peor que avisar de la foto.
 */
export async function subirVarios(archivos, contexto) {
  const fallos = [];
  let ok = 0;
  for (const a of archivos) {
    try {
      await subirAdjunto({ ...contexto, archivo: a });
      ok++;
    } catch (e) {
      fallos.push(`${a.name}: ${e.message}`);
    }
  }
  return { ok, fallos };
}

/**
 * URL temporal para abrir un adjunto ya guardado.
 *
 * Se pide por id: la clave del almacén no viaja al navegador y es la base la
 * que comprueba que el archivo sea del cliente y esté dentro del alcance.
 */
export async function urlDeAdjunto(id) {
  const { data } = await apiFetch(`/adjuntos/${id}/descarga`);
  return data;
}

/**
 * Lectura asistida del PDF de una cotización.
 *
 * No guarda nada: devuelve lo que el sistema entendió del documento para que
 * una persona lo confirme. El PDF se archiva recién al guardar la cotización.
 */
export async function leerPdfCotizacion(archivo) {
  const cuerpo = new FormData();
  cuerpo.append("archivo", archivo, archivo.name);

  const res = await fetch(`${API_BASE_URL}/cotizaciones/leer-pdf`, {
    method: "POST",
    headers: { Authorization: `Bearer ${localStorage.getItem(ACCESS_TOKEN_KEY)}` },
    body: cuerpo,
  });
  const payload = await res.json().catch(() => null);
  if (!res.ok || payload?.ok === false) {
    throw new Error(payload?.error?.message ?? "No se pudo leer el PDF.");
  }
  return payload.data;
}
