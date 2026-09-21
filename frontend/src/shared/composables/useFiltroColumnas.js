import { computed, ref } from "vue";

/**
 * Filtrado por columna, en el navegador, sobre las filas ya cargadas.
 *
 * Deliberadamente NO consulta al servidor: los filtros de columna afinan lo que
 * se está viendo. Los que buscan en toda la cartera son los de la barra del
 * panel, y mezclar ambos daría la falsa impresión de estar filtrando el total
 * cuando sólo se filtra una página.
 */
export function useFiltroColumnas(filas, columnas) {
  const filtros = ref({});

  const normalizar = (v) =>
    String(v ?? "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "");

  const filtradas = computed(() => {
    const activos = Object.entries(filtros.value).filter(([, v]) => v !== "" && v != null);
    if (!activos.length) return filas.value;

    return filas.value.filter((fila) =>
      activos.every(([clave, valor]) => {
        const col = columnas.find((c) => c.key === clave);
        // `valorFiltro` existe para columnas cuyo texto visible no es el campo
        // crudo: estado + estado administrativo, responsables en dos líneas…
        const bruto = col?.valorFiltro ? col.valorFiltro(fila) : fila[clave];

        if (col?.filtro === "numero") {
          const n = Number(bruto);
          return Number.isFinite(n) && n >= Number(valor);
        }
        if (col?.filtro === "select") return String(bruto ?? "") === String(valor);
        return normalizar(bruto).includes(normalizar(valor));
      }),
    );
  });

  const hayFiltros = computed(() =>
    Object.values(filtros.value).some((v) => v !== "" && v != null),
  );

  return { filtros, filtradas, hayFiltros };
}
