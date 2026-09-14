<template>
  <div>
    <PageHeader
      eyebrow="Transversal"
      title="Auditoría"
      subtitle="El detalle técnico de control. El historial en lenguaje de negocio está dentro de cada OT, en su trazabilidad."
    >
      <template #acciones>
        <button class="btn" @click="verificar"><ShieldCheck :size="14" /> Verificar trazabilidad</button>
      </template>
    </PageHeader>

    <div class="filtros">
      <input v-model.trim="f.entidad" class="input" placeholder="Entidad (orden_trabajo, cotizacion…)" @keyup.enter="cargar(1)" />
      <input v-model.trim="f.accion" class="input" placeholder="Acción (crear, cerrar…)" @keyup.enter="cargar(1)" />
      <input v-model="f.desde" type="date" class="input" @change="cargar(1)" />
      <input v-model="f.hasta" type="date" class="input" @change="cargar(1)" />
    </div>

    <div class="tbl-shell">
      <Cargando v-if="cargando" />
      <template v-else>
        <table class="stbl">
          <thead><tr><th>Instante</th><th>Actor</th><th>Acción</th><th>Entidad</th><th>Cambios</th><th>Motivo</th></tr></thead>
          <tbody>
            <tr v-for="a in filas" :key="a.id">
              <td class="mono muted nowrap">{{ fechaHora(a.fecha) }}</td>
              <td>{{ a.actor ?? "sistema" }}</td>
              <td><span class="tag">{{ a.accion }}</span></td>
              <td class="mono muted">{{ a.entidad }}</td>
              <td style="max-width: 340px">
                <!-- El diff campo a campo es el corazón de la auditoría (cap. 33). -->
                <div v-for="(v, k) in a.diff ?? {}" :key="k" class="sello-cambio" style="margin: 1px 0">
                  <span class="muted" style="font-family: var(--fuente)">{{ k }}:</span>
                  <span class="antes">{{ corto(v.antes) }}</span>
                  <span class="flecha">→</span>
                  <span class="despues">{{ corto(v.despues) }}</span>
                </div>
                <span v-if="!a.diff" class="muted">—</span>
              </td>
              <td class="muted" style="max-width: 220px; font-size: 12px">{{ a.motivo ?? "—" }}</td>
            </tr>
          </tbody>
        </table>
        <Vacio v-if="!filas.length" titulo="Sin registros" texto="Ajuste los filtros o amplíe el periodo." />
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { ShieldCheck } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import { auditoriaApi } from "../../shared/catalogos.api.js";
import { otApi } from "../../ot/api/ot.api.js";
import { fechaHora } from "../../../shared/utils/formato.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const f = reactive({ entidad: "", accion: "", desde: "", hasta: "" });
const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);

const corto = (v) => {
  const s = v === null || v === undefined ? "∅" : String(v);
  return s.length > 26 ? s.slice(0, 26) + "…" : s;
};

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await auditoriaApi.listar({ ...f, page, pageSize: 50 });
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudo cargar la auditoría");
  } finally {
    cargando.value = false;
  }
}

/**
 * Compara el árbol cacheado de cada OT contra la función que lo construye desde
 * las tablas. Si algo se desvía, es que un trigger de marcado dejó de dispararse.
 */
async function verificar() {
  try {
    const r = await otApi.verificarTrazabilidad();
    const d = r.data;
    if (d.integridad_ok) {
      await notify.exito(
        "Trazabilidad íntegra",
        `${d.revisadas} OT revisadas, ninguna desviada. ${d.sucias_pendientes} pendiente(s) de refresco.`,
      );
    } else {
      await notify.aviso(
        `${d.desviadas.length} OT con el árbol desviado`,
        `Afecta a: ${d.desviadas.map((x) => x.numero_ot).join(", ")}. El árbol se reconstruye al abrir cada OT.`,
      );
    }
  } catch (e) { await mostrarError(e); }
}

onMounted(() => cargar(1));
</script>
