<template>
  <div>
    <div class="arbol-nodo" :class="{ actual: nodo.id === actual }" @click="$emit('abrir', nodo)">
      <span class="mono" style="font-weight: 600">{{ nodo.numero_ot }}</span>
      <EstadoOt :estado="nodo.estado" :admin="nodo.estado_administrativo" />
      <span v-if="nodo.es_emergencia" class="tag emergencia">Emergencia</span>
      <span v-if="nodo.condicion === 'pausada'" class="tag pausada">Pausada</span>
      <span class="crecer" />
      <span v-if="bloquea" class="arbol-bloqueante">Bloquea el cierre</span>
      <span v-else-if="nodo.ot_padre_id && !nodo.es_bloqueante" class="tag">No bloqueante</span>
      <span v-if="nodo.independizada" class="tag derivada">Independizada</span>
    </div>

    <div v-if="hijos.length" class="arbol-hijos">
      <ArbolNodo
        v-for="h in hijos"
        :key="h.id"
        :nodo="h"
        :hijos-de="hijosDe"
        :actual="actual"
        @abrir="$emit('abrir', $event)"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";
import EstadoOt from "./EstadoOt.vue";

const props = defineProps({
  nodo: { type: Object, required: true },
  hijosDe: { type: Function, required: true },
  actual: { type: String, default: "" },
});
defineEmits(["abrir"]);

const hijos = computed(() => props.hijosDe(props.nodo.id));

// Bloquea si es derivada, marcada como bloqueante, y sigue viva.
const bloquea = computed(
  () =>
    props.nodo.ot_padre_id &&
    props.nodo.es_bloqueante &&
    !["cerrada", "cancelada"].includes(props.nodo.estado),
);
</script>
