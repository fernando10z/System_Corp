<template>
  <div>
    <PageHeader
      eyebrow="Análisis"
      title="Indicadores"
      subtitle="Cada indicador dice cómo se calculó. Los números sin definición engañan."
    >
      <template #acciones>
        <!-- Los filtros mandan sobre toda la pantalla: van con el título. El
             botón de exportar vive en la tabla, que es lo que se exporta. -->
        <div class="dash-filtros">
          <RangoFechas v-model:desde="f.desde" v-model:hasta="f.hasta" placeholder="Elija el periodo" @cambiar="cargar" />
          <div class="toggle-group">
            <button v-for="p in PERIODOS" :key="p.d" :class="{ active: periodo === p.d }" @click="aplicarPeriodo(p.d)">
              {{ p.label }}
            </button>
          </div>
        </div>
      </template>
    </PageHeader>

    <Cargando v-if="cargando" texto="Calculando los indicadores…" />

    <template v-else-if="k">
      <section class="hero">
        <div class="hero-cab">
          <div class="hero-tesis">
            <div class="eyebrow">Del {{ fecha(f.desde) }} al {{ fecha(f.hasta) }}</div>
            <h2>
              Se abrieron <b>{{ k.ot?.total ?? 0 }}</b> órdenes de trabajo
              y se cerraron <b>{{ k.ot?.cerradas ?? 0 }}</b>.
            </h2>
            <p>{{ resumen }}</p>
          </div>

          <div class="hero-cifras">
            <div class="hero-cifra"><div class="l">Abiertas</div><div class="v">{{ k.ot?.abiertas ?? 0 }}</div></div>
            <div class="hero-cifra"><div class="l">Derivadas</div><div class="v">{{ k.ot?.derivadas ?? 0 }}</div></div>
            <div class="hero-cifra"><div class="l">Reabiertas</div><div class="v">{{ k.ot?.reabiertas ?? 0 }}</div></div>
          </div>
        </div>
      </section>

      <div class="kpi-row">
        <article class="kpi-card" :style="{ '--galon': tasaAlta ? 'var(--red)' : 'var(--emerald)' }">
          <div class="k-l">Tasa de emergencia</div>
          <div class="k-v">{{ k.emergencias?.porcentaje ?? 0 }} <small>%</small></div>
          <div class="k-p">{{ k.emergencias?.cantidad ?? 0 }} emergencia(s) · {{ k.emergencias?.regularizacion_pendiente ?? 0 }} sin regularizar</div>
          <div class="k-barra"><i :style="{ width: Math.min(100, k.emergencias?.porcentaje ?? 0) + '%' }" /></div>
        </article>

        <article class="kpi-card" style="--galon: var(--blue)">
          <div class="k-l">Días de ejecución</div>
          <div class="k-v">{{ k.duracion?.dias_promedio ?? "—" }} <small>promedio</small></div>
          <div class="k-p">{{ k.duracion?.casos ?? 0 }} caso(s) medidos · {{ k.duracion?.horas_pausa_promedio ?? 0 }} h de pausa</div>
        </article>

        <article class="kpi-card" :style="{ '--galon': (k.cierre_con_pendiente?.total ?? 0) ? 'var(--amber)' : 'var(--emerald)' }">
          <div class="k-l">Cerradas con pendiente</div>
          <div class="k-v">{{ k.cierre_con_pendiente?.total ?? 0 }}</div>
          <div class="k-p">{{ k.cierre_con_pendiente?.oc_pendiente ?? 0 }} sin OC · {{ k.cierre_con_pendiente?.liberacion_parcial ?? 0 }} liberación parcial</div>
        </article>

        <article class="kpi-card" style="--galon: var(--violet)">
          <div class="k-l">Cotizado en el periodo</div>
          <div class="k-v mono" style="font-size: 21px">{{ monto(k.costos?.monto_cotizado_total, "PEN") }}</div>
          <div class="k-p">Suma de cotizaciones vigentes, no costo final</div>
        </article>
      </div>

      <div class="dash-grid" style="margin-bottom: var(--gap-paneles)">
        <section class="panel">
          <div class="panel-head">
            <h3>Solicitudes del periodo</h3>
            <span class="meta">{{ k.solicitudes?.creadas ?? 0 }} creadas</span>
          </div>
          <div class="util-bar">
            <div class="util-bar-row">
              <span class="label">Atendidas</span>
              <span class="pct">{{ k.solicitudes?.atendidas ?? 0 }}</span>
              <div class="track"><div class="fill" :style="{ width: pctSolicitudes(k.solicitudes?.atendidas) + '%' }" /></div>
            </div>
            <div class="util-bar-row">
              <span class="label">Observadas</span>
              <span class="pct">{{ k.solicitudes?.observadas ?? 0 }}</span>
              <div class="track">
                <div class="fill" :style="{ width: pctSolicitudes(k.solicitudes?.observadas) + '%', background: 'var(--amber)' }" />
              </div>
            </div>
          </div>
          <div class="timeline-row" style="border: 0; padding: 0">
            <span class="when">1.ª rev.</span>
            <div class="what">
              <strong>{{ k.solicitudes?.horas_primera_revision_promedio ?? "—" }} h de media</strong>
              <small>Desde que se envía hasta que alguien la toma</small>
            </div>
          </div>
        </section>

        <section class="panel">
          <div class="panel-head"><h3>Cómo se calculó</h3></div>
          <ul class="notas">
            <li v-if="k.cierre_con_pendiente?.nota"><Info :size="13" />{{ k.cierre_con_pendiente.nota }}</li>
            <li v-if="k.costos?.advertencia"><Info :size="13" />{{ k.costos.advertencia }}</li>
            <li><Info :size="13" />La duración se cuenta en días calendario; las pausas se reportan aparte y no se descuentan.</li>
            <li><Info :size="13" />La tasa de emergencia mide clasificaciones, no incumplimientos técnicos.</li>
          </ul>
        </section>
      </div>

      <ModuloPanel titulo="Detalle de OT del periodo" :icono="ClipboardList" :conteo="visibles.length" a-sangre>
        <template #acciones>
          <BotonExportar nombre="indicadores-ot" :columnas="COLUMNAS_EXCEL" :filas="visibles" />
        </template>

        <div v-if="filas.length" class="tabla-wrap" style="max-height: 520px">
          <table>
            <thead>
              <tr>
                <th v-for="c in COLUMNAS" :key="c.key" :class="c.align === 'right' ? 'num' : ''">{{ c.label }}</th>
              </tr>
              <FilaFiltros :columnas="COLUMNAS" v-model="filtros" />
            </thead>
            <tbody>
              <tr v-for="r in visibles" :key="r.numero_ot">
                <td class="mono" style="font-weight: 600; color: var(--ink)">{{ r.numero_ot }}</td>
                <td><EstadoOt :estado="r.estado" :admin="r.estado_administrativo" /></td>
                <td class="truncar" style="max-width: 280px">{{ r.titulo }}</td>
                <td class="muted">{{ r.area ?? "—" }}</td>
                <td class="muted">{{ r.tipo_trabajo ?? "—" }}</td>
                <td class="num mono">{{ r.duracion_dias ?? "—" }}</td>
                <td class="num mono">{{ r.monto_cotizado ? monto(r.monto_cotizado, r.moneda) : "—" }}</td>
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
          :icono="ClipboardList"
          titulo="Ninguna OT en este periodo"
          texto="Amplíe el rango de fechas para ver movimiento."
        />
      </ModuloPanel>
    </template>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, toRef } from "vue";
import { ClipboardList, Info } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import ModuloPanel from "../../../shared/components/ui/ModuloPanel.vue";
import RangoFechas from "../../../shared/components/ui/RangoFechas.vue";
import FilaFiltros from "../../../shared/components/ui/FilaFiltros.vue";
import BotonExportar from "../../../shared/components/ui/BotonExportar.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import { dashboardApi, reportesApi } from "../../shared/catalogos.api.js";
import { useFiltroColumnas } from "../../../shared/composables/useFiltroColumnas.js";
import { etiqueta, fecha, monto } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const PERIODOS = [
  { d: 30, label: "30 d" },
  { d: 90, label: "90 d" },
  { d: 365, label: "1 año" },
];

const COLUMNAS = [
  { key: "numero_ot", label: "OT", filtro: "texto" },
  { key: "estado", label: "Estado", filtro: "texto", valorFiltro: (r) => etiqueta(r.estado) },
  { key: "titulo", label: "Título", filtro: "texto" },
  { key: "area", label: "Área", filtro: "texto" },
  { key: "tipo_trabajo", label: "Tipo", filtro: "texto" },
  { key: "duracion_dias", label: "Días", align: "right", filtro: "numero", placeholder: "≥" },
  { key: "monto_cotizado", label: "Cotizado", align: "right", filtro: "limpiar" },
];

const COLUMNAS_EXCEL = [
  { key: "numero_ot", label: "OT" },
  { key: "estado", label: "Estado", valor: (r) => etiqueta(r.estado) },
  { key: "estado_administrativo", label: "Estado administrativo", valor: (r) => etiqueta(r.estado_administrativo) },
  { key: "titulo", label: "Título" },
  { key: "area", label: "Área" },
  { key: "tipo_trabajo", label: "Tipo de trabajo" },
  { key: "duracion_dias", label: "Días de ejecución", tipo: "entero" },
  { key: "monto_cotizado", label: "Cotizado", tipo: "numero" },
  { key: "moneda", label: "Moneda" },
];

const iso = (d) => new Date(d).toISOString().slice(0, 10);
const hoy = iso(Date.now());

const f = reactive({ desde: iso(Date.now() - 90 * 86400000), hasta: hoy });
const periodo = ref(90);
const k = ref(null);
const filas = ref([]);
const cargando = ref(true);

const { filtros, filtradas } = useFiltroColumnas(toRef(() => filas.value), COLUMNAS);
const visibles = filtradas;

const tasaAlta = computed(() => (k.value?.emergencias?.porcentaje ?? 0) > 20);

const resumen = computed(() => {
  const x = k.value;
  if (!x) return "";
  const partes = [];
  if (x.emergencias?.regularizacion_pendiente)
    partes.push(`${x.emergencias.regularizacion_pendiente} emergencia(s) siguen sin regularizar`);
  if (x.cierre_con_pendiente?.total)
    partes.push(`${x.cierre_con_pendiente.total} se cerraron con pendiente administrativo`);
  if (x.ot?.reabiertas) partes.push(`${x.ot.reabiertas} se reabrieron`);
  return partes.length
    ? `${partes.join(", ")}. Cada cifra dice abajo cómo se calculó.`
    : "Sin emergencias sin regularizar ni cierres con pendiente en el periodo.";
});

function aplicarPeriodo(d) {
  periodo.value = d;
  f.desde = iso(Date.now() - d * 86400000);
  f.hasta = hoy;
  cargar();
}

function pctSolicitudes(n) {
  const total = k.value?.solicitudes?.creadas ?? 0;
  if (!total) return 0;
  return Math.round((Number(n ?? 0) / total) * 100);
}

async function cargar() {
  cargando.value = true;
  try {
    const [kp, rep] = await Promise.all([dashboardApi.kpis(f), reportesApi.ot(f)]);
    k.value = kp.data;
    filas.value = rep.data ?? [];
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar los indicadores");
  } finally {
    cargando.value = false;
  }
}

onMounted(cargar);
</script>

<style scoped>
.notas { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 9px; }
.notas li {
  display: flex; align-items: flex-start; gap: 8px;
  font-size: 12.5px; color: var(--ink-3); line-height: 1.5;
}
.notas li svg { flex: none; margin-top: 3px; color: var(--ink-4); }
</style>
