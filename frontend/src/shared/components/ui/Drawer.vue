<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="abierto" class="drawer-back" @click="$emit('cerrar')" />
    </Transition>
    <Transition name="slide">
      <aside v-if="abierto" class="drawer" :style="{ width: ancho + 'px' }" role="dialog" aria-modal="true">
        <header class="d-head">
          <slot name="icono" />
          <div class="who">
            <h2 v-if="titulo">{{ titulo }}</h2>
            <div v-if="subtitulo" class="meta">{{ subtitulo }}</div>
          </div>
          <button class="row-action" aria-label="Cerrar" @click="$emit('cerrar')"><X :size="16" /></button>
        </header>
        <div class="d-body"><slot /></div>
        <footer v-if="$slots.acciones" class="d-foot"><slot name="acciones" /></footer>
      </aside>
    </Transition>
  </Teleport>
</template>

<script setup>
import { onBeforeUnmount, watch } from "vue";
import { X } from "lucide-vue-next";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  titulo: { type: String, default: "" },
  subtitulo: { type: String, default: "" },
  ancho: { type: Number, default: 480 },
});
const emit = defineEmits(["cerrar"]);

function alPulsar(e) {
  if (e.key === "Escape") emit("cerrar");
}

watch(
  () => props.abierto,
  (v) => {
    if (v) window.addEventListener("keydown", alPulsar);
    else window.removeEventListener("keydown", alPulsar);
  },
  { immediate: true },
);
onBeforeUnmount(() => window.removeEventListener("keydown", alPulsar));
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.16s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
.slide-enter-active, .slide-leave-active { transition: transform 0.2s ease, opacity 0.2s ease; }
.slide-enter-from, .slide-leave-to { transform: translateX(24px); opacity: 0; }
</style>
