<template>
  <!--
    Un bloque de la bandeja del coordinador (cap. 35.1). Cada bloque existe
    porque habilita UNA acción concreta, así que además del número muestra qué
    hacer con él y las filas sobre las que actuar. Un número sin acción posible
    es un adorno, y esta pantalla no es un escaparate: es una cola de triaje.
  -->
  <section class="bloque" :class="tono">
    <div class="bloque-head">
      <div class="bloque-cifra">
        <div class="bloque-n">{{ total }}</div>
        <div class="bloque-label">{{ label }}</div>
      </div>
      <span v-if="accion" class="bloque-accion">
        <component :is="icono" v-if="icono" :size="12" />
        {{ accion }}
      </span>
    </div>

    <div v-if="items.length" class="bloque-lista">
      <div
        v-for="(it, i) in items.slice(0, limite)"
        :key="it.id ?? i"
        class="bloque-fila"
        @click="$emit('abrir', it)"
      >
        <slot name="fila" :item="it" />
      </div>
    </div>

    <div v-else class="bloque-vacio">
      <Check v-if="tono === 'ok'" :size="14" />
      {{ vacio }}
    </div>
  </section>
</template>

<script setup>
import { Check } from "lucide-vue-next";

defineProps({
  total: { type: [Number, String], default: 0 },
  label: { type: String, required: true },
  accion: { type: String, default: "" },
  icono: { type: [Object, Function], default: null },
  /** 'espera' = requiere tu decisión · 'urgente' · 'ok' · '' = informativo */
  tono: { type: String, default: "" },
  items: { type: Array, default: () => [] },
  limite: { type: Number, default: 6 },
  vacio: { type: String, default: "Nada pendiente." },
});
defineEmits(["abrir"]);
</script>
