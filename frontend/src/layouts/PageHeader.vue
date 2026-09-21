<template>
  <header class="page-head">
    <div class="titles">
      <div v-if="eyebrow" class="eyebrow">{{ eyebrow }}</div>
      <h1>{{ title }}</h1>
      <p v-if="subtitle" class="subtitle">{{ subtitle }}</p>
    </div>
    <div v-if="$slots.acciones" class="actions"><slot name="acciones" /></div>
  </header>
</template>

<script setup>
defineProps({
  eyebrow: { type: String, default: "" },
  title: { type: String, required: true },
  subtitle: { type: String, default: "" },
});
</script>
