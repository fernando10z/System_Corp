<template>
  <component
    :is="to ? 'router-link' : 'div'"
    :to="to || undefined"
    :class="['stat', tono, to ? 'clicable' : '']"
  >
    <div class="stat-label">
      <span>{{ label }}</span>
      <span v-if="icono" :class="['icon-tile', color]"><component :is="icono" :size="14" /></span>
    </div>
    <div :class="['stat-val', pequeno ? 'sm' : '']">
      {{ valor }}
      <span v-if="unidad" class="unit">{{ unidad }}</span>
    </div>
    <div v-if="meta || $slots.meta" class="stat-meta">
      <slot name="meta"><span class="txt">{{ meta }}</span></slot>
    </div>
  </component>
</template>

<script setup>
/**
 * Una cifra con su etiqueta y su contexto. El contexto (`meta`) no es opcional
 * por capricho: un número solo, sin con qué compararlo, se lee como más preciso
 * de lo que es.
 */
defineProps({
  label: { type: String, required: true },
  valor: { type: [String, Number], required: true },
  unidad: { type: String, default: "" },
  meta: { type: String, default: "" },
  icono: { type: [Object, Function], default: null },
  /** color de la teja del icono */
  color: { type: String, default: "" },
  /** '' | 'espera' (ámbar) | 'urgente' (rojo) — tiñe la cifra */
  tono: { type: String, default: "" },
  pequeno: { type: Boolean, default: false },
  to: { type: String, default: "" },
});
</script>
