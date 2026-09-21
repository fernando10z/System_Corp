<template>
  <div>
    <PageHeader
      eyebrow="Administración de compras"
      title="Seguimiento administrativo"
      subtitle="SOLPED, orden de compra y liberación. Corre en paralelo al estado técnico: una OT cerrada puede seguir abierta aquí."
    />

    <div class="stat-row">
      <Stat
        label="En seguimiento"
        :valor="meta?.total ?? 0"
        :icono="Truck"
        meta="OT con algo pendiente o registrado"
      />
      <Stat
        label="Sin SOLPED"
        :valor="conteos.sinSolped"
        :tono="conteos.sinSolped ? 'espera' : ''"
        :icono="FileX"
        :color="conteos.sinSolped ? 'amber' : ''"
        meta="En esta página"
      />
      <Stat
        label="OC pendiente"
        :valor="conteos.ocPendiente"
        :tono="conteos.ocPendiente ? 'espera' : ''"
        :icono="ShoppingCart"
        :color="conteos.ocPendiente ? 'amber' : ''"
        meta="En esta página"
      />
      <Stat
        label="Cerradas con pendiente"
        :valor="conteos.cerradasPendiente"
        :tono="conteos.cerradasPendiente ? 'urgente' : ''"
        :icono="TriangleAlert"
        :color="conteos.cerradasPendiente ? 'red' : ''"
        meta="Registrar no las reabre"
      />
    </div>

    <ModuloPanel titulo="OT en seguimiento" :icono="Truck" color="violet" :conteo="meta?.total ?? null" a-sangre>
      <template #acciones>
        <BotonExportar nombre="seguimiento-administrativo" :columnas="COLUMNAS_EXCEL" :filas="visibles" />
      </template>

      <template #filtros>
        <div class="fil grow">
          <Search :size="14" />
          <input v-model.trim="f.buscar" placeholder="Buscar por número o texto…" @keyup.enter="cargar(1)" />
        </div>
        <RangoFechas v-model:desde="f.desde" v-model:hasta="f.hasta" placeholder="Creadas: todo el periodo" @cambiar="cargar(1)" />
        <SelectMenu v-model="f.estadoAdministrativo" sabor="fil" :opciones="opcAdmin" @change="cargar(1)" />
        <SelectMenu v-model="f.estado" sabor="fil" :opciones="OPC_OPERATIVO" @change="cargar(1)" />
        <div class="toolbar-spacer" />
        <button v-if="hayFiltros" class="chip-filter" @click="limpiar"><X :size="13" /> Limpiar filtros</button>
      </template>

      <Cargando v-if="cargando" :filas="6" />

      <div v-else-if="filas.length" class="tabla-wrap">
        <table>
          <thead>
            <tr>
              <th v-for="c in COLUMNAS" :key="c.key" :class="c.align === 'right' ? 'num' : ''">{{ c.label }}</th>
            </tr>
            <FilaFiltros :columnas="COLUMNAS" v-model="filtros" />
          </thead>
          <tbody>
            <tr v-for="o in visibles" :key="o.id" class="clickable" @click="$router.push(`/ot/${o.id}`)">
              <td class="mono" style="font-weight: 600; color: var(--ink)">{{ o.numero_ot }}</td>
              <td><EstadoOt :estado="o.estado" :admin="o.estado_administrativo" /></td>
              <td class="truncar" style="max-width: 340px">{{ o.titulo }}</td>
              <td class="num mono">{{ o.monto_cotizado ? monto(o.monto_cotizado, o.moneda) : "—" }}</td>
              <td class="muted" style="font-size: 11.5px">{{ o.empresa_ruc ?? "—" }}</td>
              <td class="mono muted nowrap">{{ o.fecha_cierre ? fecha(o.fecha_cierre) : "—" }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <Vacio
        v-else
        :icono="PackageCheck"
        titulo="Nada pendiente por aquí"
        texto="Cuando una OT tenga SOLPED, OC o liberación pendiente, aparecerá en esta lista."
      />

      <template v-if="!cargando && filas.length" #pie>
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </ModuloPanel>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, toRef } from "vue";
import { FileX, PackageCheck, Search, ShoppingCart, TriangleAlert, Truck, X } from "lucide-vue-next";
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
import { otApi } from "../../ot/api/ot.api.js";
import { useFiltroColumnas } from "../../../shared/composables/useFiltroColumnas.js";
import { etiqueta, fecha, monto } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const ADMIN = [
  "sin_solped", "solped_pendiente", "solped_creada", "oc_pendiente", "oc_registrada",
  "liberacion_pendiente", "liberacion_parcial", "liberacion_total",
];

const opcAdmin = [
  { value: "", label: "Todo estado administrativo" },
  ...ADMIN.map((e) => ({ value: e, label: etiqueta(e) })),
];

const OPC_OPERATIVO = [
  { value: "", label: "Todo estado operativo" },
  { value: "cerrada", label: "Cerradas" },
  { value: "en_trabajo", label: "En trabajo" },
  { value: "en_cotizacion", label: "En cotización" },
];

const COLUMNAS = [
  { key: "numero_ot", label: "OT", filtro: "texto", placeholder: "OT-…" },
  { key: "estado", label: "Estado", filtro: "texto",
    valorFiltro: (o) => `${etiqueta(o.estado)} ${etiqueta(o.estado_administrativo)}` },
  { key: "titulo", label: "Título", filtro: "texto" },
  { key: "monto_cotizado", label: "Cotizado", align: "right", filtro: "numero", placeholder: "≥" },
  { key: "empresa_ruc", label: "Organización", filtro: "texto" },
  { key: "fecha_cierre", label: "Cierre", filtro: "limpiar" },
];

const COLUMNAS_EXCEL = [
  { key: "numero_ot", label: "OT" },
  { key: "estado", label: "Estado operativo", valor: (o) => etiqueta(o.estado) },
  { key: "estado_administrativo", label: "Estado administrativo", valor: (o) => etiqueta(o.estado_administrativo) },
  { key: "titulo", label: "Título" },
  { key: "monto_cotizado", label: "Cotizado", tipo: "numero" },
  { key: "moneda", label: "Moneda" },
  { key: "empresa_ruc", label: "Empresa / RUC" },
  { key: "area", label: "Área" },
  { key: "fecha_cierre", label: "Cierre", tipo: "fecha" },
];

const f = reactive({ buscar: "", estadoAdministrativo: "", estado: "", desde: "", hasta: "" });
const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);

const { filtros, filtradas } = useFiltroColumnas(toRef(() => filas.value), COLUMNAS);
const visibles = filtradas;

const hayFiltros = computed(
  () => !!(f.buscar || f.estadoAdministrativo || f.estado || f.desde || f.hasta),
);

/** Cifras de ESTA página; se dice así en el contexto de cada tarjeta. */
const conteos = computed(() => ({
  sinSolped: visibles.value.filter((o) => ["sin_solped", "solped_pendiente"].includes(o.estado_administrativo)).length,
  ocPendiente: visibles.value.filter((o) => o.estado_administrativo === "oc_pendiente").length,
  cerradasPendiente: visibles.value.filter(
    (o) => o.estado === "cerrada" && o.estado_administrativo !== "administracion_completa",
  ).length,
}));

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await otApi.listar({ ...f, page, pageSize: 25 });
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudo cargar el seguimiento");
  } finally {
    cargando.value = false;
  }
}

function limpiar() {
  Object.assign(f, { buscar: "", estadoAdministrativo: "", estado: "", desde: "", hasta: "" });
  filtros.value = {};
  cargar(1);
}

onMounted(() => cargar(1));
</script>
