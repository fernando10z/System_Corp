<template>
  <div v-if="total > 0" class="pgn">
    <div class="pgn-info">
      Mostrando <strong>{{ desde }}</strong>–<strong>{{ hasta }}</strong> de <strong>{{ total }}</strong>
    </div>

    <nav v-if="totalPaginas > 1" class="pgn-controls" aria-label="Paginación">
      <button class="pgn-btn" :disabled="pagina <= 1" title="Anterior" @click="ir(pagina - 1)">
        <ChevronLeft :size="14" />
      </button>

      <template v-for="(p, i) in paginas" :key="i">
        <span v-if="p === '…'" class="pgn-dots">…</span>
        <button v-else :class="['pgn-btn', p === pagina ? 'pgn-active' : '']" @click="ir(p)">{{ p }}</button>
      </template>

      <button class="pgn-btn" :disabled="pagina >= totalPaginas" title="Siguiente" @click="ir(pagina + 1)">
        <ChevronRight :size="14" />
      </button>
    </nav>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { ChevronLeft, ChevronRight } from "lucide-vue-next";

/**
 * Acepta el `meta` que devuelve la API ({page, page_size, total, pages}) para
 * que ninguna pantalla tenga que desempaquetarlo a mano.
 */
const props = defineProps({ meta: { type: Object, default: null } });
const emit = defineEmits(["ir"]);

const pagina = computed(() => props.meta?.page ?? 1);
const tam = computed(() => props.meta?.page_size ?? 25);
const total = computed(() => props.meta?.total ?? 0);
const totalPaginas = computed(() => props.meta?.pages ?? Math.max(1, Math.ceil(total.value / tam.value)));

const desde = computed(() => (total.value === 0 ? 0 : (pagina.value - 1) * tam.value + 1));
const hasta = computed(() => Math.min(pagina.value * tam.value, total.value));

/** [1, '…', 4, 5, 6, '…', 12] — nunca más de nueve casillas. */
const paginas = computed(() => {
  const tp = totalPaginas.value;
  const salida = [];
  if (tp <= 9) {
    for (let i = 1; i <= tp; i++) salida.push(i);
    return salida;
  }
  const izq = Math.max(pagina.value - 1, 2);
  const der = Math.min(pagina.value + 1, tp - 1);
  salida.push(1);
  if (izq > 2) salida.push("…");
  for (let i = izq; i <= der; i++) salida.push(i);
  if (der < tp - 1) salida.push("…");
  salida.push(tp);
  return salida;
});

function ir(p) {
  if (p < 1 || p > totalPaginas.value || p === pagina.value) return;
  emit("ir", p);
}
</script>
