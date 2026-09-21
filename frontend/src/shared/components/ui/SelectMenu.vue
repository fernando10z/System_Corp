<template>
  <!--
    Un <select> nativo no se puede vestir: en cada sistema operativo se dibuja
    distinto y en modo oscuro suele salir blanco. Este lo reemplaza sin perder
    el teclado (flechas, Enter, Esc).
  -->
  <div ref="raiz" :class="['sm', sabor === 'fil' ? 'sm-fil' : 'sm-input', { abierto, deshabilitado }]">
    <button
      type="button"
      class="sm-trigger"
      :disabled="deshabilitado"
      :aria-expanded="abierto"
      aria-haspopup="listbox"
      @click="alternar"
      @keydown.down.prevent="mover(1)"
      @keydown.up.prevent="mover(-1)"
      @keydown.enter.prevent="confirmar"
      @keydown.esc.prevent="cerrar"
    >
      <slot name="icono" />
      <span :class="['sm-label', seleccionada ? '' : 'vacia']">{{ seleccionada?.label ?? placeholder }}</span>
      <ChevronDown :size="14" :class="['sm-chev', abierto ? 'girada' : '']" />
    </button>

    <Transition name="sm-pop">
      <div v-if="abierto" class="sm-menu" role="listbox">
        <button
          v-for="(o, i) in opciones"
          :key="String(o.value)"
          type="button"
          role="option"
          :aria-selected="o.value === modelValue"
          :class="['sm-item', i === resaltada ? 'activa' : '', o.value === modelValue ? 'elegida' : '']"
          @click="elegir(o)"
          @mouseenter="resaltada = i"
        >
          <span class="sm-item-label">
            <span v-if="o.dot" class="sm-dot" :style="{ background: o.dot }" />
            {{ o.label }}
            <small v-if="o.hint">{{ o.hint }}</small>
          </span>
          <Check v-if="o.value === modelValue" :size="13" class="sm-check" />
        </button>
        <div v-if="!opciones.length" class="sm-empty">Sin opciones</div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, ref, watch } from "vue";
import { Check, ChevronDown } from "lucide-vue-next";

const props = defineProps({
  modelValue: { type: [String, Number, Boolean, null], default: null },
  opciones: { type: Array, required: true },
  placeholder: { type: String, default: "Seleccionar…" },
  deshabilitado: { type: Boolean, default: false },
  /** "fil" = barra de filtros · "input" = formulario */
  sabor: { type: String, default: "input" },
});
const emit = defineEmits(["update:modelValue", "change"]);

const raiz = ref(null);
const abierto = ref(false);
const resaltada = ref(0);

const seleccionada = computed(() => props.opciones.find((o) => o.value === props.modelValue) ?? null);

function indiceActual() {
  const i = props.opciones.findIndex((o) => o.value === props.modelValue);
  return i >= 0 ? i : 0;
}

function alternar() {
  if (props.deshabilitado) return;
  abierto.value ? cerrar() : abrir();
}
function abrir() {
  abierto.value = true;
  resaltada.value = indiceActual();
  nextTick(() => document.addEventListener("mousedown", alClicFuera));
}
function cerrar() {
  abierto.value = false;
  document.removeEventListener("mousedown", alClicFuera);
}
function alClicFuera(e) {
  if (raiz.value && !raiz.value.contains(e.target)) cerrar();
}

function mover(d) {
  if (!abierto.value) return abrir();
  if (!props.opciones.length) return;
  resaltada.value = (resaltada.value + d + props.opciones.length) % props.opciones.length;
}
function confirmar() {
  if (!abierto.value) return abrir();
  const o = props.opciones[resaltada.value];
  if (o) elegir(o);
}
function elegir(o) {
  emit("update:modelValue", o.value);
  emit("change", o.value);
  cerrar();
}

watch(() => props.modelValue, () => (resaltada.value = indiceActual()));
onBeforeUnmount(() => document.removeEventListener("mousedown", alClicFuera));
</script>

<style scoped>
.sm { position: relative; min-width: 0; }

.sm-trigger {
  display: inline-flex; align-items: center; gap: 8px;
  width: 100%;
  background: var(--bg-elev);
  border: 1px solid var(--line);
  color: var(--ink);
  font-family: inherit; font-size: 13px;
  cursor: pointer;
  transition: border-color 0.12s, box-shadow 0.12s;
}
.sm-fil .sm-trigger { min-width: 168px; height: 34px; padding: 0 11px; border-radius: 8px; }
.sm-input .sm-trigger { padding: 8px 11px; border-radius: 8px; }
.sm-trigger:hover:not(:disabled) { border-color: var(--line-strong); }
.sm.abierto .sm-trigger { border-color: var(--emerald); box-shadow: 0 0 0 3px var(--emerald-soft); }
.sm.deshabilitado .sm-trigger { background: var(--bg-soft); color: var(--ink-4); cursor: not-allowed; }

.sm-label { flex: 1; text-align: left; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.sm-label.vacia { color: var(--ink-4); }
.sm-chev { flex-shrink: 0; color: var(--ink-3); transition: transform 0.18s ease, color 0.12s; }
.sm-chev.girada { transform: rotate(180deg); color: var(--emerald-deep); }
.sm-trigger :slotted(svg) { flex-shrink: 0; color: var(--ink-4); }

.sm-menu {
  position: absolute; top: calc(100% + 6px); left: 0; right: 0;
  min-width: 100%;
  background: var(--bg-elev);
  border: 1px solid var(--line);
  border-radius: 10px;
  box-shadow: var(--shadow-lg);
  padding: 5px; z-index: 70;
  max-height: 288px; overflow-y: auto;
}
.sm-pop-enter-active, .sm-pop-leave-active { transition: opacity 0.14s ease, transform 0.14s ease; }
.sm-pop-enter-from, .sm-pop-leave-to { opacity: 0; transform: translateY(-4px) scale(0.98); }

.sm-item {
  display: flex; align-items: center; justify-content: space-between; gap: 10px;
  width: 100%; padding: 8px 11px;
  border: 0; background: transparent; border-radius: 7px;
  font-family: inherit; font-size: 13px; color: var(--ink);
  text-align: left; cursor: pointer;
}
.sm-item:hover, .sm-item.activa { background: var(--emerald-soft); color: var(--emerald-ink); }
.sm-item.elegida { background: var(--bg-soft); font-weight: 500; }
.sm-item.elegida.activa { background: var(--emerald-soft); }
.sm-item-label { display: inline-flex; align-items: center; gap: 8px; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.sm-item-label small { color: var(--ink-3); font-size: 11px; }
.sm-dot { width: 8px; height: 8px; border-radius: 999px; flex-shrink: 0; }
.sm-check { color: var(--emerald-deep); flex-shrink: 0; }
.sm-empty { padding: 16px 11px; text-align: center; font-size: 12.5px; color: var(--ink-3); }
</style>
