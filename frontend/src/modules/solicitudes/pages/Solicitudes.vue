<template>
  <div>
    <PageHeader
      eyebrow="Entrada"
      title="Solicitudes de trabajo"
      subtitle="El reporte de quien detecta el problema. No se le pide que sepa qué lo causa."
    >
      <template #acciones>
        <button class="btn primary" @click="modal = true"><Plus :size="14" /> Nueva solicitud</button>
      </template>
    </PageHeader>

    <ModuloPanel titulo="Cartera de solicitudes" :icono="Inbox" :conteo="meta?.total ?? null" a-sangre>
      <template #acciones>
        <BotonExportar nombre="solicitudes" :columnas="COLUMNAS_EXCEL" :filas="visibles" :traer-todo="traerTodo" />
      </template>

      <template #filtros>
        <div class="fil grow">
          <Search :size="14" />
          <input v-model.trim="f.buscar" placeholder="Buscar por número, título o lugar…" @keyup.enter="cargar(1)" />
        </div>

        <RangoFechas v-model:desde="f.desde" v-model:hasta="f.hasta" placeholder="Enviadas: todo el periodo" @cambiar="cargar(1)" />
        <SelectMenu v-model="f.estado" sabor="fil" :opciones="opcEstados" @change="cargar(1)" />

        <label class="fil check">
          <input type="checkbox" v-model="f.pendientesRevision" @change="cargar(1)" /> Sólo por revisar
        </label>
        <label class="fil check">
          <input type="checkbox" v-model="f.mias" @change="cargar(1)" /> Sólo las mías
        </label>

        <div class="toolbar-spacer" />
        <button v-if="hayFiltros" class="chip-filter" @click="limpiar"><X :size="13" /> Limpiar filtros</button>
      </template>

      <Cargando v-if="cargando" :filas="6" />

      <div v-else-if="filas.length" class="tabla-wrap">
        <table>
          <thead>
            <tr>
              <th v-for="c in COLUMNAS" :key="c.key">{{ c.label }}</th>
            </tr>
            <FilaFiltros :columnas="COLUMNAS" v-model="filtros" />
          </thead>
          <tbody>
            <tr v-for="s in visibles" :key="s.id" class="clickable" @click="$router.push(`/solicitudes/${s.id}`)">
              <td class="mono" style="font-weight: 600">{{ s.numero }}</td>
              <td style="max-width: 340px">
                <div class="truncar" style="color: var(--ink); font-weight: 500">{{ s.titulo }}</div>
                <div class="muted truncar" style="font-size: 11.5px">{{ s.lugar }}</div>
              </td>
              <td>
                <span class="estado-pill" :class="tonoSolicitud(s.estado)"><span class="dot" />{{ etiqueta(s.estado) }}</span>
              </td>
              <td class="muted">{{ s.area ?? "—" }}</td>
              <td class="muted">{{ s.solicitante }}</td>
              <td>
                <span
                  v-if="s.horas_espera !== null && s.horas_espera !== undefined"
                  class="mono"
                  :class="claseEspera(s.horas_espera)"
                >{{ s.horas_espera }} h</span>
                <span v-else class="mas-muted">—</span>
              </td>
              <td class="mono">{{ s.ot?.numero ?? "—" }}</td>
            </tr>
          </tbody>
        </table>

        <div v-if="!visibles.length" class="vacio" style="padding: 40px 20px">
          <div class="vacio-titulo">Ninguna fila pasa los filtros de columna</div>
          <button class="btn" @click="filtros = {}">Quitar filtros de columna</button>
        </div>
      </div>

      <Vacio
        v-else
        :icono="Inbox"
        titulo="Ninguna solicitud con esos filtros"
        :texto="hayFiltros ? 'Pruebe a quitar algún filtro.' : 'Cuando alguien reporte una necesidad, aparecerá aquí para su revisión.'"
      >
        <button v-if="hayFiltros" class="btn" @click="limpiar">Quitar los filtros</button>
        <button v-else class="btn primary" @click="modal = true">Reportar una necesidad</button>
      </Vacio>

      <template v-if="!cargando && filas.length" #pie>
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </ModuloPanel>

    <SolicitudModal :abierto="modal" @cerrar="cerrarModal" @creada="alCrear" />
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, toRef } from "vue";
import { useRoute, useRouter } from "vue-router";
import { Inbox, Plus, Search, X } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import ModuloPanel from "../../../shared/components/ui/ModuloPanel.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import RangoFechas from "../../../shared/components/ui/RangoFechas.vue";
import FilaFiltros from "../../../shared/components/ui/FilaFiltros.vue";
import BotonExportar from "../../../shared/components/ui/BotonExportar.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import SolicitudModal from "../components/SolicitudModal.vue";
import { solicitudesApi } from "../api/solicitudes.api.js";
import { useFiltroColumnas } from "../../../shared/composables/useFiltroColumnas.js";
import { claseEspera, etiqueta, tonoSolicitud } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const route = useRoute();
const router = useRouter();

const ESTADOS = ["borrador", "enviada", "en_revision", "observada", "rechazada", "derivada", "duplicada", "convertida_en_ot"];
const opcEstados = [{ value: "", label: "Todos los estados" }, ...ESTADOS.map((e) => ({ value: e, label: etiqueta(e) }))];

const COLUMNAS = [
  { key: "numero", label: "Solicitud", filtro: "texto", placeholder: "ST-…" },
  { key: "titulo", label: "Título", filtro: "texto", valorFiltro: (s) => `${s.titulo ?? ""} ${s.lugar ?? ""}` },
  { key: "estado", label: "Estado", filtro: "select", opciones: ESTADOS.map((e) => ({ value: e, label: etiqueta(e) })) },
  { key: "area", label: "Área", filtro: "texto" },
  { key: "solicitante", label: "Solicitante", filtro: "texto" },
  { key: "horas_espera", label: "Espera", filtro: "numero", placeholder: "≥ h" },
  { key: "ot", label: "OT", filtro: "limpiar" },
];

const COLUMNAS_EXCEL = [
  { key: "numero", label: "Solicitud" },
  { key: "titulo", label: "Título" },
  { key: "lugar", label: "Lugar" },
  { key: "estado", label: "Estado", valor: (s) => etiqueta(s.estado) },
  { key: "area", label: "Área" },
  { key: "solicitante", label: "Solicitante" },
  { key: "prioridad_percibida", label: "Prioridad percibida", valor: (s) => etiqueta(s.prioridad_percibida) },
  { key: "horas_espera", label: "Horas de espera", tipo: "entero" },
  { key: "ot", label: "OT generada", valor: (s) => s.ot?.numero ?? "" },
  { key: "fecha", label: "Enviada", tipo: "fechaHora" },
];

const f = reactive({
  buscar: "",
  estado: "",
  desde: "",
  hasta: "",
  pendientesRevision: route.query.pendientesRevision === "true",
  mias: false,
});

const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);
const modal = ref(route.query.nueva === "1");

const { filtros, filtradas } = useFiltroColumnas(toRef(() => filas.value), COLUMNAS);
const visibles = filtradas;

const hayFiltros = computed(
  () => !!(f.buscar || f.estado || f.desde || f.hasta || f.pendientesRevision || f.mias),
);

function parametros(page, pageSize) {
  return {
    ...f,
    pendientesRevision: f.pendientesRevision ? "true" : "",
    mias: f.mias ? "true" : "",
    page,
    pageSize,
  };
}

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await solicitudesApi.listar(parametros(page, 25));
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar las solicitudes");
  } finally {
    cargando.value = false;
  }
}

async function traerTodo() {
  const todo = [];
  for (let page = 1; page <= 40; page++) {
    const r = await solicitudesApi.listar(parametros(page, 100));
    const lote = r.data ?? [];
    todo.push(...lote);
    if (lote.length < 100) break;
  }
  return todo;
}

function limpiar() {
  Object.assign(f, { buscar: "", estado: "", desde: "", hasta: "", pendientesRevision: false, mias: false });
  filtros.value = {};
  cargar(1);
}

function cerrarModal() {
  modal.value = false;
  // El enlace /solicitudes?nueva=1 abre el modal; al cerrarlo se limpia la URL.
  if (route.query.nueva) router.replace({ query: { ...route.query, nueva: undefined } });
}

function alCrear(s) {
  cerrarModal();
  router.push(`/solicitudes/${s.id}`);
}

onMounted(() => cargar(1));
</script>
