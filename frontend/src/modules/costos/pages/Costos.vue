<template>
  <div>
    <PageHeader
      eyebrow="Conocimiento"
      title="Costos unitarios"
      subtitle="Lo que se cotizó en intervenciones comparables. No es contabilidad, y el sistema no adjudica proveedores."
    />

    <div class="filtros">
      <select v-model="f.tipoTrabajoId" class="select" @change="cargar">
        <option value="">Todo tipo de trabajo</option>
        <option v-for="t in tiposTrabajo" :key="t.id" :value="t.id">
          {{ t.nombre }}<template v-if="t.casos_historicos"> ({{ t.casos_historicos }})</template>
        </option>
      </select>
      <select v-model="f.moneda" class="select" @change="cargar">
        <option value="PEN">Soles</option><option value="USD">Dólares</option><option value="EUR">Euros</option>
      </select>
      <input v-model="f.desde" type="date" class="input" @change="cargar" />
      <input v-model="f.hasta" type="date" class="input" @change="cargar" />
      <label class="fila" style="gap: 6px; font-size: 12.5px; cursor: pointer">
        <input type="checkbox" v-model="f.incluirOutliers" @change="cargar" /> Incluir atípicos
      </label>
    </div>

    <Cargando v-if="cargando" />

    <template v-else-if="h">
      <!--
        El contexto va PRIMERO y siempre: número de casos, umbral y moneda. Sin
        eso un promedio parece más preciso de lo que es, y el cap. 32.4 lo
        prohíbe expresamente.
      -->
      <div class="card" style="margin-bottom: 14px">
        <div class="card-cuerpo">
          <div class="defs">
            <div><div class="def-k">Casos comparables</div><div class="def-v mono" style="font-size:19px;font-weight:600">{{ h.contexto.casos }}</div></div>
            <div><div class="def-k">Umbral mínimo</div><div class="def-v mono">{{ h.contexto.umbral_minimo }}</div></div>
            <div><div class="def-k">Moneda</div><div class="def-v mono">{{ h.contexto.moneda }}</div></div>
            <div><div class="def-k">Atípicos</div><div class="def-v">{{ h.contexto.outliers_incluidos ? "Incluidos" : "Excluidos" }}</div></div>
          </div>
          <p class="muted" style="margin: 11px 0 0; font-size: 12px">{{ h.contexto.advertencia }}</p>
        </div>
      </div>

      <div class="bandeja" style="margin-bottom: 14px">
        <section class="bloque">
          <div class="bloque-head">
            <span class="bloque-n">{{ h.ultimo_costo ? monto(h.ultimo_costo.monto, h.ultimo_costo.moneda) : "—" }}</span>
            <span class="bloque-label">Último costo</span>
          </div>
          <div v-if="h.ultimo_costo" class="bloque-lista">
            <div class="bloque-fila"><span class="crecer">Proveedor</span><b>{{ h.ultimo_costo.proveedor ?? "—" }}</b></div>
            <div class="bloque-fila"><span class="crecer">Fecha</span><b class="mono">{{ fecha(h.ultimo_costo.fecha) }}</b></div>
            <div class="bloque-fila"><span class="crecer">OT</span><b class="mono">{{ h.ultimo_costo.ot }}</b></div>
          </div>
          <div v-else class="bloque-vacio">Sin casos comparables con estos filtros.</div>
        </section>

        <section class="bloque">
          <div class="bloque-head">
            <span class="bloque-n">{{ h.estadisticas.promedio ? monto(h.estadisticas.promedio, h.contexto.moneda) : "—" }}</span>
            <span class="bloque-label">Promedio</span>
          </div>
          <!-- Si la muestra no llega al umbral, se explica por qué no hay promedio. -->
          <div v-if="!h.estadisticas.promedio" class="bloque-vacio">{{ h.estadisticas.motivo_sin_promedio }}</div>
          <div v-else class="bloque-lista">
            <div class="bloque-fila"><span class="crecer">Mínimo</span><b class="mono">{{ monto(h.estadisticas.minimo, h.contexto.moneda) }}</b></div>
            <div class="bloque-fila"><span class="crecer">Mediana</span><b class="mono">{{ monto(h.estadisticas.mediana, h.contexto.moneda) }}</b></div>
            <div class="bloque-fila"><span class="crecer">Máximo</span><b class="mono">{{ monto(h.estadisticas.maximo, h.contexto.moneda) }}</b></div>
          </div>
        </section>
      </div>

      <div class="tbl-shell">
        <table class="stbl">
          <thead>
            <tr><th>Texto original</th><th>Normalizado</th><th>OT</th><th>Proveedor</th><th class="der">Cantidad</th><th class="der">Unitario</th><th class="der">Total</th><th>Fecha</th></tr>
          </thead>
          <tbody>
            <tr v-for="r in h.registros" :key="r.id">
              <!-- El texto original es inmutable: es la procedencia del dato. -->
              <td style="max-width: 300px" class="mono" :style="{ fontSize: '11.5px' }">{{ r.texto_original }}</td>
              <td class="muted">{{ r.descripcion_normalizada ?? "—" }}</td>
              <td class="mono">{{ r.ot }}</td>
              <td class="muted">{{ r.proveedor ?? "—" }}</td>
              <td class="der mono">{{ r.cantidad ? `${r.cantidad} ${r.unidad ?? ""}` : "—" }}</td>
              <td class="der mono">{{ r.costo_unitario ? monto(r.costo_unitario, r.moneda) : "—" }}</td>
              <td class="der mono" style="font-weight: 600">{{ monto(r.monto, r.moneda) }}</td>
              <td class="mono muted">
                {{ fecha(r.fecha) }}
                <span v-if="r.es_outlier" class="tag" style="margin-left: 4px">Atípico</span>
                <span v-if="r.emergencia" class="tag emergencia" style="margin-left: 4px">Emerg.</span>
              </td>
            </tr>
          </tbody>
        </table>
        <Vacio
          v-if="!h.registros.length"
          titulo="Sin registros comparables"
          texto="Los costos se alimentan de las cotizaciones seleccionadas y de las OT cerradas."
        />
      </div>
    </template>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import { catalogosApi, costosApi } from "../../shared/catalogos.api.js";
import { fecha, monto } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const f = reactive({ tipoTrabajoId: "", moneda: "PEN", desde: "", hasta: "", incluirOutliers: false });
const h = ref(null);
const tiposTrabajo = ref([]);
const cargando = ref(true);

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
  } catch { /* el filtro puede quedarse vacío sin romper la pantalla */ }
  await cargar();
});
</script>
