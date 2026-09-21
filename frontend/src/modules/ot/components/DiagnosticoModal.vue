<template>
  <!--
    Los cuatro campos técnicos del diagnóstico, juntos y a la vista.

    Antes se pedían uno a uno en cuatro diálogos encadenados: quien escribía el
    alcance ya no podía releer el diagnóstico, y cancelar en el cuarto tiraba
    los tres anteriores. Un diagnóstico es UN documento; se escribe leyéndolo
    entero.
  -->
  <Modal
    :abierto="abierto"
    ancho="ancho"
    persistente
    :titulo="hayVigente ? 'Nueva versión del diagnóstico' : 'Registrar el diagnóstico'"
    :subtitulo="
      hayVigente
        ? 'La versión vigente se conserva íntegra con el motivo del cambio. Nada se sobrescribe.'
        : 'La OT no pasa a cotización hasta que exista un diagnóstico con sus cuatro campos.'
    "
    @cerrar="$emit('cerrar')"
  >
    <form id="form-diagnostico" class="col" style="gap: 16px" @submit.prevent="guardar">
      <Campo
        label="Diagnóstico"
        requerido
        :error="err('diagnostico', 10)"
        ayuda="Qué está pasando, según la inspección."
      >
        <textarea
          v-model.trim="d.diagnostico" class="textarea" :class="{ error: err('diagnostico', 10) }"
          placeholder="Ej. el rodamiento del lado libre presenta juego axial y temperatura de 78 °C en marcha"
        />
      </Campo>

      <Campo
        label="Causa probable"
        requerido
        :error="err('causaProbable', 5)"
        ayuda="Puede evolucionar tras el desmontaje; entonces se registra una versión nueva, no se corrige ésta."
      >
        <textarea
          v-model.trim="d.causaProbable" class="textarea" :class="{ error: err('causaProbable', 5) }"
          style="min-height: 66px"
          placeholder="Ej. desalineación acumulada por asentamiento de la base"
        />
      </Campo>

      <div class="form-grid">
        <Campo label="Alcance" requerido :error="err('alcance', 5)" ayuda="Hasta dónde llega esta intervención.">
          <textarea
            v-model.trim="d.alcance" class="textarea" :class="{ error: err('alcance', 5) }"
            style="min-height: 66px"
            placeholder="Ej. sólo el conjunto motriz; la bancada queda fuera"
          />
        </Campo>

        <Campo
          label="Trabajo a realizar"
          requerido
          :error="err('trabajoARealizar', 5)"
          ayuda="El plan de trabajo, no el trabajo ya ejecutado."
        >
          <textarea
            v-model.trim="d.trabajoARealizar" class="textarea" :class="{ error: err('trabajoARealizar', 5) }"
            style="min-height: 66px"
            placeholder="Ej. desmontar, reemplazar rodamientos, alinear con láser y probar 2 h"
          />
        </Campo>
      </div>

      <Campo
        label="Lecturas de instrumentos"
        ayuda="Opcional. Vibración, temperatura, presión… lo que se midió."
      >
        <input v-model.trim="d.lecturasInstrumentos" class="input" placeholder="Ej. vib. 7,2 mm/s · T 78 °C" />
      </Campo>

      <!-- Reemplazar exige motivo: la versión anterior se conserva con él (cap. 18.1). -->
      <Campo
        v-if="hayVigente"
        label="¿Por qué se reemplaza el diagnóstico vigente?"
        requerido
        :error="err('motivoCambio', 10)"
        ayuda="Quedará sellado en la tarjeta viajera junto a la versión anterior."
      >
        <textarea
          v-model.trim="d.motivoCambio" class="textarea" :class="{ error: err('motivoCambio', 10) }"
          style="min-height: 66px"
          placeholder="Ej. el desmontaje descartó la causa inicial"
        />
      </Campo>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn primary" form="form-diagnostico" type="submit" :disabled="enviando || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Guardando…" : hayVigente ? "Registrar la versión" : "Registrar diagnóstico" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { TriangleAlert } from "lucide-vue-next";
import Modal from "../../../shared/components/ui/Modal.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import { otApi } from "../api/ot.api.js";
import { notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  otId: { type: String, required: true },
  hayVigente: { type: Boolean, default: false },
});
const emit = defineEmits(["cerrar", "guardado"]);

const vacio = () => ({
  diagnostico: "",
  causaProbable: "",
  alcance: "",
  trabajoARealizar: "",
  lecturasInstrumentos: "",
  motivoCambio: "",
});

const d = reactive(vacio());
const enviando = ref(false);
const tocado = ref(false);
const errorGeneral = ref("");

/** Sólo se marca en rojo lo que ya se intentó enviar: regañar antes es hostil. */
function err(campo, minimo) {
  if (!tocado.value) return "";
  const v = d[campo] ?? "";
  if (campo === "motivoCambio" && !props.hayVigente) return "";
  return v.length < minimo ? `Necesita al menos ${minimo} caracteres.` : "";
}

const valido = computed(
  () =>
    d.diagnostico.length >= 10 &&
    d.causaProbable.length >= 5 &&
    d.alcance.length >= 5 &&
    d.trabajoARealizar.length >= 5 &&
    (!props.hayVigente || d.motivoCambio.length >= 10),
);

watch(
  () => props.abierto,
  (v) => {
    if (!v) return;
    Object.assign(d, vacio());
    tocado.value = false;
    errorGeneral.value = "";
  },
);

async function guardar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    const r = await otApi.registrarDiagnostico(props.otId, { ...d });
    await notify.exito("Diagnóstico registrado", `Versión ${r.data.version}`);
    emit("guardado");
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo registrar el diagnóstico.";
  } finally {
    enviando.value = false;
  }
}
</script>
