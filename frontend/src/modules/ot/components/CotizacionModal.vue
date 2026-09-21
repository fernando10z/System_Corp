<template>
  <!--
    MIP no compara proveedores: recibe la cotización final ya seleccionada
    (cap. 28). Este formulario registra ese documento tal como llegó.
  -->
  <Modal
    :abierto="abierto"
    ancho="ancho"
    persistente
    :titulo="hayVigente ? 'Reemplazar la cotización vigente' : 'Cargar la cotización seleccionada'"
    :subtitulo="
      hayVigente
        ? 'La cotización actual se conserva con sus datos y el motivo del reemplazo.'
        : 'Sólo una cotización vigente por OT. Si hay proveedores o alcances independientes, eso son OT derivadas.'
    "
    @cerrar="cerrar"
  >
    <form id="form-cotizacion" class="col" style="gap: 16px" @submit.prevent="guardar">
      <!-- El PDF va primero: es el documento de verdad, y de él salen los datos
           que siguen. Escribirlos a mano sigue siendo posible. -->
      <Campo label="PDF de la cotización" :ayuda="ayudaPdf">
        <Adjuntos
          v-model="pdf" acepta="application/pdf" :maximo="26214400"
          titulo="Suelte aquí el PDF del proveedor"
          sugerencia="Arrastre el archivo o haga clic para buscarlo."
        />
      </Campo>

      <p v-if="leyendo" class="aviso info">
        <span class="spinner" /> <b>Leyendo el documento…</b>
      </p>

      <div v-else-if="lectura" class="aviso" :class="lectura.textoDetectado ? 'ok' : 'espera'">
        <component :is="lectura.textoDetectado ? FileCheck2 : TriangleAlert" :size="15" />
        <div style="flex: 1; min-width: 0">
          <b>{{ lectura.textoDetectado ? tituloLectura : "No se pudo leer el contenido" }}</b>
          {{ lectura.aviso ?? "Revise que todo coincida con el documento antes de guardar." }}
        </div>
        <button v-if="urlLocal" type="button" class="btn sm" @click="verPdf">
          <Eye :size="13" /> Ver PDF
        </button>
      </div>

      <div class="form-grid">
        <Campo
          label="Proveedor" requerido
          :marca="marcaDe('proveedorNombre')" :tono="tonoDe('proveedorNombre')"
          :error="tocado && !d.proveedorNombre ? 'Indique el proveedor.' : ''"
        >
          <input
            v-model.trim="d.proveedorNombre" class="input"
            :class="{ error: tocado && !d.proveedorNombre }"
            placeholder="Razón social" @input="confirmar('proveedorNombre')"
          />
        </Campo>

        <Campo
          label="RUC" ayuda="Opcional, pero ayuda a agrupar el histórico de costos."
          :marca="marcaDe('proveedorRuc')" :tono="tonoDe('proveedorRuc')"
        >
          <input
            v-model.trim="d.proveedorRuc" class="input mono" placeholder="20100000001"
            maxlength="11" @input="confirmar('proveedorRuc')"
          />
        </Campo>

        <Campo
          label="N.º de cotización"
          :marca="marcaDe('numeroCotizacion')" :tono="tonoDe('numeroCotizacion')"
        >
          <input
            v-model.trim="d.numeroCotizacion" class="input mono" placeholder="COT-2026-0081"
            @input="confirmar('numeroCotizacion')"
          />
        </Campo>

        <Campo label="Fecha del documento" :marca="marcaDe('fecha')" :tono="tonoDe('fecha')">
          <input v-model="d.fecha" type="date" class="input" @input="confirmar('fecha')" />
        </Campo>

        <Campo
          label="Monto" requerido
          :marca="marcaDe('monto')" :tono="tonoDe('monto')"
          :error="tocado && !montoValido ? 'Escriba un importe mayor que cero.' : ''"
        >
          <input
            v-model="d.monto" type="number" step="0.01" min="0" class="input mono"
            :class="{ error: tocado && !montoValido }" placeholder="0.00"
            @input="confirmar('monto')"
          />
        </Campo>

        <Campo label="Moneda" requerido :marca="marcaDe('moneda')" :tono="tonoDe('moneda')">
          <SelectMenu v-model="d.moneda" :opciones="OPC_MONEDA" @update:model-value="confirmar('moneda')" />
        </Campo>
      </div>

      <div class="form-grid">
        <Campo
          label="Plazo ofrecido" ayuda="En días calendario."
          :marca="marcaDe('plazoOfrecidoDias')" :tono="tonoDe('plazoOfrecidoDias')"
        >
          <input
            v-model="d.plazoOfrecidoDias" type="number" min="0" class="input mono" placeholder="15"
            @input="confirmar('plazoOfrecidoDias')"
          />
        </Campo>

        <Campo
          label="Validez de la oferta" ayuda="Opcional. Días hasta que caduque."
          :marca="marcaDe('validezDias')" :tono="tonoDe('validezDias')"
        >
          <input
            v-model="d.validezDias" type="number" min="0" class="input mono" placeholder="30"
            @input="confirmar('validezDias')"
          />
        </Campo>
      </div>

      <!-- La línea del PDF de la que salió cada dato dudoso: quien confirma ve
           de dónde vino el número sin tener que abrir el documento. -->
      <details v-if="dudosos.length" class="evidencias">
        <summary>De dónde salieron los datos marcados ({{ dudosos.length }})</summary>
        <ul>
          <li v-for="e in dudosos" :key="e.campo">
            <b>{{ e.etiqueta }}</b>
            <span class="mono">{{ e.evidencia }}</span>
          </li>
        </ul>
      </details>

      <Campo label="Observaciones" ayuda="Condiciones, exclusiones, lo que no entra en el precio.">
        <textarea
          v-model.trim="d.observaciones" class="textarea" style="min-height: 66px"
          placeholder="Ej. no incluye desmontaje ni transporte"
        />
      </Campo>

      <Campo
        v-if="hayVigente"
        label="¿Por qué se reemplaza la cotización vigente?"
        requerido
        :error="tocado && d.motivoReemplazo.length < 10 ? 'Necesita al menos 10 caracteres.' : ''"
      >
        <textarea
          v-model.trim="d.motivoReemplazo" class="textarea" style="min-height: 66px"
          :class="{ error: tocado && d.motivoReemplazo.length < 10 }"
          placeholder="Ej. el nuevo diagnóstico amplió el alcance"
        />
      </Campo>

      <p v-if="errorGeneral" class="aviso peligro"><TriangleAlert :size="15" /> {{ errorGeneral }}</p>
    </form>

    <template #acciones>
      <button class="btn" :disabled="enviando" @click="cerrar">Cancelar</button>
      <button class="btn primary" form="form-cotizacion" type="submit" :disabled="enviando || leyendo || !valido">
        <span v-if="enviando" class="spinner" />
        {{ enviando ? "Guardando…" : hayVigente ? "Reemplazar" : "Cargar cotización" }}
      </button>
    </template>
  </Modal>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { Eye, FileCheck2, TriangleAlert } from "lucide-vue-next";
import Modal from "../../../shared/components/ui/Modal.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import Adjuntos from "../../../shared/components/ui/Adjuntos.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import { otApi } from "../api/ot.api.js";
import { leerPdfCotizacion, subirVarios } from "../../../shared/api/adjuntos.api.js";
import { notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  otId: { type: String, required: true },
  hayVigente: { type: Boolean, default: false },
});
const emit = defineEmits(["cerrar", "guardado"]);

const OPC_MONEDA = [
  { value: "PEN", label: "Soles", hint: "PEN" },
  { value: "USD", label: "Dólares", hint: "USD" },
  { value: "EUR", label: "Euros", hint: "EUR" },
];

const ETIQUETAS = {
  proveedorNombre: "Proveedor",
  proveedorRuc: "RUC",
  numeroCotizacion: "N.º de cotización",
  fecha: "Fecha del documento",
  monto: "Monto",
  moneda: "Moneda",
  plazoOfrecidoDias: "Plazo ofrecido",
  validezDias: "Validez de la oferta",
};

const vacio = () => ({
  proveedorNombre: "", proveedorRuc: "", numeroCotizacion: "",
  fecha: new Date().toISOString().slice(0, 10),
  monto: "", moneda: "PEN", plazoOfrecidoDias: "", validezDias: "",
  observaciones: "", motivoReemplazo: "",
});

const d = reactive(vacio());
const pdf = ref([]);
const enviando = ref(false);
const tocado = ref(false);
const errorGeneral = ref("");

const leyendo = ref(false);
const lectura = ref(null);
/** Campo -> confianza con la que lo leyó el sistema. Se borra al editarlo a mano. */
const marcas = reactive({});
const urlLocal = ref("");

const montoValido = computed(() => Number(d.monto) > 0);
const valido = computed(
  () => !!d.proveedorNombre && montoValido.value && (!props.hayVigente || d.motivoReemplazo.length >= 10),
);

const ayudaPdf =
  "Súbalo y el sistema intenta llenar el formulario con lo que diga el documento. " +
  "Nada se guarda hasta que usted lo confirme; el PDF queda archivado junto a esta versión.";

const tituloLectura = computed(() => {
  const n = Object.keys(marcas).length;
  if (!n) return "El PDF se leyó, pero no se reconoció ningún dato";
  const dudosos = Object.values(marcas).filter((c) => c === "media").length;
  const llenados = n === 1 ? "Se llenó 1 campo" : `Se llenaron ${n} campos`;
  if (!dudosos) return `${llenados} con lo que decía el documento`;
  return dudosos === 1
    ? `${llenados}; 1 necesita que lo revise`
    : `${llenados}; ${dudosos} necesitan que los revise`;
});

/** Sólo los que quedaron dudosos: de los seguros no hace falta justificarse. */
const dudosos = computed(() =>
  Object.entries(marcas)
    .filter(([, c]) => c === "media")
    .map(([campo]) => ({
      campo,
      etiqueta: ETIQUETAS[campo] ?? campo,
      evidencia: lectura.value?.campos?.[campo]?.evidencia ?? "",
    }))
    .filter((e) => e.evidencia),
);

const marcaDe = (campo) =>
  marcas[campo] === "alta" ? "del PDF" : marcas[campo] === "media" ? "revíselo" : "";
const tonoDe = (campo) => (marcas[campo] === "media" ? "espera" : "ok");

/** En cuanto alguien toca el campo, el dato es suyo y la marca sobra. */
function confirmar(campo) {
  delete marcas[campo];
}

function limpiarUrl() {
  if (urlLocal.value) URL.revokeObjectURL(urlLocal.value);
  urlLocal.value = "";
}

function verPdf() {
  if (urlLocal.value) window.open(urlLocal.value, "_blank", "noopener");
}

/**
 * Se lee el PDF en cuanto se suelta, no al guardar: la persona tiene que ver el
 * resultado a tiempo de corregirlo. La lectura no escribe nada en el sistema.
 */
async function leer(archivo) {
  leyendo.value = true;
  lectura.value = null;
  Object.keys(marcas).forEach((k) => delete marcas[k]);
  try {
    const r = await leerPdfCotizacion(archivo);
    lectura.value = r;
    for (const [campo, leido] of Object.entries(r.campos ?? {})) {
      if (leido?.valor === undefined || leido.valor === null) continue;
      d[campo] = leido.valor;
      marcas[campo] = leido.confianza;
    }
  } catch (e) {
    lectura.value = { textoDetectado: false, campos: {}, aviso: e.message };
  } finally {
    leyendo.value = false;
  }
}

watch(pdf, (lista) => {
  const bueno = lista.find((a) => !a.error);
  limpiarUrl();
  if (!bueno) {
    lectura.value = null;
    Object.keys(marcas).forEach((k) => delete marcas[k]);
    return;
  }
  urlLocal.value = URL.createObjectURL(bueno.file);
  leer(bueno.file);
});

watch(
  () => props.abierto,
  (v) => {
    if (v) {
      Object.assign(d, vacio());
      pdf.value = [];
      tocado.value = false;
      errorGeneral.value = "";
      lectura.value = null;
      Object.keys(marcas).forEach((k) => delete marcas[k]);
    }
    limpiarUrl();
  },
);

function cerrar() {
  limpiarUrl();
  emit("cerrar");
}

async function guardar() {
  tocado.value = true;
  if (!valido.value) return;
  enviando.value = true;
  errorGeneral.value = "";
  try {
    const res = await otApi.cargarCotizacion(props.otId, {
      proveedorNombre: d.proveedorNombre,
      proveedorRuc: d.proveedorRuc || undefined,
      numeroCotizacion: d.numeroCotizacion || undefined,
      fecha: d.fecha || undefined,
      monto: Number(d.monto),
      moneda: d.moneda,
      plazoOfrecidoDias: d.plazoOfrecidoDias ? Number(d.plazoOfrecidoDias) : undefined,
      validezDias: d.validezDias ? Number(d.validezDias) : undefined,
      observaciones: d.observaciones || undefined,
      motivoReemplazo: props.hayVigente ? d.motivoReemplazo : undefined,
    });
    // El PDF se sube DESPUÉS: la cotización tiene que existir para colgarlo de
    // ella. Si falla el archivo, la cotización ya está registrada y se avisa —
    // perderla por un adjunto sería peor que avisar del adjunto.
    const archivos = pdf.value.filter((a) => !a.error).map((a) => a.file);
    let avisoPdf = "";
    if (archivos.length && res.data?.id) {
      const { fallos } = await subirVarios(archivos, {
        entidadTipo: "cotizacion",
        entidadId: res.data.id,
        etapa: "cotizacion",
      });
      if (fallos.length) avisoPdf = fallos.join(" · ");
    }

    // La API avisa si ya existía una SOLPED: MIP no modifica SAP por su cuenta.
    if (res.data?.advertencia) await notify.aviso("Cotización cargada, con una advertencia", res.data.advertencia);
    else if (avisoPdf) await notify.aviso("Cotización cargada, pero el PDF no subió", avisoPdf);
    else await notify.exito("Cotización cargada");
    limpiarUrl();
    emit("guardado");
  } catch (e) {
    errorGeneral.value = e.message ?? "No se pudo cargar la cotización.";
  } finally {
    enviando.value = false;
  }
}
</script>

<style scoped>
.evidencias {
  border: 1px solid var(--line); border-radius: var(--radius);
  background: var(--bg-soft); padding: 10px 14px; font-size: 12px;
}
.evidencias summary { cursor: pointer; color: var(--ink-2); font-weight: 500; }
.evidencias ul { list-style: none; margin: 10px 0 0; padding: 0; display: flex; flex-direction: column; gap: 7px; }
.evidencias li { display: flex; flex-direction: column; gap: 2px; }
.evidencias b { font-size: 11px; color: var(--ink-3); font-weight: 600; }
.evidencias .mono { font-size: 11.5px; color: var(--ink); word-break: break-word; }
</style>
