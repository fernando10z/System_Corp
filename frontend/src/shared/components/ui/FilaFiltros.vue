<template>
  <!--
    Fila de filtros bajo la cabecera de la tabla: cada columna filtra lo suyo,
    justo encima de los datos que afecta. Es más directo que una barra superior
    donde hay que adivinar a qué columna corresponde cada control.

    Filtra SOBRE LO CARGADO, en el navegador. Los filtros que consultan al
    servidor siguen siendo los de la barra del panel: mezclarlos daría la falsa
    impresión de estar buscando en toda la cartera.
  -->
  <tr class="fila-filtros">
    <th v-for="c in columnas" :key="c.key" :class="c.align === 'right' ? 'num' : ''">
      <select
        v-if="c.filtro === 'select'"
        :value="modelValue[c.key] ?? ''"
        class="ff-control"
        @change="emitir(c.key, $event.target.value)"
      >
        <option value="">{{ c.placeholder ?? "Todos" }}</option>
        <option v-for="o in c.opciones ?? []" :key="o.value" :value="o.value">{{ o.label }}</option>
      </select>

      <input
        v-else-if="c.filtro === 'texto'"
        :value="modelValue[c.key] ?? ''"
        class="ff-control"
        type="search"
        :placeholder="c.placeholder ?? 'Buscar…'"
        @input="emitir(c.key, $event.target.value)"
      />

      <input
        v-else-if="c.filtro === 'numero'"
        :value="modelValue[c.key] ?? ''"
        class="ff-control mono"
        type="number"
        :placeholder="c.placeholder ?? '≥ 0'"
        @input="emitir(c.key, $event.target.value)"
      />

      <button
        v-else-if="c.filtro === 'limpiar'"
        class="ff-limpiar"
        :disabled="!hayFiltros"
        title="Quitar los filtros de columna"
        @click="$emit('update:modelValue', {})"
      >
        <FilterX :size="14" />
      </button>

      <span v-else class="ff-vacio" />
    </th>
  </tr>
</template>

<script setup>
import { computed } from "vue";
import { FilterX } from "lucide-vue-next";

const props = defineProps({
  /** Las MISMAS columnas de la tabla, con `filtro` donde deba haberlo. */
  columnas: { type: Array, required: true },
  modelValue: { type: Object, default: () => ({}) },
});
const emit = defineEmits(["update:modelValue"]);

const hayFiltros = computed(() => Object.values(props.modelValue).some((v) => v !== "" && v != null));

function emitir(clave, valor) {
  const siguiente = { ...props.modelValue };
  if (valor === "" || valor == null) delete siguiente[clave];
  else siguiente[clave] = valor;
  emit("update:modelValue", siguiente);
}
</script>
