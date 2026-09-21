<template>
  <!-- Una pantalla vacía es una invitación a actuar, no una disculpa. -->
  <div class="vacio">
    <div v-if="icono" class="vacio-icono"><component :is="icono" :size="26" /></div>
    <div class="vacio-titulo">{{ titulo }}</div>
    <p v-if="texto" class="vacio-texto">{{ texto }}</p>
    <div v-if="$slots.default" class="fila" style="margin-top: 6px; gap: 8px"><slot /></div>
  </div>
</template>

<script setup>
defineProps({
  titulo: { type: String, default: "Nada por aquí todavía" },
  texto: { type: String, default: "" },
  icono: { type: [Object, Function], default: null },
});
</script>
