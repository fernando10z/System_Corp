<template>
  <!--
    El documento (cap. 25.1) trata el estado operativo y el administrativo como
    DIMENSIONES SEPARADAS: una OT puede estar cerrada con la OC pendiente. La
    marca lo refleja en dos líneas en vez de mezclarlas en una sola cadena.
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

// El pendiente administrativo sólo se muestra cuando de verdad hay algo
// pendiente; repetir "administración completa" en cada fila es ruido.
const mostrarAdmin = computed(
  () => props.admin && props.admin !== "administracion_completa" && props.admin !== "sin_solped",
);
</script>
