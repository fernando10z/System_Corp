import Swal from "sweetalert2";

/**
 * El ÚNICO canal de diálogos de la aplicación.
 *
 * Prohibido usar window.alert/confirm/prompt nativos o banners ad-hoc en los
 * componentes: rompen la consistencia visual y no respetan el modo oscuro.
 *
 * Los textos siguen la regla de escritura del producto: se dice qué pasó y qué
 * hacer, en voz activa, sin disculpas ni vaguedades.
 */
const base = {
  buttonsStyling: false,
  customClass: {
    popup: "swal-mip",
    confirmButton: "btn primary",
    cancelButton: "btn",
    denyButton: "btn peligro",
    input: "input",
    validationMessage: "swal-mip-error",
  },
  reverseButtons: true,
};

export const notify = {
  exito: (titulo, texto = "") =>
    Swal.fire({ ...base, icon: "success", title: titulo, text: texto, timer: 2200, showConfirmButton: false }),

  error: (titulo, texto = "") =>
    Swal.fire({ ...base, icon: "error", title: titulo, text: texto, confirmButtonText: "Entendido" }),

  aviso: (titulo, texto = "") =>
    Swal.fire({ ...base, icon: "warning", title: titulo, text: texto, confirmButtonText: "Entendido" }),

  info: (titulo, texto = "") =>
    Swal.fire({ ...base, icon: "info", title: titulo, text: texto, confirmButtonText: "Entendido" }),

  /** El botón dice exactamente qué va a pasar, nunca "Aceptar". */
  async confirmar(titulo, texto = "", { confirmar = "Continuar", cancelar = "Cancelar", peligro = false } = {}) {
    const r = await Swal.fire({
      ...base,
      icon: peligro ? "warning" : "question",
      title: titulo,
      text: texto,
      showCancelButton: true,
      confirmButtonText: confirmar,
      cancelButtonText: cancelar,
      customClass: { ...base.customClass, confirmButton: peligro ? "btn peligro" : "btn primary" },
    });
    return r.isConfirmed;
  },

  /** Devuelve el texto, o null si se canceló. Valida antes de cerrar. */
  async pedirTexto(titulo, { texto = "", placeholder = "", confirmar = "Guardar", minimo = 0, area = true } = {}) {
    const r = await Swal.fire({
      ...base,
      title: titulo,
      text: texto,
      input: area ? "textarea" : "text",
      inputPlaceholder: placeholder,
      showCancelButton: true,
      confirmButtonText: confirmar,
      cancelButtonText: "Cancelar",
      inputValidator: (v) => {
        const s = (v ?? "").trim();
        if (!s) return "Escriba el motivo para continuar";
        if (minimo && s.length < minimo) return `Necesita al menos ${minimo} caracteres`;
        return undefined;
      },
    });
    return r.isConfirmed ? String(r.value).trim() : null;
  },

  async elegir(titulo, opciones, { confirmar = "Continuar", texto = "" } = {}) {
    const r = await Swal.fire({
      ...base,
      title: titulo,
      text: texto,
      input: "select",
      inputOptions: opciones,
      showCancelButton: true,
      confirmButtonText: confirmar,
      cancelButtonText: "Cancelar",
      inputValidator: (v) => (v ? undefined : "Elija una opción"),
    });
    return r.isConfirmed ? r.value : null;
  },

  toast: (mensaje, icono = "success") =>
    Swal.fire({
      ...base,
      toast: true,
      position: "bottom-end",
      icon: icono,
      title: mensaje,
      showConfirmButton: false,
      timer: 2600,
      timerProgressBar: true,
    }),
};

/** Traduce un error del cliente al diálogo adecuado. */
export function mostrarError(e, titulo = "No se pudo completar la acción") {
  return notify.error(titulo, e?.message ?? "");
}
