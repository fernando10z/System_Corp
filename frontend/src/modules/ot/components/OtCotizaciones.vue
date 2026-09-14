<template>
  <div>
    <div class="fila fila-sep" style="margin-bottom: 12px">
      <p class="muted" style="margin: 0; font-size: 12.5px; max-width: 66ch">
        MIP no compara proveedores: recibe la cotización final ya seleccionada. Sólo una vigente por OT; si hay
        proveedores o alcances independientes, eso son OT derivadas.
      </p>
      <button v-if="puede('cotizaciones:cargar')" class="btn primary" @click="cargar">
        <Plus :size="14" /> {{ hayVigente ? "Reemplazar" : "Cargar cotización" }}
      </button>
    </div>

    <Vacio
      v-if="!(t.cotizaciones ?? []).length"
      titulo="Sin cotización cargada"
      texto="El inicio normal del trabajo requiere una cotización vigente. Una emergencia puede empezar sin ella, dejando la regularización pendiente."
    />

    <div v-else>
      <div v-for="c in ordenadas" :key="c.id" class="version" :class="c.vigente ? 'vigente' : 'reemplazada'">
        <div class="version-cab">
          <span class="version-n">v{{ c.version }}</span>
          <span v-if="c.vigente" class="tag ok">Vigente</span>
          <span v-else-if="c.invalidada" class="tag">Invalidada</span>
          <span v-else class="tag">Reemplazada</span>
          <span class="crecer"></span>
          <span class="muted mono" style="font-size: 11px">{{ c.cargada_por }} · {{ fechaHora(c.cargada_at) }}</span>
        </div>

        <div class="defs">
          <div><div class="def-k">Proveedor</div><div class="def-v">{{ c.proveedor ?? "—" }}</div></div>
          <div><div class="def-k">RUC</div><div class="def-v mono">{{ c.proveedor_ruc ?? "—" }}</div></div>
          <div><div class="def-k">N.º de cotización</div><div class="def-v mono">{{ c.numero ?? "—" }}</div></div>
          <div><div class="def-k">Fecha</div><div class="def-v mono">{{ fecha(c.fecha) }}</div></div>
          <div><div class="def-k">Monto</div><div class="def-v mono" style="font-weight:600">{{ monto(c.monto, c.moneda) }}</div></div>
          <div>
            <div class="def-k">Plazo ofrecido</div>
            <div class="def-v">{{ c.plazo_ofrecido_dias ? c.plazo_ofrecido_dias + " días" : "—" }}</div>
          </div>
        </div>

        <p v-if="c.observaciones" class="muted" style="margin: 9px 0 0; font-size: 12.5px">{{ c.observaciones }}</p>

        <div v-if="c.motivo_reemplazo" class="sello-motivo" style="margin-top: 9px">
          <b>Motivo del reemplazo</b>{{ c.motivo_reemplazo }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { Plus } from "lucide-vue-next";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import { otApi } from "../api/ot.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { fecha, fechaHora, monto } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true }, otId: { type: String, required: true } });
const emit = defineEmits(["cambio"]);
const { puede } = useAuth();

const ordenadas = computed(() => [...(props.t.cotizaciones ?? [])].sort((a, b) => b.version - a.version));
const hayVigente = computed(() => ordenadas.value.some((c) => c.vigente));

async function cargar() {
  const { default: Swal } = await import("sweetalert2");
  const r = await Swal.fire({
    title: hayVigente.value ? "Reemplazar la cotización" : "Cargar la cotización seleccionada",
    html: `
      <div style="text-align:left;display:grid;gap:9px">
        <label class="campo"><span class="campo-label">Proveedor</span>
          <input id="prov" class="swal2-input input" style="margin:0" placeholder="Razón social"></label>
        <label class="campo"><span class="campo-label">RUC</span>
          <input id="ruc" class="swal2-input input" style="margin:0" placeholder="20100000001"></label>
        <label class="campo"><span class="campo-label">N.º de cotización</span>
          <input id="num" class="swal2-input input" style="margin:0" placeholder="COT-2026-0081"></label>
        <label class="campo"><span class="campo-label">Monto</span>
          <input id="monto" type="number" step="0.01" min="0" class="swal2-input input" style="margin:0"></label>
        <label class="campo"><span class="campo-label">Moneda</span>
          <select id="moneda" class="swal2-input input" style="margin:0">
            <option value="PEN">Soles (PEN)</option><option value="USD">Dólares (USD)</option><option value="EUR">Euros (EUR)</option>
          </select></label>
        <label class="campo"><span class="campo-label">Plazo ofrecido (días)</span>
          <input id="plazo" type="number" min="0" class="swal2-input input" style="margin:0"></label>
      </div>`,
    width: 460,
    showCancelButton: true,
    confirmButtonText: hayVigente.value ? "Continuar" : "Cargar",
    cancelButtonText: "Cancelar",
    buttonsStyling: false,
    reverseButtons: true,
    customClass: { popup: "swal-mip", confirmButton: "btn primary", cancelButton: "btn" },
    preConfirm: () => {
      const v = (id) => document.getElementById(id)?.value?.trim() ?? "";
      if (!v("prov")) { Swal.showValidationMessage("Indique el proveedor"); return false; }
      return {
        proveedorNombre: v("prov"),
        proveedorRuc: v("ruc") || undefined,
        numeroCotizacion: v("num") || undefined,
        monto: v("monto") ? Number(v("monto")) : undefined,
        moneda: v("moneda") || "PEN",
        plazoOfrecidoDias: v("plazo") ? Number(v("plazo")) : undefined,
      };
    },
  });
  if (!r.isConfirmed) return;

  const body = r.value;
  // Reemplazar exige motivo: la versión anterior se conserva con él (cap. 28.2).
  if (hayVigente.value) {
    const motivo = await notify.pedirTexto("¿Por qué se reemplaza la cotización vigente?", {
      texto: "La anterior se conserva con sus datos y este motivo.",
      placeholder: "Ej. el nuevo diagnóstico amplió el alcance",
      confirmar: "Reemplazar", minimo: 10,
    });
    if (!motivo) return;
    body.motivoReemplazo = motivo;
  }

  try {
    const res = await otApi.cargarCotizacion(props.otId, body);
    // La API avisa si ya existía una SOLPED: MIP no modifica SAP solo.
    if (res.data?.advertencia) await notify.aviso("Cotización cargada, con una advertencia", res.data.advertencia);
    else await notify.exito("Cotización cargada");
    emit("cambio");
  } catch (e) {
    await mostrarError(e);
  }
}
</script>
