<template>
  <!--
    Un bloque de la bandeja del coordinador (cap. 35.1). Cada bloque existe
    porque habilita una acción concreta, así que además del número muestra QUÉ
    hacer con él y las filas sobre las que actuar.
  -->
  <section class="bloque" :class="tono">
    <div class="bloque-head">
      <span class="bloque-n">{{ total }}</span>
      <span class="bloque-label">{{ label }}</span>
      <span v-if="accion" class="bloque-accion">{{ accion }}</span>
    </div>
    <div v-if="items.length" class="bloque-lista">
      <div v-for="(it, i) in items.slice(0, limite)" :key="it.id ?? i" class="bloque-fila" @click="$emit('abrir', it)">
        <slot name="fila" :item="it" />
      </div>
    </div>
    <div v-else class="bloque-vacio">{{ vacio }}</div>
  </section>
</template>

<script setup>
defineProps({
  total: { type: [Number, String], default: 0 },
  label: { type: String, required: true },
  accion: { type: String, default: "" },
  // 'espera' = requiere tu decisión · 'urgente' · 'ok' · '' = informativo
  tono: { type: String, default: "" },
  items: { type: Array, default: () => [] },
  limite: { type: Number, default: 6 },
  vacio: { type: String, default: "Nada pendiente." },
});
defineEmits(["abrir"]);
</script>
