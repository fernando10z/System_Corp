<template>
  <!--
    Reportar una necesidad. Es un modal y no una página porque se reporta DESDE
    donde se está: la bandeja, el listado. Obligar a navegar a otra pantalla y
    volver es fricción sobre quien menos usa el sistema.

    El formulario es deliberadamente corto: el documento (ST-01) prohíbe pedir
    activo, código de equipo, CECOS, diagnóstico, causa, proveedor o costo. Lo
    único que faltaba era la evidencia, que sí está prevista como entrada.
  -->
  <Modal
    :abierto="abierto"
    ancho="ancho"
    persistente
    titulo="Reportar una necesidad"
    subtitulo="Cuente qué observó. No hace falta que sepa qué equipo es, ni qué lo causa, ni cuánto cuesta."
    @cerrar="$emit('cerrar')"
  >
    <form id="form-solicitud" class="col" style="gap: 16px" @submit.prevent="enviar">
      <Campo label="Título" requerido :error="err('titulo')" ayuda="Una frase corta que lo identifique.">
        <input
          ref="primerCampo"
          v-model.trim="d.titulo"
          class="input"
          :class="{ error: err('titulo') }"
          maxlength="180"
          placeholder="Ej. ruido anormal en el compresor 2"
        />
      </Campo>

      <Campo
        label="¿Qué está pasando?"
        requerido
        :error="err('descripcion')"
        ayuda="Desde cuándo, qué se oye o se ve, si afecta la producción. Este texto se conserva tal cual, aunque después el diagnóstico diga otra cosa."
      >
        <textarea
          v-model.trim="d.descripcion"
          class="textarea"
          :class="{ error: err('descripcion') }"
          placeholder="Empezó el lunes. Al arrancar suena un golpeteo metálico y vibra más de lo normal…"
        />
      </Campo>

      <div class="form-grid">
        <Campo label="¿Dónde?" requerido :error="err('lugar')" ayuda="Como usted lo diría, sin código técnico.">
          <input v-model.trim="d.lugar" class="input" :class="{ error: err('lugar') }" placeholder="Ej. sala de compresores, nivel 1" />
        </Campo>

        <Campo label="Área afectada" requerido :error="err('areaId')">
          <SelectMenu v-model="d.areaId" :opciones="opcAreas" placeholder="Elija el área" />
        </Campo>
      </div>

      <div class="form-grid">
        <Campo label="¿Cómo afecta a la operación?">
          <SelectMenu v-model="d.impactoOperativoId" :opciones="opcImpactos" placeholder="Sin indicar" />
        </Campo>

        <Campo label="¿Qué tan urgente le parece?" ayuda="Es su percepción. El coordinador fijará la prioridad técnica.">
          <SelectMenu v-model="d.prioridadPercibida" :opciones="OPC_PRIORIDAD" placeholder="Sin indicar" />
        </Campo>
      </div>

      <!-- El catálogo declara qué ítem exige comentario (normalmente "Otro"). -->
      <Campo v-if="impactoExigeComentario" label="Cuéntenos más sobre el impacto" requerido :error="err('impactoComentario')">
        <input v-model.trim="d.impactoComentario" class="input" placeholder="¿Qué se detiene, y cuánto?" />
      </Campo>

      <Campo label="Evidencias" ayuda="Opcional. Una foto del problema suele ahorrar una visita.">
        <Adjuntos v-model="evidencias" />
      </Campo>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <span class="izq muted" style="font-size: 12px">{{ pie }}</span>
      <button class="btn" :disabled="enviando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn" :disabled="enviando || !minimo" @click="guardarBorrador">Guardar borrador</button>
      <button class="btn primary" form="form-solicitud" type="submit" :disabled="enviando || !completa">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? textoEnviando : "Enviar solicitud" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, nextTick, reactive, ref, watch } from "vue";
import { TriangleAlert } from "lucide-vue-next";
import Modal from "../../../shared/components/ui/Modal.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import Adjuntos from "../../../shared/components/ui/Adjuntos.vue";
import { solicitudesApi } from "../api/solicitudes.api.js";
import { catalogosApi, organizacionApi } from "../../shared/catalogos.api.js";
import { subirVarios } from "../../../shared/api/adjuntos.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({ abierto: { type: Boolean, required: true } });
const emit = defineEmits(["cerrar", "creada"]);

const { puede } = useAuth();
/**
 * Quien decide solicitudes también puede crearlas (Anexo B). Decirle que "el
 * coordinador la revisará" cuando ella ES la coordinadora suena a que el
 * sistema no sabe con quién habla.
 */
const puedeDecidir = puede("solicitudes:decidir");

const OPC_PRIORIDAD = [
  { value: "", label: "Sin indicar" },
  { value: "critica", label: "Crítica", dot: "var(--red)" },
  { value: "alta", label: "Alta", dot: "var(--amber)" },
  { value: "media", label: "Media", dot: "var(--blue)" },
  { value: "baja", label: "Baja", dot: "var(--ink-4)" },
];

const vacio = () => ({
  titulo: "", descripcion: "", lugar: "", areaId: "",
  impactoOperativoId: "", impactoComentario: "", prioridadPercibida: "",
});

const d = reactive(vacio());
const evidencias = ref([]);
const areas = ref([]);
const impactos = ref([]);
const enviando = ref(false);
const tocado = ref(false);
const errorGeneral = ref("");
const textoEnviando = ref("Enviando…");
const primerCampo = ref(null);

const opcAreas = computed(() => areas.value.map((a) => ({ value: a.id, label: a.nombre, hint: a.empresa_ruc })));
const opcImpactos = computed(() => [
  { value: "", label: "Sin indicar" },
  ...impactos.value.map((i) => ({ value: i.id, label: i.nombre })),
]);

const impactoExigeComentario = computed(
  () => impactos.value.find((i) => i.id === d.impactoOperativoId)?.requiere_comentario ?? false,
);

const reglas = {
  titulo: () => d.titulo.length >= 5 || "Al menos 5 caracteres.",
  descripcion: () => d.descripcion.length >= 10 || "Al menos 10 caracteres.",
  lugar: () => d.lugar.length >= 3 || "Al menos 3 caracteres.",
  areaId: () => !!d.areaId || "Elija el área.",
  impactoComentario: () =>
    !impactoExigeComentario.value || d.impactoComentario.length >= 3 || "Este impacto exige un comentario.",
};

const err = (k) => (tocado.value && reglas[k]() !== true ? reglas[k]() : "");
const completa = computed(() => Object.values(reglas).every((r) => r() === true));
/** Un borrador se guarda con menos: sólo hace falta poder identificarlo. */
const minimo = computed(() => d.titulo.length >= 5 && !!d.areaId);

const pie = computed(() =>
  evidencias.value.length
    ? `${evidencias.value.length} evidencia(s) adjunta(s)`
    : "Puede guardarla y terminarla más tarde.",
);

watch(
  () => props.abierto,
  async (v) => {
    if (!v) return;
    Object.assign(d, vacio());
    evidencias.value = [];
    tocado.value = false;
    errorGeneral.value = "";
    try {
      const [a, c] = await Promise.all([organizacionApi.areas(), catalogosApi.todos("impacto_operativo")]);
      areas.value = a.data ?? [];
      impactos.value = c.data?.impacto_operativo ?? [];
      if (areas.value.length === 1) d.areaId = areas.value[0].id;
    } catch (e) {
      errorGeneral.value = e.message ?? "No se pudieron cargar las áreas.";
    }
    await nextTick();
    primerCampo.value?.focus();
  },
);

/** Los opcionales vacíos van como undefined: la API valida enums y "" no lo es. */
function cuerpo() {
  return Object.fromEntries(Object.entries(d).map(([k, v]) => [k, v === "" ? undefined : v]));
}

async function guardar(enviarAhora) {
  tocado.value = true;
  if (enviarAhora ? !completa.value : !minimo.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    // Se crea SIEMPRE como borrador para poder adjuntar antes de notificar: si
    // se enviara primero, el coordinador recibiría el aviso sin las evidencias.
    const r = await solicitudesApi.crear({ ...cuerpo(), enviar: false });

    const buenas = evidencias.value.filter((a) => !a.error).map((a) => a.file);
    if (buenas.length) {
      textoEnviando.value = `Subiendo ${buenas.length} evidencia(s)…`;
      const { fallos } = await subirVarios(buenas, {
        entidadTipo: "solicitud",
        entidadId: r.data.id,
        etapa: "solicitud",
      });
      if (fallos.length) {
        await notify.aviso("Algunas evidencias no se pudieron subir", fallos.join(" · "));
      }
    }

    if (enviarAhora) {
      textoEnviando.value = "Enviando…";
      await solicitudesApi.enviar(r.data.id);
    }

    await notify.exito(
      enviarAhora ? "Solicitud enviada" : "Borrador guardado",
      enviarAhora
        ? `${r.data.numero} · ${puedeDecidir ? "queda en la cola de revisión; puede tomarla usted mismo." : "un coordinador la revisará."}`
        : "Puede terminarla cuando quiera.",
    );
    emit("creada", r.data);
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo registrar la solicitud.";
  } finally {
    enviando.value = false;
    textoEnviando.value = "Enviando…";
  }
}

const enviar = () => guardar(true);
const guardarBorrador = () => guardar(false);
</script>
