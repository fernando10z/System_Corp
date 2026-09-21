<template>
  <!--
    El diálogo de "escriba el motivo". Antes esto era un SweetAlert con un
    textarea inyectado: se veía distinto del resto de modales —otro ancho, otra
    tipografía, botones centrados— y por eso parecía torcido junto a los modales
    propios. Ahora usa el mismo Modal que todo lo demás.
  -->
  <Modal
    :abierto="abierto"
    :titulo="titulo"
    :subtitulo="subtitulo"
    persistente
    @cerrar="$emit('cerrar')"
  >
    <form :id="idForm" class="col" style="gap: 14px" @submit.prevent="confirmar">
      <Campo :label="label" :ayuda="ayuda" :error="error" requerido>
        <textarea
          ref="campo"
          v-model.trim="texto"
          class="textarea"
          :class="{ error: !!error }"
          :placeholder="placeholder"
          :style="{ minHeight: alto + 'px' }"
        />
      </Campo>

      <div v-if="conPorcentaje" class="form-grid">
        <Campo label="Avance estimado" ayuda="Opcional. De 0 a 100.">
          <input v-model="porcentaje" type="number" min="0" max="100" class="input mono" placeholder="—" />
        </Campo>
      </div>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button :class="['btn', peligro ? 'solido-peligro' : tono]" :form="idForm" type="submit" :disabled="enviando || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Guardando…" : confirmarTexto }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, nextTick, ref, watch } from "vue";
import { TriangleAlert } from "lucide-vue-next";
import Modal from "./Modal.vue";
import Campo from "./Campo.vue";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  titulo: { type: String, required: true },
  subtitulo: { type: String, default: "" },
  label: { type: String, default: "Motivo" },
  ayuda: { type: String, default: "" },
  placeholder: { type: String, default: "" },
  confirmarTexto: { type: String, default: "Guardar" },
  /** Longitud mínima exigida; la misma que valida el stored procedure. */
  minimo: { type: Number, default: 5 },
  alto: { type: Number, default: 96 },
  peligro: { type: Boolean, default: false },
  tono: { type: String, default: "primary" },
  conPorcentaje: { type: Boolean, default: false },
  /** Acción asíncrona; si lanza, el error se muestra dentro del modal. */
  alConfirmar: { type: Function, required: true },
});
const emit = defineEmits(["cerrar", "hecho"]);

const texto = ref("");
const porcentaje = ref("");
const tocado = ref(false);
const enviando = ref(false);
const errorGeneral = ref("");
const campo = ref(null);
const idForm = `mt-${Math.random().toString(36).slice(2, 8)}`;

const valido = computed(() => texto.value.length >= props.minimo);
const error = computed(() =>
  tocado.value && !valido.value ? `Necesita al menos ${props.minimo} caracteres.` : "",
);

watch(
  () => props.abierto,
  async (v) => {
    if (!v) return;
    texto.value = "";
    porcentaje.value = "";
    tocado.value = false;
    errorGeneral.value = "";
    await nextTick();
    campo.value?.focus();
  },
);

async function confirmar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    await props.alConfirmar({
      texto: texto.value,
      porcentaje: porcentaje.value === "" ? undefined : Number(porcentaje.value),
    });
    emit("hecho");
  } catch (e) {
    // El error se queda DENTRO del modal: cerrarlo perdería lo escrito.
    errorGeneral.value = e?.message ?? "No se pudo completar la acción.";
  } finally {
    enviando.value = false;
  }
}
</script>
