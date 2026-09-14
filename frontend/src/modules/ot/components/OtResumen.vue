<template>
  <div class="pila">
    <!--
      El reporte original del solicitante se muestra tal cual y separado del
      diagnóstico. El cap. 26.3 lo pide explícitamente: hay que poder distinguir
      lo que dijo quien reportó de lo que concluyó el técnico.
    -->
    <section v-if="t.origen?.solicitud" class="card">
      <div class="card-head">
        <span class="card-titulo">Reporte original</span>
        <router-link
          v-if="t.origen.solicitud.id"
          class="btn sm plano"
          :to="`/solicitudes/${t.origen.solicitud.id}`"
        >
          Ver la solicitud
        </router-link>
      </div>
      <div class="card-cuerpo">
        <div class="fila" style="gap: 8px; margin-bottom: 8px">
          <span class="mono">{{ t.origen.solicitud.numero }}</span>
          <span v-if="t.origen.solicitud.prioridad_percibida" class="tag">
            Percibida: {{ etiqueta(t.origen.solicitud.prioridad_percibida) }}
          </span>
          <span v-if="t.origen.solicitud.impacto" class="tag">{{ t.origen.solicitud.impacto }}</span>
        </div>
        <p style="white-space: pre-wrap; margin: 0 0 10px">{{ t.origen.solicitud.descripcion_original }}</p>
        <div class="defs">
          <div><div class="def-k">Lugar reportado</div><div class="def-v">{{ t.origen.solicitud.lugar }}</div></div>
          <div><div class="def-k">Solicitante</div><div class="def-v">{{ t.origen.solicitud.solicitante?.nombre }}</div></div>
          <div><div class="def-k">Enviada</div><div class="def-v mono">{{ fechaHora(t.origen.solicitud.fecha_envio) }}</div></div>
        </div>
      </div>
    </section>

    <section v-if="t.origen?.ot_padre" class="card">
      <div class="card-head"><span class="card-titulo">Por qué existe esta OT</span></div>
      <div class="card-cuerpo">
        <div class="fila" style="gap: 8px; margin-bottom: 6px">
          <span class="tag derivada">Derivada de {{ t.origen.ot_padre.numero }}</span>
          <span v-if="t.origen.ot_padre.es_bloqueante" class="arbol-bloqueante">Bloquea el cierre del padre</span>
          <span v-else class="tag">No bloqueante</span>
        </div>
        <p style="margin: 0">{{ t.origen.ot_padre.motivo_derivacion }}</p>
      </div>
    </section>

    <section v-if="vigente" class="card">
      <div class="card-head"><span class="card-titulo">Diagnóstico vigente</span>
        <span class="version-n">v{{ vigente.version }}</span>
      </div>
      <div class="card-cuerpo">
        <div class="version-campo"><div class="version-campo-k">Diagnóstico</div>{{ vigente.diagnostico }}</div>
        <div class="version-campo"><div class="version-campo-k">Causa probable</div>{{ vigente.causa_probable }}</div>
        <div class="version-campo"><div class="version-campo-k">Alcance</div>{{ vigente.alcance }}</div>
        <div class="version-campo"><div class="version-campo-k">Trabajo a realizar</div>{{ vigente.trabajo_a_realizar }}</div>
      </div>
    </section>

    <section v-if="trabajo" class="card">
      <div class="card-head">
        <span class="card-titulo">Trabajo realizado</span>
        <span v-if="trabajo.revision?.resultado" class="tag" :class="trabajo.revision.resultado === 'aprobado' ? 'ok' : 'espera'">
          {{ etiqueta(trabajo.revision.resultado) }}
        </span>
      </div>
      <div class="card-cuerpo">
        <p style="white-space: pre-wrap; margin: 0 0 8px">{{ trabajo.descripcion }}</p>
        <div class="defs">
          <div><div class="def-k">Resultado</div><div class="def-v">{{ trabajo.resultado ?? "—" }}</div></div>
          <div><div class="def-k">Término</div><div class="def-v mono">{{ fechaHora(trabajo.fecha_termino) }}</div></div>
          <div><div class="def-k">Declarado por</div><div class="def-v">{{ trabajo.declarado_por }}</div></div>
          <div>
            <div class="def-k">Conformidad del solicitante</div>
            <div class="def-v">{{ etiqueta(trabajo.conformidad_solicitante?.estado) }}</div>
          </div>
        </div>
        <div v-if="trabajo.revision?.observacion" class="sello-motivo" style="margin-top: 10px">
          <b>Observación de la revisión</b>{{ trabajo.revision.observacion }}
        </div>
      </div>
    </section>

    <!-- El cierre con pendiente y su observación: la constancia que exige el cap. 31.2. -->
    <section v-if="cierre" class="card">
      <div class="card-head"><span class="card-titulo">Cierre</span></div>
      <div class="card-cuerpo">
        <div class="defs">
          <div><div class="def-k">Fecha</div><div class="def-v mono">{{ fechaHora(cierre.fecha) }}</div></div>
          <div><div class="def-k">Cerrado por</div><div class="def-v">{{ cierre.cerrado_por }}</div></div>
          <div>
            <div class="def-k">Estado administrativo al cerrar</div>
            <div class="def-v">{{ etiqueta(cierre.estado_admin_al_cierre) }}</div>
          </div>
        </div>
        <div v-if="cierre.observacion_pendiente" class="sello-motivo" style="margin-top: 10px">
          <b>Pendiente declarado al cerrar</b>{{ cierre.observacion_pendiente }}
        </div>
      </div>
    </section>

    <section v-if="(t.cierre?.reaperturas ?? []).length" class="card">
      <div class="card-head"><span class="card-titulo">Reaperturas</span></div>
      <div class="card-cuerpo">
        <div v-for="r in t.cierre.reaperturas" :key="r.id" class="version">
          <div class="version-cab">
            <span class="tag espera">Reabierta</span>
            <span class="mono muted">{{ fechaHora(r.fecha) }}</span>
            <span class="muted">· {{ r.reabierta_por }}</span>
          </div>
          <div class="version-cuerpo">{{ r.motivo_texto }}</div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { computed } from "vue";
import { etiqueta, fechaHora } from "../../../shared/utils/formato.js";

const props = defineProps({ t: { type: Object, required: true } });

const vigente = computed(() => (props.t.diagnosticos ?? []).find((d) => d.vigente));
const trabajo = computed(() => (props.t.cierre?.trabajo_realizado ?? []).find((w) => w.vigente));
const cierre = computed(() => (props.t.cierre?.cierres ?? []).find((c) => c.vigente));
</script>
