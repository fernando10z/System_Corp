<template>
  <div class="cargando">
    <div class="barra-carga" style="max-width: 200px; margin: 0 auto 12px"></div>
    {{ texto }}
  </div>
</template>

<script setup>
defineProps({ texto: { type: String, default: "Cargando…" } });
</script>
