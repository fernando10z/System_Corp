import { ref } from "vue";

/**
 * Título de la ficha abierta, para la última miga de la barra superior.
 *
 * No se usa `route.meta` porque el meta vive en el REGISTRO de la ruta, no en
 * la ruta activa: mutarlo no dispara los computed que lo leen, y la miga se
 * quedaba con el número de la OT anterior.
 */
const titulo = ref("");

export function useTitulo() {
  const fijar = (v) => (titulo.value = v ?? "");
  const limpiar = () => (titulo.value = "");
  return { titulo, fijar, limpiar };
}
