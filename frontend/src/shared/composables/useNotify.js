import Swal from "sweetalert2";

/**
 * El ÚNICO canal de diálogos de la aplicación.
 *
 * Prohibido usar window.alert/confirm/prompt nativos o banners ad-hoc en los
 * componentes: rompen la consistencia visual y no respetan el modo oscuro.
 *
 * Lo que SÍ vive aquí: confirmar, pedir un motivo, elegir entre opciones,
 * avisar. Lo que NO: formularios de varios campos — esos son modales propios
 * (shared/components/ui/Modal.vue), porque un formulario incrustado como HTML
 * en un diálogo no valida bien, no recuerda lo escrito y no se puede probar.
 *
 * Los textos siguen la regla de escritura del producto: se dice qué pasó y qué
 * hacer, en voz activa, sin disculpas ni vaguedades.
 */
const base = {
  buttonsStyling: false,
  reverseButtons: true,
  customClass: {
    popup: "swal-mip",
    confirmButton: "btn primary",
    cancelButton: "btn",
    denyButton: "btn peligro",
    input: "input",
    validationMessage: "swal-mip-error",
  },
  showClass: { popup: "swal-mip-anim-in" },
  hideClass: { popup: "swal-mip-anim-out" },
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
      customClass: { ...base.customClass, confirmButton: peligro ? "btn solido-peligro" : "btn primary" },
    });
    return r.isConfirmed;
  },

  /** Devuelve el texto, o null si se canceló. Valida antes de cerrar. */
  async pedirTexto(
    titulo,
    { texto = "", placeholder = "", confirmar = "Guardar", minimo = 0, area = true, valorInicial = "" } = {},
  ) {
    const r = await Swal.fire({
      ...base,
      title: titulo,
      text: texto,
      input: area ? "textarea" : "text",
      inputValue: valorInicial,
      inputPlaceholder: placeholder,
      showCancelButton: true,
      confirmButtonText: confirmar,
      cancelButtonText: "Cancelar",
      customClass: { ...base.customClass, input: area ? "textarea" : "input" },
      inputValidator: (v) => {
        const s = (v ?? "").trim();
        if (!s) return "Escriba el motivo para continuar";
        if (minimo && s.length < minimo) return `Necesita al menos ${minimo} caracteres`;
        return undefined;
      },
    });
    return r.isConfirmed ? String(r.value).trim() : null;
  },

  /**
   * Para tres o cuatro opciones, radios: se ven todas a la vez y se elige de un
   * clic. Un desplegable esconde las alternativas justo cuando hay que
   * compararlas.
   */
  async elegir(titulo, opciones, { confirmar = "Continuar", texto = "", tipo = "auto" } = {}) {
    const n = Object.keys(opciones).length;
    const usarRadio = tipo === "radio" || (tipo === "auto" && n <= 5);
    const r = await Swal.fire({
      ...base,
      title: titulo,
      text: texto,
      input: usarRadio ? "radio" : "select",
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
      customClass: { ...base.customClass, popup: "swal-mip swal-mip--toast" },
    }),
};

/** Traduce un error del cliente al diálogo adecuado. */
export function mostrarError(e, titulo = "No se pudo completar la acción") {
  return notify.error(titulo, e?.message ?? "");
}
