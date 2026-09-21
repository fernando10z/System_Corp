<template>
  <div>
    <div class="fila fila-sep fila-wrap" style="margin-bottom: 14px; gap: 12px">
      <p class="muted" style="margin: 0; font-size: 12.5px; max-width: 68ch">
        MIP no compara proveedores: recibe la cotización final ya seleccionada. Sólo una vigente por OT; si hay
        proveedores o alcances independientes, eso son OT derivadas.
      </p>
      <button v-if="puede('cotizaciones:cargar')" class="btn primary" @click="modal = true">
        <Plus :size="14" /> {{ hayVigente ? "Reemplazar" : "Cargar cotización" }}
      </button>
    </div>

    <Vacio
      v-if="!ordenadas.length"
      :icono="Coins"
      titulo="Sin cotización cargada"
      texto="El inicio normal del trabajo requiere una cotización vigente. Una emergencia puede empezar sin ella, dejando la regularización pendiente."
    >
      <button v-if="puede('cotizaciones:cargar')" class="btn primary" @click="modal = true">Cargar la cotización</button>
    </Vacio>

    <div v-else>
      <article v-for="c in ordenadas" :key="c.id" class="version" :class="c.vigente ? 'vigente' : 'reemplazada'">
        <div class="version-cab">
          <span class="version-n">v{{ c.version }}</span>
          <span v-if="c.vigente" class="tag ok">Vigente</span>
          <span v-else-if="c.invalidada" class="tag emergencia">Invalidada</span>
          <span v-else class="tag">Reemplazada</span>
          <span class="crecer" />
          <span class="mas-muted mono" style="font-size: 11px">{{ c.cargada_por }} · {{ fechaHora(c.cargada_at) }}</span>
        </div>

        <!-- El importe es el dato que se busca: se muestra como cifra, no como
             una fila más de la rejilla. -->
        <div class="cotiz-importe">
          <div class="monto">{{ monto(c.monto, c.moneda) }}</div>
          <div class="mas-muted" style="font-size: 11.5px">
            {{ c.proveedor ?? "Sin proveedor" }}
            <span v-if="c.proveedor_ruc" class="mono"> · {{ c.proveedor_ruc }}</span>
          </div>
        </div>

        <div class="defs" style="margin-top: 14px">
          <div><div class="def-k">N.º de cotización</div><div class="def-v mono">{{ c.numero ?? "—" }}</div></div>
          <div><div class="def-k">Fecha</div><div class="def-v mono">{{ fecha(c.fecha) }}</div></div>
          <div>
            <div class="def-k">Plazo ofrecido</div>
            <div class="def-v">{{ c.plazo_ofrecido_dias ? dias(c.plazo_ofrecido_dias) : "—" }}</div>
          </div>
          <div>
            <div class="def-k">Validez</div>
            <div class="def-v">{{ c.validez_dias ? dias(c.validez_dias) : "—" }}</div>
          </div>
        </div>

        <!-- Una oferta caducada no debería aprobarse sin que alguien lo note:
             ámbar, que en este sistema significa "esto te espera a ti". -->
        <p v-if="c.vigente && venceEl(c) && vencida(c)" class="aviso espera" style="margin-top: 12px">
          <CalendarX2 :size="15" />
          <span>La oferta venció el <b style="display: inline">{{ fecha(venceEl(c)) }}</b>. Confirme el precio con el proveedor antes de seguir.</span>
        </p>

        <!-- El documento que respalda el importe: a un paso, sin salir de la OT. -->
        <div v-if="(c.adjuntos ?? []).length" class="cotiz-docs">
          <button
            v-for="a in c.adjuntos" :key="a.id" type="button" class="btn sm"
            :disabled="abriendo === a.id" @click="abrir(a)"
          >
            <span v-if="abriendo === a.id" class="spinner" />
            <FileText v-else :size="13" />
            {{ a.nombre }}
          </button>
        </div>

        <p v-if="c.observaciones" class="muted" style="margin: 12px 0 0; font-size: 12.5px">{{ c.observaciones }}</p>

        <div v-if="c.motivo_reemplazo" class="sello-motivo"><b>Motivo del reemplazo</b>{{ c.motivo_reemplazo }}</div>
        <div v-if="c.motivo_invalidacion" class="sello-motivo peligro">
          <b>Motivo de la invalidación</b>{{ c.motivo_invalidacion }}
        </div>
      </article>
    </div>

    <CotizacionModal
      :abierto="modal"
      :ot-id="otId"
      :hay-vigente="hayVigente"
      @cerrar="modal = false"
      @guardado="alGuardar"
    />
  </div>
</template>

<script setup>
import { computed, ref } from "vue";
import { CalendarX2, Coins, FileText, Plus } from "lucide-vue-next";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import CotizacionModal from "./CotizacionModal.vue";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { urlDeAdjunto } from "../../../shared/api/adjuntos.api.js";
import { notify } from "../../../shared/composables/useNotify.js";
import { dias, fecha, fechaHora, monto } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true }, otId: { type: String, required: true } });
const emit = defineEmits(["cambio"]);
const { puede } = useAuth();

const modal = ref(false);
const abriendo = ref("");

/** Fecha en la que caduca la oferta, si el documento traía ambas cosas. */
function venceEl(c) {
  if (!c.fecha || !c.validez_dias) return null;
  const f = new Date(c.fecha);
  f.setDate(f.getDate() + Number(c.validez_dias));
  return f.toISOString().slice(0, 10);
}
const vencida = (c) => venceEl(c) < new Date().toISOString().slice(0, 10);

/**
 * La URL del almacén es temporal y se pide en el momento: guardarla en el
 * listado la dejaría caducar en pantalla y expondría el archivo más tiempo del
 * necesario.
 */
async function abrir(a) {
  abriendo.value = a.id;
  try {
    const { url } = await urlDeAdjunto(a.id);
    window.open(url, "_blank", "noopener");
  } catch (e) {
    await notify.error("No se pudo abrir el documento", e.message);
  } finally {
    abriendo.value = "";
  }
}

const ordenadas = computed(() => [...(props.t.cotizaciones ?? [])].sort((a, b) => b.version - a.version));
const hayVigente = computed(() => ordenadas.value.some((c) => c.vigente));

function alGuardar() {
  modal.value = false;
  emit("cambio");
}
</script>

<style scoped>
.cotiz-importe {
  display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap;
  padding: 12px 14px; border-radius: var(--radius-sm);
  background: var(--bg-soft);
}
.cotiz-importe .monto {
  font-family: var(--font-mono);
  font-size: 22px; font-weight: 700; letter-spacing: -0.03em;
  color: var(--ink);
}
.version.reemplazada .cotiz-importe .monto { color: var(--ink-3); }

.cotiz-docs { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px; }
</style>
