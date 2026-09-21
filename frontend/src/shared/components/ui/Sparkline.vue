<template>
  <svg :width="ancho" :height="alto" :viewBox="`0 0 ${ancho} ${alto}`" aria-hidden="true">
    <!-- Sin datos se dibuja una línea de puntos, no una línea plana: una plana
         mentiría diciendo "constante en cero". -->
    <line
      v-if="vacio"
      :x1="2" :y1="alto - 3" :x2="ancho - 2" :y2="alto - 3"
      stroke="var(--ink-4)" stroke-width="1" stroke-dasharray="2 3" stroke-linecap="round"
    />
    <path v-else :d="ruta" fill="none" :stroke="color" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
  </svg>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
  puntos: { type: Array, default: () => [] },
  color: { type: String, default: "var(--emerald)" },
  ancho: { type: Number, default: 64 },
  alto: { type: Number, default: 22 },
});

const vacio = computed(() => !props.puntos?.length || props.puntos.every((v) => !v));

const ruta = computed(() => {
  const p = props.puntos ?? [];
  if (!p.length) return "";
  const pad = 2;
  const min = Math.min(...p);
  const max = Math.max(...p);
  const rango = max - min || 1;
  const paso = (props.ancho - pad * 2) / Math.max(p.length - 1, 1);
  return p
    .map((v, i) => {
      const x = pad + i * paso;
      const y = props.alto - pad - ((v - min) / rango) * (props.alto - pad * 2);
      return `${i === 0 ? "M" : "L"}${x.toFixed(1)} ${y.toFixed(1)}`;
    })
    .join(" ");
});
</script>
