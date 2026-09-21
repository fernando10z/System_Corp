<template>
  <button class="btn sm" :disabled="!filas.length || exportando" :title="titulo" @click="exportar">
    <span v-if="exportando" class="spinner" style="border-color: var(--line-strong); border-top-color: var(--ink)" />
    <FileSpreadsheet v-else :size="14" />
    Excel
  </button>
</template>

<script setup>
import { computed, ref } from "vue";
import { FileSpreadsheet } from "lucide-vue-next";
import { exportarExcel } from "../../utils/exportar.js";
import { notify } from "../../composables/useNotify.js";

const props = defineProps({
  nombre: { type: String, required: true },
  columnas: { type: Array, required: true },
  /** Filas ya cargadas en pantalla. */
  filas: { type: Array, default: () => [] },
  /**
   * Opcional: función que devuelve TODAS las filas del filtro actual, más allá
   * de la página visible. Sin ella se exporta lo que se ve, y el título lo dice.
   */
  traerTodo: { type: Function, default: null },
});

const exportando = ref(false);

const titulo = computed(() =>
  props.traerTodo
    ? "Exportar a Excel todo lo que cumple los filtros actuales"
    : "Exportar a Excel las filas visibles",
);

async function exportar() {
  exportando.value = true;
  try {
    const filas = props.traerTodo ? await props.traerTodo() : props.filas;
    const n = exportarExcel(props.nombre, props.columnas, filas);
    notify.toast(`${n} fila(s) exportadas`);
  } catch (e) {
    notify.error("No se pudo exportar", e?.message ?? "");
  } finally {
    exportando.value = false;
  }
}
</script>
