<template>
  <div>
    <div class="fila fila-sep fila-wrap" style="margin-bottom: 14px; gap: 12px">
      <p class="muted" style="margin: 0; font-size: 12.5px; max-width: 68ch">
        Un cambio de diagnóstico no sobrescribe el anterior: crea una versión nueva y conserva la previa con su motivo.
      </p>
      <button v-if="puede('diagnosticos:registrar')" class="btn primary" @click="modal = true">
        <Plus :size="14" /> {{ hayVigente ? "Nueva versión" : "Registrar diagnóstico" }}
      </button>
    </div>

    <Vacio
      v-if="!ordenados.length"
      :icono="Stethoscope"
      titulo="Todavía sin diagnóstico"
      texto="La OT no puede pasar a cotización hasta que exista un diagnóstico con sus cuatro campos técnicos."
    >
      <button v-if="puede('diagnosticos:registrar')" class="btn primary" @click="modal = true">
        Registrar el diagnóstico
      </button>
    </Vacio>

    <div v-else>
      <!-- De la más reciente a la más antigua; las reemplazadas se apagan pero
           siguen ahí y siguen siendo legibles. -->
      <article v-for="d in ordenados" :key="d.id" class="version" :class="d.vigente ? 'vigente' : 'reemplazada'">
        <div class="version-cab">
          <span class="version-n">v{{ d.version }}</span>
          <span v-if="d.vigente" class="tag ok">Vigente</span>
          <span v-else class="tag">Reemplazado</span>
          <span v-if="d.aprobado_at" class="tag info"><Check :size="11" /> Aprobado</span>
          <span class="crecer" />
          <span class="mas-muted mono" style="font-size: 11px">{{ d.autor }} · {{ fechaHora(d.fecha) }}</span>
          <button
            v-if="d.vigente && !d.aprobado_at && puede('diagnosticos:aprobar')"
            class="btn sm"
            @click="aprobar(d)"
          >
            Aprobar
          </button>
        </div>

        <div class="version-cuerpo">
          <div class="version-campo"><div class="version-campo-k">Diagnóstico</div>{{ d.diagnostico }}</div>
          <div class="version-campo"><div class="version-campo-k">Causa probable</div>{{ d.causa_probable }}</div>
          <div class="grid-2" style="gap: 10px 22px; margin-top: 10px">
            <div class="version-campo" style="margin: 0"><div class="version-campo-k">Alcance</div>{{ d.alcance }}</div>
            <div class="version-campo" style="margin: 0">
              <div class="version-campo-k">Trabajo a realizar</div>{{ d.trabajo_a_realizar }}
            </div>
          </div>
          <div v-if="d.lecturas_instrumentos" class="version-campo">
            <div class="version-campo-k">Lecturas de instrumentos</div>
            <span class="mono">{{ d.lecturas_instrumentos }}</span>
          </div>
        </div>

        <div v-if="d.motivo_cambio" class="sello-motivo"><b>Motivo del cambio</b>{{ d.motivo_cambio }}</div>
      </article>
    </div>

    <DiagnosticoModal
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
import { Check, Plus, Stethoscope } from "lucide-vue-next";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import DiagnosticoModal from "./DiagnosticoModal.vue";
import { otApi } from "../api/ot.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { fechaHora } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true }, otId: { type: String, required: true } });
const emit = defineEmits(["cambio"]);
const { puede } = useAuth();

const modal = ref(false);

const ordenados = computed(() => [...(props.t.diagnosticos ?? [])].sort((a, b) => b.version - a.version));
const hayVigente = computed(() => ordenados.value.some((d) => d.vigente));

function alGuardar() {
  modal.value = false;
  emit("cambio");
}

async function aprobar(d) {
  const ok = await notify.confirmar(
    "Aprobar el diagnóstico",
    `Versión ${d.version}. La aprobación queda sellada con su nombre y su instante.`,
    { confirmar: "Aprobar" },
  );
  if (!ok) return;
  try {
    await otApi.aprobarDiagnostico(d.id);
    await notify.exito("Diagnóstico aprobado");
    emit("cambio");
  } catch (e) {
    await mostrarError(e);
  }
}
</script>
