<template>
  <!-- Una pantalla vacía es una invitación a actuar, no una disculpa. -->
  <div class="vacio">
    <div class="vacio-titulo">{{ titulo }}</div>
    <p class="vacio-texto">{{ texto }}</p>
    <slot />
  </div>
</template>

<script setup>
defineProps({
  titulo: { type: String, default: "Nada por aquí todavía" },
  texto: { type: String, default: "" },
});
</script>
