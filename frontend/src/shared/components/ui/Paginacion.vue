<template>
  <div v-if="meta && meta.pages > 1" class="fila fila-sep" style="padding: 10px 14px; border-top: 1px solid var(--line-soft)">
    <span class="muted" style="font-size: 12px">
      {{ desde }}–{{ hasta }} de {{ meta.total }}
    </span>
    <div class="fila">
      <button class="btn sm" :disabled="meta.page <= 1" @click="$emit('ir', meta.page - 1)">Anterior</button>
      <span class="mono muted" style="padding: 0 6px">{{ meta.page }} / {{ meta.pages }}</span>
      <button class="btn sm" :disabled="meta.page >= meta.pages" @click="$emit('ir', meta.page + 1)">Siguiente</button>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";
const props = defineProps({ meta: { type: Object, default: null } });
defineEmits(["ir"]);

const desde = computed(() => (props.meta.page - 1) * props.meta.page_size + 1);
const hasta = computed(() => Math.min(props.meta.page * props.meta.page_size, props.meta.total));
</script>
