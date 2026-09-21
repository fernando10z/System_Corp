<template>
  <div class="pila">
    <div class="stat-row">
      <Stat label="Responsable" :valor="e?.responsable ?? '—'" pequeno :icono="User" meta="Quien ejecuta el trabajo" />
      <Stat
        label="Duración"
        :valor="e?.duracion_dias ? dias(e.duracion_dias) : '—'"
        pequeno
        :icono="CalendarDays"
        meta="Días calendario; las pausas no se descuentan"
      />
      <Stat label="Avances" :valor="(e?.avances ?? []).length" :icono="ListChecks" meta="Registrados por el ejecutor" />
      <Stat
        label="Pausas"
        :valor="(e?.pausas ?? []).length"
        :tono="pausaAbierta ? 'espera' : ''"
        :icono="PauseCircle"
        :color="pausaAbierta ? 'amber' : ''"
        :meta="pausaAbierta ? 'Hay una pausa abierta' : 'Se reportan aparte'"
      />
    </div>

    <div v-if="e?.inicio_sin_cotizacion" class="aviso espera">
      <TriangleAlert :size="15" />
      <div>
        <b>El trabajo empezó sin cotización.</b>
        Es la excepción que permite una emergencia; la regularización sigue pendiente hasta que se registre.
      </div>
    </div>

    <section class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile neutral"><Clock :size="14" /></span>
          Fechas reales
        </span>
      </div>
      <div class="card-cuerpo defs">
        <div><div class="def-k">Inicio real</div><div class="def-v mono">{{ fechaHora(e?.inicio_real) }}</div></div>
        <div><div class="def-k">Término real</div><div class="def-v mono">{{ fechaHora(e?.termino_real) }}</div></div>
        <div>
          <div class="def-k">Horas en pausa</div>
          <div class="def-v mono">{{ horasPausa !== null ? horasPausa + " h" : "—" }}</div>
        </div>
      </div>
    </section>

    <section class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile"><ListChecks :size="14" /></span>
          Avances
          <span class="head-meta">{{ (e?.avances ?? []).length }}</span>
        </span>
      </div>
      <div class="card-cuerpo">
        <p v-if="!(e?.avances ?? []).length" class="muted" style="margin: 0; font-size: 12.5px">
          Todavía no hay avances registrados.
        </p>
        <div v-else class="viajera">
          <article v-for="a in avances" :key="a.id" class="sello humano">
            <div class="sello-cab">
              <span class="sello-titulo">{{ a.autor }}</span>
              <span class="sello-meta">{{ fechaHora(a.fecha) }}</span>
              <span v-if="a.porcentaje !== null && a.porcentaje !== undefined" class="tag">{{ a.porcentaje }} %</span>
            </div>
            <div class="sello-cuerpo">{{ a.descripcion }}</div>
          </article>
        </div>
      </div>
    </section>

    <section v-if="(e?.incidencias ?? []).length" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile red"><TriangleAlert :size="14" /></span>
          Incidencias
          <span class="head-meta">{{ e.incidencias.length }}</span>
        </span>
      </div>
      <div class="card-cuerpo viajera">
        <article v-for="i in e.incidencias" :key="i.id" class="sello alerta">
          <div class="sello-cab">
            <span class="sello-titulo">{{ i.tipo ?? "Incidencia" }}</span>
            <span class="sello-meta">{{ fechaHora(i.fecha) }} · {{ i.autor }}</span>
            <span v-if="i.resuelta" class="tag ok">Resuelta</span>
          </div>
          <div class="sello-cuerpo">{{ i.descripcion }}</div>
        </article>
      </div>
    </section>

    <!--
      Las pausas se conservan y se muestran aparte. El cap. 12.3 dice que la
      duración se cuenta en días calendario y las pausas se reportan por
      separado: NO se descuentan en silencio del tiempo total.
    -->
    <section v-if="(e?.pausas ?? []).length" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile amber"><PauseCircle :size="14" /></span>
          Pausas
          <span class="head-meta">{{ e.pausas.length }}</span>
        </span>
        <span class="muted" style="font-size: 12px">Se reportan aparte; no se descuentan de la duración</span>
      </div>
      <div class="tabla-wrap">
        <table>
          <thead>
            <tr><th>Motivo</th><th>Desde</th><th>Hasta</th><th class="num">Horas</th></tr>
          </thead>
          <tbody>
            <tr v-for="pa in e.pausas" :key="pa.id">
              <td>
                {{ pa.motivo }}
                <span v-if="pa.abierta" class="tag pausada" style="margin-left: 6px">Abierta</span>
              </td>
              <td class="mono muted nowrap">{{ fechaHora(pa.fecha_pausa) }}</td>
              <td class="mono muted nowrap">{{ pa.fecha_reanudacion ? fechaHora(pa.fecha_reanudacion) : "—" }}</td>
              <td class="num mono">{{ pa.horas ?? "—" }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { CalendarDays, Clock, ListChecks, PauseCircle, TriangleAlert, User } from "lucide-vue-next";
import Stat from "../../../shared/components/ui/Stat.vue";
import { dias, fechaHora } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true } });

const e = computed(() => props.t.ejecucion);

// Del avance más reciente al más antiguo: lo último es lo que se viene a ver.
const avances = computed(() => [...(e.value?.avances ?? [])].reverse());

const pausaAbierta = computed(() => (e.value?.pausas ?? []).some((p) => p.abierta));

const horasPausa = computed(() => {
  const ps = e.value?.pausas ?? [];
  if (!ps.length) return null;
  const total = ps.reduce((a, p) => a + Number(p.horas ?? 0), 0);
  return Math.round(total * 10) / 10;
});
</script>
