<template>
  <div>
    <PageHeader eyebrow="Análisis" title="Indicadores" subtitle="Cada indicador dice cómo se calculó. Los números sin definición engañan.">
      <template #acciones>
        <button class="btn" :disabled="!filas.length" @click="exportar"><Download :size="14" /> Exportar CSV</button>
      </template>
    </PageHeader>

    <div class="filtros">
      <input v-model="f.desde" type="date" class="input" @change="cargar" />
      <input v-model="f.hasta" type="date" class="input" @change="cargar" />
    </div>

    <Cargando v-if="cargando" />

    <template v-else-if="k">
      <div class="bandeja" style="margin-bottom: 14px">
        <section class="bloque">
          <div class="bloque-head"><span class="bloque-n">{{ k.solicitudes?.creadas ?? 0 }}</span><span class="bloque-label">Solicitudes</span></div>
          <div class="bloque-lista">
            <div class="bloque-fila"><span class="crecer">Atendidas</span><b class="mono">{{ k.solicitudes?.atendidas ?? 0 }}</b></div>
            <div class="bloque-fila"><span class="crecer">Observadas</span><b class="mono">{{ k.solicitudes?.observadas ?? 0 }}</b></div>
            <div class="bloque-fila">
              <span class="crecer">Primera revisión</span>
              <b class="mono">{{ k.solicitudes?.horas_primera_revision_promedio ?? "—" }} h</b>
            </div>
          </div>
        </section>

        <section class="bloque">
          <div class="bloque-head"><span class="bloque-n">{{ k.ot?.total ?? 0 }}</span><span class="bloque-label">Órdenes de trabajo</span></div>
          <div class="bloque-lista">
            <div class="bloque-fila"><span class="crecer">Abiertas</span><b class="mono">{{ k.ot?.abiertas ?? 0 }}</b></div>
            <div class="bloque-fila"><span class="crecer">Cerradas</span><b class="mono">{{ k.ot?.cerradas ?? 0 }}</b></div>
            <div class="bloque-fila"><span class="crecer">Derivadas</span><b class="mono">{{ k.ot?.derivadas ?? 0 }}</b></div>
            <div class="bloque-fila"><span class="crecer">Reabiertas</span><b class="mono">{{ k.ot?.reabiertas ?? 0 }}</b></div>
          </div>
        </section>

        <section class="bloque" :class="k.emergencias?.cantidad ? 'urgente' : ''">
          <div class="bloque-head">
            <span class="bloque-n">{{ k.emergencias?.porcentaje ?? 0 }}%</span>
            <span class="bloque-label">Tasa de emergencia</span>
          </div>
          <div class="bloque-lista">
            <div class="bloque-fila"><span class="crecer">Emergencias</span><b class="mono">{{ k.emergencias?.cantidad ?? 0 }}</b></div>
            <div class="bloque-fila">
              <span class="crecer">Regularización pendiente</span>
              <b class="mono">{{ k.emergencias?.regularizacion_pendiente ?? 0 }}</b>
            </div>
          </div>
        </section>

        <section class="bloque">
          <div class="bloque-head">
            <span class="bloque-n">{{ k.duracion?.dias_promedio ?? "—" }}</span>
            <span class="bloque-label">Días de ejecución</span>
            <span class="bloque-accion">promedio</span>
          </div>
          <div class="bloque-lista">
            <div class="bloque-fila"><span class="crecer">Casos medidos</span><b class="mono">{{ k.duracion?.casos ?? 0 }}</b></div>
            <!-- Las pausas se reportan aparte, no se descuentan del total. -->
            <div class="bloque-fila"><span class="crecer">Horas en pausa</span><b class="mono">{{ k.duracion?.horas_pausa_promedio ?? 0 }}</b></div>
          </div>
        </section>

        <section class="bloque">
          <div class="bloque-head">
            <span class="bloque-n">{{ k.cierre_con_pendiente?.total ?? 0 }}</span>
            <span class="bloque-label">Cerradas con pendiente</span>
          </div>
          <div class="bloque-lista">
            <div class="bloque-fila"><span class="crecer">OC pendiente</span><b class="mono">{{ k.cierre_con_pendiente?.oc_pendiente ?? 0 }}</b></div>
            <div class="bloque-fila"><span class="crecer">Liberación parcial</span><b class="mono">{{ k.cierre_con_pendiente?.liberacion_parcial ?? 0 }}</b></div>
          </div>
          <div class="bloque-vacio" style="border-top: 1px solid var(--line-soft)">
            {{ k.cierre_con_pendiente?.nota }}
          </div>
        </section>

        <section class="bloque">
          <div class="bloque-head">
            <span class="bloque-n" style="font-size: 20px">
              {{ monto(k.costos?.monto_cotizado_total, "PEN") }}
            </span>
            <span class="bloque-label">Cotizado</span>
          </div>
          <div class="bloque-vacio">{{ k.costos?.advertencia }}</div>
        </section>
      </div>

      <div class="tbl-shell">
        <div class="card-head"><span class="card-titulo">Detalle de OT del periodo</span></div>
        <div class="tbl-scroll" style="max-height: 460px">
          <table class="stbl">
            <thead>
              <tr><th>OT</th><th>Estado</th><th>Título</th><th>Área</th><th>Tipo</th><th class="der">Días</th><th class="der">Cotizado</th></tr>
            </thead>
            <tbody>
              <tr v-for="r in filas" :key="r.numero_ot">
                <td class="mono">{{ r.numero_ot }}</td>
                <td><EstadoOt :estado="r.estado" :admin="r.estado_administrativo" /></td>
                <td style="max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">{{ r.titulo }}</td>
                <td class="muted">{{ r.area ?? "—" }}</td>
                <td class="muted">{{ r.tipo_trabajo ?? "—" }}</td>
                <td class="der mono">{{ r.duracion_dias ?? "—" }}</td>
                <td class="der mono">{{ r.monto_cotizado ? monto(r.monto_cotizado, r.moneda) : "—" }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { Download } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import { dashboardApi, reportesApi } from "../../shared/catalogos.api.js";
import { monto } from "../../../shared/utils/formato.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const hoy = new Date().toISOString().slice(0, 10);
const hace90 = new Date(Date.now() - 90 * 86400000).toISOString().slice(0, 10);

const f = reactive({ desde: hace90, hasta: hoy });
const k = ref(null);
const filas = ref([]);
const cargando = ref(true);

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

/** Exporta lo que hay en pantalla, con las mismas columnas que se ven. */
function exportar() {
  const cols = Object.keys(filas.value[0] ?? {});
  const escapa = (v) => `"${String(v ?? "").replace(/"/g, '""')}"`;
  const csv = [cols.join(","), ...filas.value.map((r) => cols.map((c) => escapa(r[c])).join(","))].join("\n");
  // BOM para que Excel en español respete los acentos.
  const blob = new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8;" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = `mip-ot-${f.desde}-a-${f.hasta}.csv`;
  a.click();
  URL.revokeObjectURL(a.href);
  notify.toast("Archivo descargado");
}

onMounted(cargar);
</script>
