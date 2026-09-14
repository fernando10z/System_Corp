<template>
  <div class="pila">
    <section class="card">
      <div class="card-head"><span class="card-titulo">Ejecución</span></div>
      <div class="card-cuerpo defs">
        <div><div class="def-k">Responsable</div><div class="def-v">{{ e?.responsable ?? "—" }}</div></div>
        <div><div class="def-k">Inicio real</div><div class="def-v mono">{{ fechaHora(e?.inicio_real) }}</div></div>
        <div><div class="def-k">Término real</div><div class="def-v mono">{{ fechaHora(e?.termino_real) }}</div></div>
        <div>
          <div class="def-k">Duración</div>
          <div class="def-v mono">{{ e?.duracion_dias ? e.duracion_dias + " días calendario" : "—" }}</div>
        </div>
        <div v-if="e?.inicio_sin_cotizacion">
          <div class="def-k">Inicio</div>
          <div class="def-v"><span class="tag espera">Sin cotización · regularizar</span></div>
        </div>
      </div>
    </section>

    <section class="card">
      <div class="card-head">
        <span class="card-titulo">Avances</span>
        <span class="muted" style="font-size: 12px">{{ (e?.avances ?? []).length }}</span>
      </div>
      <div class="card-cuerpo">
        <div v-if="!(e?.avances ?? []).length" class="muted" style="font-size: 12.5px">
          Todavía no hay avances registrados.
        </div>
        <div v-else class="viajera">
          <div v-for="a in [...(e.avances ?? [])].reverse()" :key="a.id" class="sello">
            <div class="sello-cab">
              <span class="sello-titulo">{{ a.autor }}</span>
              <span class="sello-meta">{{ fechaHora(a.fecha) }}</span>
              <span v-if="a.porcentaje !== null && a.porcentaje !== undefined" class="tag">{{ a.porcentaje }}%</span>
            </div>
            <div class="sello-cuerpo">{{ a.descripcion }}</div>
          </div>
        </div>
      </div>
    </section>

    <section v-if="(e?.incidencias ?? []).length" class="card">
      <div class="card-head"><span class="card-titulo">Incidencias</span></div>
      <div class="card-cuerpo viajera">
        <div v-for="i in e.incidencias" :key="i.id" class="sello alerta">
          <div class="sello-cab">
            <span class="sello-titulo">{{ i.tipo ?? "Incidencia" }}</span>
            <span class="sello-meta">{{ fechaHora(i.fecha) }} · {{ i.autor }}</span>
            <span v-if="i.resuelta" class="tag ok">Resuelta</span>
          </div>
          <div class="sello-cuerpo">{{ i.descripcion }}</div>
        </div>
      </div>
    </section>

    <!--
      Las pausas se conservan y se muestran aparte. El cap. 12.3 dice que la
      duración se cuenta en días calendario y las pausas se reportan por
      separado: NO se descuentan en silencio del tiempo total.
    -->
    <section v-if="(e?.pausas ?? []).length" class="card">
      <div class="card-head">
        <span class="card-titulo">Pausas</span>
        <span class="muted" style="font-size: 12px">Se reportan aparte; no se descuentan de la duración</span>
      </div>
      <div class="card-cuerpo">
        <table class="stbl">
          <thead><tr><th>Motivo</th><th>Desde</th><th>Hasta</th><th class="der">Horas</th></tr></thead>
          <tbody>
            <tr v-for="pa in e.pausas" :key="pa.id">
              <td>
                {{ pa.motivo }}
                <span v-if="pa.abierta" class="tag pausada" style="margin-left: 6px">Abierta</span>
              </td>
              <td class="mono muted">{{ fechaHora(pa.fecha_pausa) }}</td>
              <td class="mono muted">{{ pa.fecha_reanudacion ? fechaHora(pa.fecha_reanudacion) : "—" }}</td>
              <td class="der mono">{{ pa.horas ?? "—" }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { fechaHora } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true } });
const e = computed(() => props.t.ejecucion);
</script>
