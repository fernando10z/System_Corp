<template>
  <div class="pila">
    <!--
      El reporte original del solicitante se muestra tal cual y SEPARADO del
      diagnóstico. El cap. 26.3 lo pide explícitamente: hay que poder distinguir
      lo que dijo quien reportó de lo que concluyó el técnico.
    -->
    <section v-if="t.origen?.solicitud" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile neutral"><MessageSquare :size="14" /></span>
          Lo que reportó el solicitante
        </span>
        <router-link v-if="t.origen.solicitud.id" class="btn sm plano" :to="`/solicitudes/${t.origen.solicitud.id}`">
          Ver la solicitud <ArrowRight :size="13" />
        </router-link>
      </div>
      <div class="card-cuerpo">
        <div class="fila fila-wrap" style="gap: 8px; margin-bottom: 12px">
          <span class="mono" style="font-weight: 600">{{ t.origen.solicitud.numero }}</span>
          <span v-if="t.origen.solicitud.prioridad_percibida" class="tag">
            Percibida: {{ etiqueta(t.origen.solicitud.prioridad_percibida) }}
          </span>
          <span v-if="t.origen.solicitud.impacto" class="tag">{{ t.origen.solicitud.impacto }}</span>
        </div>
        <p style="white-space: pre-wrap; margin: 0 0 16px; line-height: 1.6">
          {{ t.origen.solicitud.descripcion_original }}
        </p>
        <div class="defs">
          <div><div class="def-k">Lugar reportado</div><div class="def-v">{{ t.origen.solicitud.lugar }}</div></div>
          <div><div class="def-k">Solicitante</div><div class="def-v">{{ t.origen.solicitud.solicitante?.nombre ?? "—" }}</div></div>
          <div><div class="def-k">Enviada</div><div class="def-v mono">{{ fechaHora(t.origen.solicitud.fecha_envio) }}</div></div>
        </div>
      </div>
    </section>

    <section v-if="t.origen?.ot_padre" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile violet"><GitBranch :size="14" /></span>
          Por qué existe esta OT
        </span>
      </div>
      <div class="card-cuerpo">
        <div class="fila fila-wrap" style="gap: 8px; margin-bottom: 10px">
          <router-link class="tag derivada" :to="`/ot/${t.origen.ot_padre.id}`">
            Derivada de {{ t.origen.ot_padre.numero }}
          </router-link>
          <span v-if="t.origen.ot_padre.es_bloqueante" class="arbol-bloqueante">Bloquea el cierre del padre</span>
          <span v-else class="tag">No bloqueante</span>
        </div>
        <p style="margin: 0; line-height: 1.6">{{ t.origen.ot_padre.motivo_derivacion }}</p>
      </div>
    </section>

    <section v-if="vigente" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile blue"><Stethoscope :size="14" /></span>
          Diagnóstico vigente
        </span>
        <span class="version-n">v{{ vigente.version }}</span>
      </div>
      <div class="card-cuerpo">
        <div class="version-campo"><div class="version-campo-k">Diagnóstico</div>{{ vigente.diagnostico }}</div>
        <div class="version-campo"><div class="version-campo-k">Causa probable</div>{{ vigente.causa_probable }}</div>
        <div class="grid-2" style="gap: 10px 22px; margin-top: 10px">
          <div class="version-campo" style="margin: 0"><div class="version-campo-k">Alcance</div>{{ vigente.alcance }}</div>
          <div class="version-campo" style="margin: 0">
            <div class="version-campo-k">Trabajo a realizar</div>{{ vigente.trabajo_a_realizar }}
          </div>
        </div>
      </div>
    </section>

    <section v-if="trabajo" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile"><CheckCheck :size="14" /></span>
          Trabajo realizado
        </span>
        <span
          v-if="trabajo.revision?.resultado"
          class="estado-pill"
          :class="trabajo.revision.resultado === 'aprobado' ? 'ok' : 'warn'"
        >
          <span class="dot" />{{ etiqueta(trabajo.revision.resultado) }}
        </span>
      </div>
      <div class="card-cuerpo">
        <p style="white-space: pre-wrap; margin: 0 0 16px; line-height: 1.6">{{ trabajo.descripcion }}</p>
        <div class="defs">
          <div><div class="def-k">Resultado</div><div class="def-v">{{ trabajo.resultado ?? "—" }}</div></div>
          <div><div class="def-k">Término</div><div class="def-v mono">{{ fechaHora(trabajo.fecha_termino) }}</div></div>
          <div><div class="def-k">Declarado por</div><div class="def-v">{{ trabajo.declarado_por }}</div></div>
          <div>
            <div class="def-k">Conformidad del solicitante</div>
            <div class="def-v">{{ etiqueta(trabajo.conformidad_solicitante?.estado) }}</div>
          </div>
        </div>
        <div v-if="trabajo.revision?.observacion" class="sello-motivo">
          <b>Observación de la revisión</b>{{ trabajo.revision.observacion }}
        </div>
      </div>
    </section>

    <!-- El cierre con pendiente y su observación: la constancia que exige el cap. 31.2. -->
    <section v-if="cierre" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile"><Lock :size="14" /></span>
          Cierre
        </span>
      </div>
      <div class="card-cuerpo">
        <div class="defs">
          <div><div class="def-k">Fecha</div><div class="def-v mono">{{ fechaHora(cierre.fecha) }}</div></div>
          <div><div class="def-k">Cerrado por</div><div class="def-v">{{ cierre.cerrado_por }}</div></div>
          <div>
            <div class="def-k">Estado administrativo al cerrar</div>
            <div class="def-v">{{ etiqueta(cierre.estado_admin_al_cierre) }}</div>
          </div>
        </div>
        <div v-if="cierre.observacion_pendiente" class="sello-motivo">
          <b>Pendiente declarado al cerrar</b>{{ cierre.observacion_pendiente }}
        </div>
      </div>
    </section>

    <section v-if="(t.cierre?.reaperturas ?? []).length" class="card">
      <div class="card-head">
        <span class="card-titulo">
          <span class="icon-tile amber"><Unlock :size="14" /></span>
          Reaperturas
          <span class="head-meta">{{ t.cierre.reaperturas.length }}</span>
        </span>
      </div>
      <div class="card-cuerpo viajera">
        <article v-for="r in t.cierre.reaperturas" :key="r.id" class="sello alerta">
          <div class="sello-cab">
            <span class="sello-titulo">Reabierta</span>
            <span class="sello-meta">{{ fechaHora(r.fecha) }}</span>
            <span class="sello-meta">· {{ r.reabierta_por }}</span>
          </div>
          <div class="sello-motivo"><b>Motivo</b>{{ r.motivo_texto }}</div>
        </article>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { ArrowRight, CheckCheck, GitBranch, Lock, MessageSquare, Stethoscope, Unlock } from "lucide-vue-next";
import { etiqueta, fechaHora } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true } });

const vigente = computed(() => (props.t.diagnosticos ?? []).find((d) => d.vigente));
const trabajo = computed(() => (props.t.cierre?.trabajo_realizado ?? []).find((w) => w.vigente));
const cierre = computed(() => (props.t.cierre?.cierres ?? []).find((c) => c.vigente));
</script>
