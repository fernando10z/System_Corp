<template>
  <span :class="['avatar-sm', tamano, color]" :title="nombre || undefined">{{ iniciales(nombre) }}</span>
</template>

<script setup>
import { iniciales } from "../../utils/formato.js";

defineProps({
  nombre: { type: String, default: "" },
  /** '' | 'lg' */
  tamano: { type: String, default: "" },
  /** '' (esmeralda) | 'blue' | 'amber' | 'violet' | 'neutral' */
  color: { type: String, default: "" },
});
</script>
