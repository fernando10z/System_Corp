<template>
  <div>
    <PageHeader
      eyebrow="Operación"
      title="Órdenes de trabajo"
      subtitle="Cada OT es una intervención técnica ejecutable. Si el alcance se divide, aparece como derivada."
    />

    <div class="stat-row">
      <Stat label="En la cartera" :valor="meta?.total ?? 0" :icono="ClipboardList" meta="Con los filtros actuales" />
      <Stat
        label="Emergencias"
        :valor="conteos.emergencias"
        :tono="conteos.emergencias ? 'urgente' : ''"
        :icono="Siren"
        :color="conteos.emergencias ? 'red' : ''"
        meta="En esta página"
      />
      <Stat
        label="Pausadas"
        :valor="conteos.pausadas"
        :tono="conteos.pausadas ? 'espera' : ''"
        :icono="PauseCircle"
        :color="conteos.pausadas ? 'amber' : ''"
        meta="No pueden declarar trabajo"
      />
      <Stat
        label="Cotizado visible"
        :valor="monto(conteos.cotizado, 'PEN')"
        pequeno
        :icono="Coins"
        meta="Suma de esta página, no de la cartera"
      />
    </div>

    <ModuloPanel titulo="Cartera de OT" :icono="ClipboardList" :conteo="meta?.total ?? null" a-sangre>
      <template #acciones>
        <BotonExportar nombre="ordenes-de-trabajo" :columnas="COLUMNAS_EXCEL" :filas="visibles" :traer-todo="traerTodo" />
      </template>

      <template #filtros>
        <div class="fil grow">
          <Search :size="14" />
          <input v-model.trim="f.buscar" placeholder="Buscar por número o texto…" @keyup.enter="cargar(1)" />
        </div>

        <RangoFechas
          v-model:desde="f.desde"
          v-model:hasta="f.hasta"
          placeholder="Creadas: todo el periodo"
          @cambiar="cargar(1)"
        />

        <SelectMenu v-model="f.estado" sabor="fil" :opciones="opcEstados" @change="cargar(1)" />
        <SelectMenu v-model="f.prioridadTecnica" sabor="fil" :opciones="OPC_PRIORIDAD" @change="cargar(1)" />
        <SelectMenu v-model="f.estadoAdministrativo" sabor="fil" :opciones="opcAdmin" @change="cargar(1)" />

        <label class="fil check">
          <input type="checkbox" v-model="f.soloEmergencias" @change="cargar(1)" /> Sólo emergencias
        </label>
        <label class="fil check">
          <input type="checkbox" v-model="f.soloPrincipales" @change="cargar(1)" /> Ocultar derivadas
        </label>

        <div class="toolbar-spacer" />
        <button v-if="hayFiltros" class="chip-filter" @click="limpiar"><X :size="13" /> Limpiar filtros</button>
      </template>

      <Cargando v-if="cargando" :filas="8" />

      <div v-else-if="filas.length" class="tabla-wrap" style="max-height: calc(100vh - 380px)">
        <table>
          <thead>
            <tr>
              <th v-for="c in COLUMNAS" :key="c.key" :class="c.align === 'right' ? 'num' : ''">{{ c.label }}</th>
            </tr>
            <FilaFiltros :columnas="COLUMNAS" v-model="filtros" />
          </thead>
          <tbody>
            <tr v-for="o in visibles" :key="o.id" class="clickable" @click="$router.push(`/ot/${o.id}`)">
              <td class="nowrap">
                <div class="fila" style="gap: 6px">
                  <span v-if="o.nivel" class="mas-muted" :style="{ paddingLeft: o.nivel * 11 + 'px' }">↳</span>
                  <span class="mono" style="font-weight: 600; color: var(--ink)">{{ o.numero_ot }}</span>
                </div>
                <div v-if="o.derivadas_activas" class="mas-muted" style="font-size: 10.5px; margin-top: 2px">
                  {{ o.derivadas_activas }} derivada(s) activa(s)
                </div>
              </td>
              <td><EstadoOt :estado="o.estado" :admin="o.estado_administrativo" /></td>
              <td style="max-width: 320px">
                <div class="truncar" style="color: var(--ink); font-weight: 500">{{ o.titulo }}</div>
                <div v-if="marcas(o).length" class="fila fila-wrap" style="gap: 5px; margin-top: 4px">
                  <span v-for="m in marcas(o)" :key="m.t" class="tag" :class="m.c">{{ m.t }}</span>
                </div>
              </td>
              <td><span class="prio" :class="'p-' + o.prioridad_tecnica">{{ etiqueta(o.prioridad_tecnica) }}</span></td>
              <td class="muted" style="font-size: 11.5px">
                {{ o.area ?? "—" }}
                <div class="mas-muted">{{ o.empresa_ruc ?? "" }}</div>
              </td>
              <td class="muted" style="font-size: 11.5px">
                {{ o.coordinador ?? "—" }}
                <div class="mas-muted">{{ o.ejecutor ?? "sin ejecutor" }}</div>
              </td>
              <td class="num mono">{{ o.monto_cotizado ? monto(o.monto_cotizado, o.moneda) : "—" }}</td>
              <td class="muted mono nowrap">{{ desde(o.fecha_creacion) }}</td>
            </tr>
          </tbody>
        </table>

        <div v-if="!visibles.length" class="vacio" style="padding: 40px 20px">
          <div class="vacio-titulo">Ninguna fila pasa los filtros de columna</div>
          <p class="vacio-texto">Los filtros de columna afinan lo ya cargado. Quítelos para volver a ver la página.</p>
          <button class="btn" @click="filtros = {}">Quitar filtros de columna</button>
        </div>
      </div>

      <Vacio
        v-else
        :icono="ClipboardList"
        titulo="Ninguna OT con esos filtros"
        texto="Las OT nacen al aceptar una solicitud. Pruebe a quitar algún filtro o revise la entrada."
      >
        <button v-if="hayFiltros" class="btn" @click="limpiar">Quitar los filtros</button>
        <router-link class="btn primary" to="/solicitudes?pendientesRevision=true">Ver solicitudes por revisar</router-link>
      </Vacio>

      <template v-if="!cargando && filas.length" #pie>
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </ModuloPanel>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, toRef } from "vue";
import { useRoute } from "vue-router";
import { ClipboardList, Coins, PauseCircle, Search, Siren, X } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import ModuloPanel from "../../../shared/components/ui/ModuloPanel.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import RangoFechas from "../../../shared/components/ui/RangoFechas.vue";
import FilaFiltros from "../../../shared/components/ui/FilaFiltros.vue";
import BotonExportar from "../../../shared/components/ui/BotonExportar.vue";
import Stat from "../../../shared/components/ui/Stat.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import { otApi } from "../api/ot.api.js";
import { useFiltroColumnas } from "../../../shared/composables/useFiltroColumnas.js";
import { desde, etiqueta, monto } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const route = useRoute();

const ESTADOS = ["creada", "en_diagnostico", "en_cotizacion", "en_trabajo", "trabajo_realizado", "cerrada", "cancelada"];
const ADMIN = [
  "sin_solped", "solped_pendiente", "solped_creada", "oc_pendiente", "oc_registrada",
  "liberacion_pendiente", "liberacion_parcial", "liberacion_total", "administracion_completa",
];

const opcEstados = [{ value: "", label: "Todos los estados" }, ...ESTADOS.map((e) => ({ value: e, label: etiqueta(e) }))];
const opcAdmin = [{ value: "", label: "Todo estado administrativo" }, ...ADMIN.map((e) => ({ value: e, label: etiqueta(e) }))];
const OPC_PRIORIDAD = [
  { value: "", label: "Toda prioridad" },
  { value: "critica", label: "Crítica", dot: "var(--red)" },
  { value: "alta", label: "Alta", dot: "var(--amber)" },
  { value: "media", label: "Media", dot: "var(--blue)" },
  { value: "baja", label: "Baja", dot: "var(--ink-4)" },
];

/**
 * Una sola definición de columnas para la cabecera, los filtros de columna y la
 * exportación: si se añade una columna, aparece en los tres sitios o en ninguno.
 */
const COLUMNAS = [
  { key: "numero_ot", label: "OT", filtro: "texto", placeholder: "OT-…" },
  { key: "estado", label: "Estado", filtro: "select", placeholder: "Todos",
    opciones: ESTADOS.map((e) => ({ value: e, label: etiqueta(e) })) },
  { key: "titulo", label: "Título", filtro: "texto" },
  { key: "prioridad_tecnica", label: "Prioridad", filtro: "select", placeholder: "Toda",
    opciones: ["critica", "alta", "media", "baja"].map((p) => ({ value: p, label: etiqueta(p) })) },
  { key: "area", label: "Organización", filtro: "texto",
    valorFiltro: (o) => `${o.area ?? ""} ${o.empresa_ruc ?? ""}` },
  { key: "coordinador", label: "Responsables", filtro: "texto",
    valorFiltro: (o) => `${o.coordinador ?? ""} ${o.ejecutor ?? ""}` },
  { key: "monto_cotizado", label: "Cotizado", align: "right", filtro: "numero", placeholder: "≥" },
  { key: "fecha_creacion", label: "Creada", filtro: "limpiar" },
];

const COLUMNAS_EXCEL = [
  { key: "numero_ot", label: "OT" },
  { key: "estado", label: "Estado", valor: (o) => etiqueta(o.estado) },
  { key: "estado_administrativo", label: "Estado administrativo", valor: (o) => etiqueta(o.estado_administrativo) },
  { key: "titulo", label: "Título" },
  { key: "prioridad_tecnica", label: "Prioridad", valor: (o) => etiqueta(o.prioridad_tecnica) },
  { key: "es_emergencia", label: "Emergencia", valor: (o) => (o.es_emergencia ? "Sí" : "No") },
  { key: "area", label: "Área" },
  { key: "empresa_ruc", label: "Empresa / RUC" },
  { key: "coordinador", label: "Coordinador" },
  { key: "ejecutor", label: "Ejecutor" },
  { key: "monto_cotizado", label: "Cotizado", tipo: "numero" },
  { key: "moneda", label: "Moneda" },
  { key: "fecha_creacion", label: "Creada", tipo: "fecha" },
  { key: "fecha_cierre", label: "Cierre", tipo: "fecha" },
];

const f = reactive({
  buscar: "",
  estado: route.query.estado ?? "",
  prioridadTecnica: "",
  estadoAdministrativo: "",
  desde: "",
  hasta: "",
  soloEmergencias: route.query.soloEmergencias === "true",
  soloPrincipales: false,
});

const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);

const { filtros, filtradas } = useFiltroColumnas(toRef(() => filas.value), COLUMNAS);
const visibles = filtradas;

const hayFiltros = computed(
  () => !!(f.buscar || f.estado || f.prioridadTecnica || f.estadoAdministrativo || f.desde || f.hasta || f.soloEmergencias || f.soloPrincipales),
);

const conteos = computed(() => ({
  emergencias: visibles.value.filter((o) => o.es_emergencia).length,
  pausadas: visibles.value.filter((o) => o.condicion === "pausada").length,
  cotizado: visibles.value.reduce((a, o) => a + Number(o.monto_cotizado ?? 0), 0),
}));

function marcas(o) {
  const m = [];
  if (o.es_emergencia) m.push({ t: "Emergencia", c: "emergencia" });
  if (o.condicion === "pausada") m.push({ t: "Pausada", c: "pausada" });
  if (o.regularizacion_pendiente) m.push({ t: "Regularizar", c: "espera" });
  if (o.veces_reabierta) m.push({ t: `Reabierta ×${o.veces_reabierta}`, c: "" });
  return m;
}

function parametros(page, pageSize) {
  return {
    ...f,
    soloEmergencias: f.soloEmergencias ? "true" : "",
    soloPrincipales: f.soloPrincipales ? "true" : "",
    page,
    pageSize,
  };
}

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await otApi.listar(parametros(page, 25));
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar las órdenes de trabajo");
  } finally {
    cargando.value = false;
  }
}

/** Para el Excel: todo lo que cumple el filtro, no sólo la página visible. */
async function traerTodo() {
  const todo = [];
  for (let page = 1; page <= 40; page++) {
    const r = await otApi.listar(parametros(page, 100));
    const lote = r.data ?? [];
    todo.push(...lote);
    if (lote.length < 100) break;
  }
  return todo;
}

function limpiar() {
  Object.assign(f, {
    buscar: "", estado: "", prioridadTecnica: "", estadoAdministrativo: "",
    desde: "", hasta: "", soloEmergencias: false, soloPrincipales: false,
  });
  filtros.value = {};
  cargar(1);
}

onMounted(() => cargar(1));
</script>
