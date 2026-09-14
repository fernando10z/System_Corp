<template>
  <!--
    La jerarquía de OT derivadas (cap. 10, 27). La sangría codifica el nivel real
    de derivación: no es decoración, es la estructura del trabajo.
    Se marca cuál bloquea el cierre del padre, porque es la pregunta que uno se
    hace mirando este árbol.
  -->
  <div class="arbol">
    <ArbolNodo
      v-for="n in raices"
      :key="n.id"
      :nodo="n"
      :hijos-de="hijosDe"
      :actual="actual"
      @abrir="$emit('abrir', $event)"
    />
  </div>
</template>

<script setup>
import { computed } from "vue";
import ArbolNodo from "./ArbolNodo.vue";

const props = defineProps({
  nodos: { type: Array, default: () => [] },
  actual: { type: String, default: "" },
});
defineEmits(["abrir"]);

const raices = computed(() => {
  const ids = new Set(props.nodos.map((n) => n.id));
  // Es raíz quien no tiene padre, o cuyo padre no está en el conjunto recibido.
  return props.nodos.filter((n) => !n.ot_padre_id || !ids.has(n.ot_padre_id));
});

function hijosDe(id) {
  return props.nodos.filter((n) => n.ot_padre_id === id);
}
</script>
