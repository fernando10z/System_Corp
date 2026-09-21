<template>
  <div class="tabs" role="tablist">
    <button
      v-for="t in tabs"
      :key="t.key"
      class="tab"
      :class="{ activo: t.key === activo }"
      role="tab"
      :aria-selected="t.key === activo"
      @click="$emit('cambiar', t.key)"
    >
      <component :is="t.icono" v-if="t.icono" :size="14" />
      {{ t.label }}
      <span v-if="t.n !== undefined && t.n !== null" class="tab-n">{{ t.n }}</span>
    </button>
  </div>
</template>

<script setup>
defineProps({
  tabs: { type: Array, required: true },
  activo: { type: String, required: true },
});
defineEmits(["cambiar"]);
</script>
