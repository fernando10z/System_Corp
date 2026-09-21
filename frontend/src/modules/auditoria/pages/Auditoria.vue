<template>
  <div>
    <PageHeader
      eyebrow="Transversal"
      title="Auditoría"
      subtitle="El detalle técnico de control, campo a campo. El historial en lenguaje de negocio está dentro de cada OT, en su trazabilidad."
    >
      <template #acciones>
        <button class="btn" :disabled="verificando" @click="verificar">
          <span v-if="verificando" class="spinner" style="border-color: var(--line-strong); border-top-color: var(--ink)" />
          <ShieldCheck v-else :size="14" />
          Verificar trazabilidad
        </button>
      </template>
    </PageHeader>

    <ModuloPanel titulo="Registro de cambios" :icono="ScrollText" color="neutral" :conteo="meta?.total ?? null" a-sangre>
      <template #acciones>
        <BotonExportar nombre="auditoria" :columnas="COLUMNAS_EXCEL" :filas="visibles" />
      </template>

      <template #filtros>
        <div class="fil">
          <Database :size="14" />
          <input v-model.trim="f.entidad" placeholder="Entidad (orden_trabajo…)" @keyup.enter="cargar(1)" />
        </div>
        <div class="fil">
          <Zap :size="14" />
          <input v-model.trim="f.accion" placeholder="Acción (crear, cerrar…)" @keyup.enter="cargar(1)" />
        </div>
        <RangoFechas v-model:desde="f.desde" v-model:hasta="f.hasta" placeholder="Todo el periodo" @cambiar="cargar(1)" />
        <div class="toolbar-spacer" />
        <button v-if="hayFiltros" class="chip-filter" @click="limpiar"><X :size="13" /> Limpiar</button>
      </template>

      <Cargando v-if="cargando" :filas="8" />

      <div v-else-if="filas.length" class="tabla-wrap" style="max-height: calc(100vh - 330px)">
        <table>
          <thead>
            <tr>
              <th v-for="c in COLUMNAS" :key="c.key">{{ c.label }}</th>
            </tr>
            <FilaFiltros :columnas="COLUMNAS" v-model="filtros" />
          </thead>
          <tbody>
            <tr v-for="a in visibles" :key="a.id">
              <td class="mono muted nowrap">{{ fechaHora(a.fecha) }}</td>
              <td>{{ a.actor ?? "sistema" }}</td>
              <td><span class="tag mono">{{ a.accion }}</span></td>
              <td class="mono muted">{{ a.entidad }}</td>
              <td style="max-width: 360px">
                <!-- El diff campo a campo es el corazón de la auditoría (cap. 33). -->
                <div v-for="(v, k) in a.diff ?? {}" :key="k" class="sello-cambio" style="margin: 1px 0; display: flex">
                  <span class="mas-muted" style="font-family: var(--font)">{{ k }}:</span>
                  <span class="antes">{{ corto(v.antes) }}</span>
                  <span class="flecha">→</span>
                  <span class="despues">{{ corto(v.despues) }}</span>
                </div>
                <span v-if="!a.diff" class="mas-muted">—</span>
              </td>
              <td class="muted" style="max-width: 220px; font-size: 12px">{{ a.motivo ?? "—" }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <Vacio
        v-else
        :icono="ScrollText"
        titulo="Sin registros"
        texto="Ajuste los filtros o amplíe el periodo. La auditoría no se borra: si no aparece nada, es que no hubo movimiento."
      />

      <template v-if="!cargando && filas.length" #pie>
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </ModuloPanel>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, toRef } from "vue";
import { Database, ScrollText, ShieldCheck, X, Zap } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import ModuloPanel from "../../../shared/components/ui/ModuloPanel.vue";
import RangoFechas from "../../../shared/components/ui/RangoFechas.vue";
import FilaFiltros from "../../../shared/components/ui/FilaFiltros.vue";
import BotonExportar from "../../../shared/components/ui/BotonExportar.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import { auditoriaApi } from "../../shared/catalogos.api.js";
import { otApi } from "../../ot/api/ot.api.js";
import { useFiltroColumnas } from "../../../shared/composables/useFiltroColumnas.js";
import { fechaHora } from "../../../shared/utils/formato.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const COLUMNAS = [
  { key: "fecha", label: "Instante" },
  { key: "actor", label: "Actor", filtro: "texto" },
  { key: "accion", label: "Acción", filtro: "texto" },
  { key: "entidad", label: "Entidad", filtro: "texto" },
  { key: "diff", label: "Cambios" },
  { key: "motivo", label: "Motivo", filtro: "limpiar" },
];

const COLUMNAS_EXCEL = [
  { key: "fecha", label: "Instante", tipo: "fechaHora" },
  { key: "actor", label: "Actor" },
  { key: "accion", label: "Acción" },
  { key: "entidad", label: "Entidad" },
  { key: "entidad_id", label: "Id de la entidad" },
  { key: "diff", label: "Cambios", valor: (a) => (a.diff ? JSON.stringify(a.diff) : "") },
  { key: "motivo", label: "Motivo" },
];

const f = reactive({ entidad: "", accion: "", desde: "", hasta: "" });
const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);
const verificando = ref(false);

const { filtros, filtradas } = useFiltroColumnas(toRef(() => filas.value), COLUMNAS);
const visibles = filtradas;

const hayFiltros = computed(() => !!(f.entidad || f.accion || f.desde || f.hasta));

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

function limpiar() {
  Object.assign(f, { entidad: "", accion: "", desde: "", hasta: "" });
  filtros.value = {};
  cargar(1);
}

/**
 * Compara el árbol cacheado de cada OT contra la función que lo construye desde
 * las tablas. Si algo se desvía, es que un trigger de marcado dejó de dispararse.
 */
async function verificar() {
  verificando.value = true;
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
  } catch (e) {
    await mostrarError(e);
  } finally {
    verificando.value = false;
  }
}

onMounted(() => cargar(1));
</script>
