<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="abierto" class="modal-back" @mousedown.self="cerrar">
        <div
          :class="['modal', ancho]"
          role="dialog"
          aria-modal="true"
          :aria-label="titulo ?? undefined"
          @mousedown.stop
        >
          <header v-if="titulo || $slots.cabecera" class="m-head">
            <slot name="cabecera">
              <div class="m-titulos">
                <h3>{{ titulo }}</h3>
                <p v-if="subtitulo" class="m-sub">{{ subtitulo }}</p>
              </div>
            </slot>
            <button class="row-action" aria-label="Cerrar" @click="cerrar"><X :size="16" /></button>
          </header>

          <div class="m-body"><slot /></div>

          <footer v-if="$slots.acciones" class="m-foot"><slot name="acciones" /></footer>
        </div>
      </div>
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
  /** "" | "ancho" (640) | "extra" (840) */
  ancho: { type: String, default: "" },
  /** Un formulario a medio llenar no debe perderse por un clic fuera. */
  persistente: { type: Boolean, default: false },
});
const emit = defineEmits(["cerrar"]);

function cerrar() {
  if (!props.persistente) emit("cerrar");
}

function alPulsar(e) {
  if (e.key === "Escape") emit("cerrar");
}

// El scroll del fondo se bloquea mientras el modal está abierto: si no, la
// rueda del ratón mueve la página de detrás y el modal parece despegado.
watch(
  () => props.abierto,
  (v) => {
    if (v) {
      window.addEventListener("keydown", alPulsar);
      document.body.style.overflow = "hidden";
    } else {
      window.removeEventListener("keydown", alPulsar);
      document.body.style.overflow = "";
    }
  },
  { immediate: true },
);

onBeforeUnmount(() => {
  window.removeEventListener("keydown", alPulsar);
  document.body.style.overflow = "";
});
</script>

<style scoped>
.modal-enter-active, .modal-leave-active { transition: opacity 0.16s ease; }
.modal-enter-from, .modal-leave-to { opacity: 0; }
</style>
