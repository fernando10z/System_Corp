<template>
  <!--
    Elegir entre dos o tres caminos, con el detalle de cada uno a la vista. Un
    desplegable escondería justo las alternativas que hay que comparar, y un
    SweetAlert con radios no permite explicar cada opción.
  -->
  <Modal :abierto="abierto" :titulo="titulo" :subtitulo="subtitulo" persistente @cerrar="$emit('cerrar')">
    <div class="col" style="gap: 10px">
      <label
        v-for="o in opciones"
        :key="o.value"
        class="opcion"
        :class="{ elegida: elegido === o.value, peligro: o.peligro }"
      >
        <input v-model="elegido" type="radio" :value="o.value" name="opcion-modal" />
        <span class="opcion-texto">
          <b>{{ o.label }}</b>
          <small v-if="o.detalle">{{ o.detalle }}</small>
        </span>
      </label>

      <Campo
        v-if="pideTexto"
        :label="opcionActual?.labelTexto ?? 'Motivo'"
        :ayuda="opcionActual?.ayudaTexto ?? ''"
        :error="errorTexto"
        requerido
      >
        <textarea v-model.trim="texto" class="textarea" :class="{ error: !!errorTexto }" style="min-height: 84px" />
      </Campo>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </div>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button
        :class="['btn', opcionActual?.peligro ? 'solido-peligro' : 'primary']"
        :disabled="enviando || !valido"
        @click="confirmar"
      >
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Aplicando…" : confirmarTexto }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import { TriangleAlert } from "lucide-vue-next";
import Modal from "./Modal.vue";
import Campo from "./Campo.vue";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  titulo: { type: String, required: true },
  subtitulo: { type: String, default: "" },
  /** [{ value, label, detalle?, peligro?, exigeTexto?, labelTexto?, ayudaTexto?, minimo? }] */
  opciones: { type: Array, required: true },
  confirmarTexto: { type: String, default: "Continuar" },
  alConfirmar: { type: Function, required: true },
});
const emit = defineEmits(["cerrar", "hecho"]);

const elegido = ref("");
const texto = ref("");
const tocado = ref(false);
const enviando = ref(false);
const errorGeneral = ref("");

const opcionActual = computed(() => props.opciones.find((o) => o.value === elegido.value) ?? null);
const pideTexto = computed(() => !!opcionActual.value?.exigeTexto);
const minimo = computed(() => opcionActual.value?.minimo ?? 5);

const errorTexto = computed(() =>
  tocado.value && pideTexto.value && texto.value.length < minimo.value
    ? `Necesita al menos ${minimo.value} caracteres.`
    : "",
);
const valido = computed(
  () => !!elegido.value && (!pideTexto.value || texto.value.length >= minimo.value),
);

watch(
  () => props.abierto,
  (v) => {
    if (!v) return;
    elegido.value = props.opciones[0]?.value ?? "";
    texto.value = "";
    tocado.value = false;
    errorGeneral.value = "";
  },
);

async function confirmar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    await props.alConfirmar({ opcion: elegido.value, texto: texto.value });
    emit("hecho");
  } catch (e) {
    errorGeneral.value = e?.message ?? "No se pudo completar la acción.";
  } finally {
    enviando.value = false;
  }
}
</script>

<style scoped>
.opcion {
  display: flex; align-items: flex-start; gap: 11px;
  padding: 12px 14px; border-radius: var(--radius);
  border: 1px solid var(--line); background: var(--bg-elev);
  cursor: pointer; user-select: none;
  transition: border-color 0.12s, background 0.12s;
}
.opcion:hover { border-color: var(--line-strong); background: var(--bg-soft); }
.opcion.elegida { border-color: var(--emerald); background: var(--emerald-soft); }
.opcion.elegida.peligro { border-color: var(--red); background: var(--red-soft); }
.opcion input { margin-top: 3px; accent-color: var(--emerald); }
.opcion.peligro input { accent-color: var(--red); }
.opcion-texto { min-width: 0; line-height: 1.45; }
.opcion-texto b { display: block; font-size: 13.5px; color: var(--ink); font-weight: 600; }
.opcion-texto small { display: block; font-size: 12.5px; color: var(--ink-3); margin-top: 2px; }
.opcion.elegida .opcion-texto b { color: var(--emerald-ink); }
.opcion.elegida.peligro .opcion-texto b { color: var(--red-ink); }
</style>
