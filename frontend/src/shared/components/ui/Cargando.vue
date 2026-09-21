<template>
  <!--
    Dos formas de esperar. `filas` dibuja el esqueleto de una tabla, que ocupa
    el sitio que va a ocupar el contenido y evita el salto al llegar los datos.
    Sin `filas`, una barra sobria con su texto.
  -->
  <div v-if="filas" class="sk-tabla" role="status" :aria-label="texto">
    <div v-for="i in filas" :key="i" class="sk-fila">
      <div class="skeleton" :style="{ width: anchos[i % anchos.length], height: '12px' }" />
      <div class="skeleton" style="width: 22%; height: 12px" />
      <div class="skeleton" style="width: 14%; height: 12px" />
    </div>
  </div>

  <div v-else class="cargando" role="status">
    <div class="barra-carga" style="max-width: 220px; margin: 0 auto 14px" />
    {{ texto }}
  </div>
</template>

<script setup>
defineProps({
  texto: { type: String, default: "Cargando…" },
  filas: { type: Number, default: 0 },
});

const anchos = ["38%", "46%", "30%", "42%", "34%"];
</script>

<style scoped>
.sk-tabla { padding: 4px 0; }
.sk-fila {
  display: flex; align-items: center; gap: 16px;
  padding: 14px 18px;
  border-bottom: 1px solid var(--line-soft);
}
.sk-fila:last-child { border-bottom: 0; }
.sk-fila .skeleton:first-child { flex: 1; }
</style>
