<template>
  <div>
    <!-- Los filtros gobiernan TODA la pantalla, así que van arriba con el
         título, no dentro de una tarjeta que sugeriría que sólo afectan a ella. -->
    <PageHeader
      eyebrow="Conocimiento"
      title="Costos unitarios"
      subtitle="Lo que se cotizó en intervenciones comparables. No es contabilidad, y el sistema no adjudica proveedores."
    >
      <template #acciones>
        <div class="dash-filtros">
          <SelectMenu v-model="f.tipoTrabajoId" sabor="fil" :opciones="opcTipos" @change="cargar" />
          <SelectMenu v-model="f.moneda" sabor="fil" :opciones="OPC_MONEDA" @change="cargar" />
          <RangoFechas v-model:desde="f.desde" v-model:hasta="f.hasta" placeholder="Todo el periodo" @cambiar="cargar" />
          <label class="fil check">
            <input type="checkbox" v-model="f.incluirOutliers" @change="cargar" /> Incluir atípicos
          </label>
        </div>
      </template>
    </PageHeader>

    <Cargando v-if="cargando" texto="Reuniendo casos comparables…" />

    <template v-else-if="h">
      <!-- El hallazgo en prosa, no un número suelto: un promedio sin contexto
           se lee como más preciso de lo que es (cap. 32.4). -->
      <section class="hero">
        <div class="hero-cab">
          <div class="hero-tesis">
            <div class="eyebrow">{{ tituloTipo }}</div>
            <h2 v-if="h.estadisticas.promedio">
              Lo comparable ronda <b>{{ monto(h.estadisticas.promedio, h.contexto.moneda) }}</b>,
              entre {{ monto(h.estadisticas.minimo, h.contexto.moneda) }} y
              {{ monto(h.estadisticas.maximo, h.contexto.moneda) }}.
            </h2>
            <h2 v-else>Todavía no hay muestra suficiente para publicar un promedio.</h2>
            <p>
              {{ h.estadisticas.promedio ? h.contexto.advertencia : h.estadisticas.motivo_sin_promedio }}
            </p>
          </div>

          <div class="hero-cifras">
            <div class="hero-cifra">
              <div class="l">Casos</div>
              <div class="v">{{ h.contexto.casos }}</div>
            </div>
            <div class="hero-cifra">
              <div class="l">Mediana</div>
              <div class="v">{{ h.estadisticas.mediana ? monto(h.estadisticas.mediana, h.contexto.moneda) : "—" }}</div>
            </div>
            <div class="hero-cifra">
              <div class="l">Umbral</div>
              <div class="v">{{ h.contexto.umbral_minimo }}</div>
            </div>
          </div>
        </div>
      </section>

      <div class="kpi-row">
        <article class="kpi-card" style="--galon: var(--emerald)">
          <div class="k-l">Último costo</div>
          <div class="k-v mono">{{ h.ultimo_costo ? monto(h.ultimo_costo.monto, h.ultimo_costo.moneda) : "—" }}</div>
          <div class="k-p">{{ h.ultimo_costo ? `${h.ultimo_costo.proveedor ?? "Sin proveedor"} · ${fecha(h.ultimo_costo.fecha)}` : "Sin casos con estos filtros" }}</div>
        </article>

        <article class="kpi-card" style="--galon: var(--blue)">
          <div class="k-l">Mínimo observado</div>
          <div class="k-v mono">{{ h.estadisticas.minimo ? monto(h.estadisticas.minimo, h.contexto.moneda) : "—" }}</div>
          <div class="k-p">El caso más barato de la muestra</div>
        </article>

        <article class="kpi-card" style="--galon: var(--amber)">
          <div class="k-l">Máximo observado</div>
          <div class="k-v mono">{{ h.estadisticas.maximo ? monto(h.estadisticas.maximo, h.contexto.moneda) : "—" }}</div>
          <div class="k-p">El caso más caro de la muestra</div>
        </article>

        <article class="kpi-card" :style="{ '--galon': suficiente ? 'var(--emerald)' : 'var(--amber)' }">
          <div class="k-l">Muestra</div>
          <div class="k-v">{{ h.contexto.casos }} <small>de {{ h.contexto.umbral_minimo }} mínimos</small></div>
          <div class="k-p">{{ suficiente ? "Suficiente para publicar promedio" : "Insuficiente: no se publica promedio" }}</div>
          <div class="k-barra"><i :style="{ width: Math.min(100, (h.contexto.casos / h.contexto.umbral_minimo) * 100) + '%' }" /></div>
        </article>
      </div>

      <ModuloPanel titulo="Casos comparables" :icono="Coins" :conteo="h.registros.length" a-sangre>
        <template #acciones>
          <BotonExportar nombre="costos-unitarios" :columnas="COLUMNAS_EXCEL" :filas="visibles" />
        </template>

        <div v-if="h.registros.length" class="tabla-wrap" style="max-height: calc(100vh - 480px)">
          <table>
            <thead>
              <tr>
                <th v-for="c in COLUMNAS" :key="c.key" :class="c.align === 'right' ? 'num' : ''">{{ c.label }}</th>
              </tr>
              <FilaFiltros :columnas="COLUMNAS" v-model="filtros" />
            </thead>
            <tbody>
              <tr v-for="r in visibles" :key="r.id">
                <!-- El texto original es inmutable: es la procedencia del dato. -->
                <td class="mono" style="max-width: 300px; font-size: 11.5px">
                  <div class="truncar" :title="r.texto_original">{{ r.texto_original }}</div>
                </td>
                <td class="muted">{{ r.descripcion_normalizada ?? "—" }}</td>
                <td class="mono">{{ r.ot }}</td>
                <td class="muted truncar" style="max-width: 190px">{{ r.proveedor ?? "—" }}</td>
                <td class="num mono">{{ r.cantidad ? `${r.cantidad} ${r.unidad ?? ""}` : "—" }}</td>
                <td class="num mono">{{ r.costo_unitario ? monto(r.costo_unitario, r.moneda) : "—" }}</td>
                <td class="num mono" style="font-weight: 600; color: var(--ink)">{{ monto(r.monto, r.moneda) }}</td>
                <td class="nowrap">
                  <span class="mono muted">{{ fecha(r.fecha) }}</span>
                  <span v-if="r.es_outlier" class="tag" style="margin-left: 5px">Atípico</span>
                  <span v-if="r.emergencia" class="tag emergencia" style="margin-left: 5px">Emerg.</span>
                </td>
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
          :icono="Coins"
          titulo="Sin registros comparables"
          texto="Los costos se alimentan de las cotizaciones seleccionadas y de las OT cerradas. Pruebe con otro tipo de trabajo o amplíe el periodo."
        />
      </ModuloPanel>
    </template>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, toRef } from "vue";
import { Coins } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import ModuloPanel from "../../../shared/components/ui/ModuloPanel.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import RangoFechas from "../../../shared/components/ui/RangoFechas.vue";
import FilaFiltros from "../../../shared/components/ui/FilaFiltros.vue";
import BotonExportar from "../../../shared/components/ui/BotonExportar.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import { catalogosApi, costosApi } from "../../shared/catalogos.api.js";
import { useFiltroColumnas } from "../../../shared/composables/useFiltroColumnas.js";
import { fecha, monto } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const OPC_MONEDA = [
  { value: "PEN", label: "Soles", hint: "PEN" },
  { value: "USD", label: "Dólares", hint: "USD" },
  { value: "EUR", label: "Euros", hint: "EUR" },
];

const COLUMNAS = [
  { key: "texto_original", label: "Texto original", filtro: "texto" },
  { key: "descripcion_normalizada", label: "Normalizado", filtro: "texto" },
  { key: "ot", label: "OT", filtro: "texto" },
  { key: "proveedor", label: "Proveedor", filtro: "texto" },
  { key: "cantidad", label: "Cantidad", align: "right" },
  { key: "costo_unitario", label: "Unitario", align: "right", filtro: "numero", placeholder: "≥" },
  { key: "monto", label: "Total", align: "right", filtro: "numero", placeholder: "≥" },
  { key: "fecha", label: "Fecha", filtro: "limpiar" },
];

const COLUMNAS_EXCEL = [
  { key: "texto_original", label: "Texto original del documento" },
  { key: "descripcion_normalizada", label: "Descripción normalizada" },
  { key: "ot", label: "OT" },
  { key: "proveedor", label: "Proveedor" },
  { key: "concepto", label: "Concepto" },
  { key: "cantidad", label: "Cantidad" },
  { key: "unidad", label: "Unidad" },
  { key: "costo_unitario", label: "Costo unitario", tipo: "numero" },
  { key: "monto", label: "Monto total", tipo: "numero" },
  { key: "moneda", label: "Moneda" },
  { key: "es_outlier", label: "Atípico", valor: (r) => (r.es_outlier ? "Sí" : "No") },
  { key: "fecha", label: "Fecha", tipo: "fecha" },
];

const f = reactive({ tipoTrabajoId: "", moneda: "PEN", desde: "", hasta: "", incluirOutliers: false });
const h = ref(null);
const tiposTrabajo = ref([]);
const cargando = ref(true);

const registros = computed(() => h.value?.registros ?? []);
const { filtros, filtradas } = useFiltroColumnas(registros, COLUMNAS);
const visibles = filtradas;

const opcTipos = computed(() => [
  { value: "", label: "Todo tipo de trabajo" },
  ...tiposTrabajo.value.map((t) => ({
    value: t.id,
    label: t.nombre,
    hint: t.casos_historicos ? `${t.casos_historicos} caso(s)` : "",
  })),
]);

const tituloTipo = computed(() => {
  const t = tiposTrabajo.value.find((x) => x.id === f.tipoTrabajoId);
  return t ? t.nombre : "Todos los tipos de trabajo";
});

const suficiente = computed(
  () => (h.value?.contexto?.casos ?? 0) >= (h.value?.contexto?.umbral_minimo ?? 3),
);

async function cargar() {
  cargando.value = true;
  try {
    h.value = (await costosApi.historico({ ...f, incluirOutliers: f.incluirOutliers ? "true" : "" })).data;
  } catch (e) {
    await mostrarError(e, "No se pudo cargar el histórico");
  } finally {
    cargando.value = false;
  }
}

onMounted(async () => {
  try {
    tiposTrabajo.value = (await catalogosApi.tiposTrabajo()).data ?? [];
  } catch {
    // El filtro puede quedarse vacío sin romper la pantalla.
  }
  await cargar();
});
</script>
