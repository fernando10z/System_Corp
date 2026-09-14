<template>
  <div>
    <div class="fila fila-sep" style="margin-bottom: 12px">
      <p class="muted" style="margin: 0; font-size: 12.5px; max-width: 66ch">
        Un cambio de diagnóstico no sobrescribe el anterior: crea una versión nueva y conserva la previa con su motivo.
      </p>
      <button v-if="puede('diagnosticos:registrar')" class="btn primary" @click="registrar">
        <Plus :size="14" /> {{ hayVigente ? "Nueva versión" : "Registrar diagnóstico" }}
      </button>
    </div>

    <Vacio
      v-if="!(t.diagnosticos ?? []).length"
      titulo="Todavía sin diagnóstico"
      texto="La OT no puede pasar a cotización hasta que exista un diagnóstico con sus cuatro campos técnicos."
    />

    <div v-else>
      <!-- Se muestran de la más reciente a la más antigua; las reemplazadas se
           apagan pero siguen ahí y siguen siendo legibles. -->
      <div v-for="d in ordenados" :key="d.id" class="version" :class="d.vigente ? 'vigente' : 'reemplazada'">
        <div class="version-cab">
          <span class="version-n">v{{ d.version }}</span>
          <span v-if="d.vigente" class="tag ok">Vigente</span>
          <span v-else class="tag">Reemplazado</span>
          <span v-if="d.aprobado_at" class="tag info">Aprobado</span>
          <span class="crecer"></span>
          <span class="muted mono" style="font-size: 11px">{{ d.autor }} · {{ fechaHora(d.fecha) }}</span>
          <button
            v-if="d.vigente && !d.aprobado_at && puede('diagnosticos:aprobar')"
            class="btn sm" @click="aprobar(d)"
          >
            Aprobar
          </button>
        </div>

        <div class="version-cuerpo">
          <div class="version-campo"><div class="version-campo-k">Diagnóstico</div>{{ d.diagnostico }}</div>
          <div class="version-campo"><div class="version-campo-k">Causa probable</div>{{ d.causa_probable }}</div>
          <div class="version-campo"><div class="version-campo-k">Alcance</div>{{ d.alcance }}</div>
          <div class="version-campo"><div class="version-campo-k">Trabajo a realizar</div>{{ d.trabajo_a_realizar }}</div>
          <div v-if="d.lecturas_instrumentos" class="version-campo">
            <div class="version-campo-k">Lecturas de instrumentos</div>{{ d.lecturas_instrumentos }}
          </div>
        </div>

        <div v-if="d.motivo_cambio" class="sello-motivo" style="margin-top: 9px">
          <b>Motivo del cambio</b>{{ d.motivo_cambio }}
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
import { fechaHora } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true }, otId: { type: String, required: true } });
const emit = defineEmits(["cambio"]);
const { puede } = useAuth();

const ordenados = computed(() => [...(props.t.diagnosticos ?? [])].sort((a, b) => b.version - a.version));
const hayVigente = computed(() => ordenados.value.some((d) => d.vigente));

/**
 * Los cuatro campos técnicos se piden uno a uno, en su orden lógico. Un
 * formulario largo en un diálogo se rellena mal; esto obliga a pensar cada campo.
 */
async function registrar() {
  const diagnostico = await notify.pedirTexto("Diagnóstico · 1 de 4", {
    texto: "Qué está pasando, según la inspección.",
    confirmar: "Siguiente", minimo: 10,
  });
  if (!diagnostico) return;

  const causaProbable = await notify.pedirTexto("Causa probable · 2 de 4", {
    texto: "Puede evolucionar tras el desmontaje; entonces se registra una versión nueva.",
    confirmar: "Siguiente", minimo: 5,
  });
  if (!causaProbable) return;

  const alcance = await notify.pedirTexto("Alcance · 3 de 4", {
    texto: "Hasta dónde llega esta intervención.",
    confirmar: "Siguiente", minimo: 5,
  });
  if (!alcance) return;

  const trabajoARealizar = await notify.pedirTexto("Trabajo a realizar · 4 de 4", {
    texto: "El plan de trabajo, no el trabajo ya ejecutado.",
    confirmar: hayVigente.value ? "Siguiente" : "Registrar", minimo: 5,
  });
  if (!trabajoARealizar) return;

  let motivoCambio = "";
  if (hayVigente.value) {
    motivoCambio = await notify.pedirTexto("¿Por qué se reemplaza el diagnóstico vigente?", {
      texto: "La versión anterior se conserva con este motivo.",
      confirmar: "Registrar versión", minimo: 10,
    });
    if (!motivoCambio) return;
  }

  try {
    const r = await otApi.registrarDiagnostico(props.otId, {
      diagnostico, causaProbable, alcance, trabajoARealizar, motivoCambio,
    });
    await notify.exito("Diagnóstico registrado", `Versión ${r.data.version}`);
    emit("cambio");
  } catch (e) {
    await mostrarError(e);
  }
}

async function aprobar(d) {
  if (!(await notify.confirmar("Aprobar el diagnóstico", `Versión ${d.version}.`, { confirmar: "Aprobar" }))) return;
  try {
    await otApi.aprobarDiagnostico(d.id);
    await notify.exito("Diagnóstico aprobado");
    emit("cambio");
  } catch (e) {
    await mostrarError(e);
  }
}
</script>
