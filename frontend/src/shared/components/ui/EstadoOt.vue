<template>
  <!--
    El documento (cap. 25.1) trata el estado operativo y el administrativo como
    DIMENSIONES SEPARADAS: una OT puede estar cerrada con la OC pendiente. La
    marca lo refleja en dos líneas en vez de mezclarlas en una sola cadena.

    La línea administrativa sólo aparece cuando de verdad queda algo pendiente:
    repetir "administración completa" en cada fila sería ruido.
  -->
  <span class="estado">
    <span class="estado-op" :class="'e-' + estado">{{ etiqueta(estado) }}</span>
    <span v-if="mostrarAdmin" class="estado-admin">{{ etiqueta(admin) }}</span>
  </span>
</template>

<script setup>
import { computed } from "vue";
import { etiqueta } from "../../utils/formato.js";

const props = defineProps({
  estado: { type: String, required: true },
  admin: { type: String, default: "" },
});

const mostrarAdmin = computed(
  () => props.admin && !["administracion_completa", "sin_solped", "liberacion_total"].includes(props.admin),
);
</script>
