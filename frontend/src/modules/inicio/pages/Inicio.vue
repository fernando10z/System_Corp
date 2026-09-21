<template>
  <div>
    <PageHeader
      :eyebrow="esCoordinador ? 'Bandeja del coordinador' : 'Mis reportes'"
      :title="saludo"
      :subtitle="
        esCoordinador
          ? 'Lo que espera una decisión suya, ordenado por lo que se puede hacer con ello.'
          : 'El estado de lo que usted ha reportado. Sin jerga técnica y sin datos internos.'
      "
    >
      <template #acciones>
        <router-link class="btn primary" to="/solicitudes?nueva=1"><Plus :size="14" /> Nueva solicitud</router-link>
      </template>
    </PageHeader>

    <Cargando v-if="cargando" texto="Reuniendo su bandeja…" />

    <!-- ── vista del coordinador ──────────────────────────────────────── -->
    <template v-else-if="esCoordinador && tablero">
      <!--
        La franja de cifras resume la carga. El ámbar sólo aparece cuando el
        número es mayor que cero: un "0 pendientes" en ámbar entrenaría al ojo
        a ignorar el color justo donde importa.
      -->
      <div class="stat-row">
        <Stat
          label="Esperan su decisión"
          :valor="totalEnEspera"
          :tono="totalEnEspera ? 'espera' : ''"
          :icono="Hourglass"
          :color="totalEnEspera ? 'amber' : ''"
          :meta="totalEnEspera ? 'Solicitudes, diagnósticos y revisiones' : 'Bandeja al día'"
        />
        <Stat
          label="En trabajo"
          :valor="tablero.ejecucion?.en_trabajo ?? 0"
          :icono="Wrench"
          :meta="`${tablero.ejecucion?.pausadas ?? 0} pausada(s)`"
          to="/ot?estado=en_trabajo"
        />
        <Stat
          label="Emergencias activas"
          :valor="tablero.ejecucion?.emergencias_activas ?? 0"
          :tono="tablero.ejecucion?.emergencias_activas ? 'urgente' : ''"
          :icono="Siren"
          :color="tablero.ejecucion?.emergencias_activas ? 'red' : ''"
          :meta="`${tablero.ejecucion?.regularizacion_pendiente ?? 0} sin regularizar`"
          to="/ot?soloEmergencias=true"
        />
        <Stat
          label="Administración pendiente"
          :valor="tablero.administracion_pendiente?.total ?? 0"
          :tono="tablero.administracion_pendiente?.total ? 'espera' : ''"
          :icono="Truck"
          :color="tablero.administracion_pendiente?.total ? 'amber' : ''"
          meta="SOLPED, OC o liberación"
          to="/administrativo"
        />
      </div>

      <!-- Los tres bloques accionables: cada uno habilita una decisión. -->
      <div class="bandeja">
        <Bloque
          :total="tablero.solicitudes_nuevas?.total ?? 0"
          label="Solicitudes por revisar"
          accion="Tomar y decidir"
          :icono="Inbox"
          :tono="tablero.solicitudes_nuevas?.total ? 'espera' : 'ok'"
          :items="tablero.solicitudes_nuevas?.items ?? []"
          vacio="Sin solicitudes esperando."
          @abrir="(s) => $router.push(`/solicitudes/${s.id}`)"
        >
          <template #fila="{ item }">
            <span class="mono">{{ item.numero }}</span>
            <span class="crecer truncar">{{ item.titulo }}</span>
            <span v-if="item.prioridad_percibida" class="prio" :class="'p-' + item.prioridad_percibida">
              {{ etiqueta(item.prioridad_percibida) }}
            </span>
            <span class="mono nowrap" :class="claseEspera(item.horas_espera)">{{ item.horas_espera }} h</span>
          </template>
        </Bloque>

        <Bloque
          :total="tablero.sin_diagnostico?.total ?? 0"
          label="OT sin diagnóstico vigente"
          accion="Completar o asignar"
          :icono="Stethoscope"
          :tono="tablero.sin_diagnostico?.total ? 'espera' : 'ok'"
          :items="tablero.sin_diagnostico?.items ?? []"
          vacio="Todas tienen diagnóstico vigente."
          @abrir="(o) => $router.push(`/ot/${o.id}`)"
        >
          <template #fila="{ item }">
            <span class="mono">{{ item.numero_ot }}</span>
            <span v-if="item.es_emergencia" class="tag emergencia">Emergencia</span>
            <span class="crecer" />
            <span class="prio" :class="'p-' + item.prioridad">{{ etiqueta(item.prioridad) }}</span>
            <span class="muted mono nowrap">{{ item.dias_abierta }} d</span>
          </template>
        </Bloque>

        <Bloque
          :total="tablero.revision_final?.total ?? 0"
          label="Trabajo por revisar"
          accion="Aprobar o devolver"
          :icono="ClipboardCheck"
          :tono="tablero.revision_final?.total ? 'espera' : 'ok'"
          :items="tablero.revision_final?.items ?? []"
          vacio="Nada pendiente de revisión."
          @abrir="(o) => $router.push(`/ot/${o.id}`)"
        >
          <template #fila="{ item }">
            <span class="mono">{{ item.numero_ot }}</span>
            <span class="crecer truncar muted">{{ item.declarado_por }}</span>
            <span class="muted mono nowrap">{{ desde(item.declarado_at) }}</span>
          </template>
        </Bloque>
      </div>

      <div class="grid-2" style="margin-top: var(--gap-paneles)">
        <!-- Jerarquías bloqueadas: un padre no cierra con una hija bloqueante viva. -->
        <Bloque
          :total="(tablero.bloqueos_cierre ?? []).length"
          label="Cierres bloqueados por derivadas"
          accion="Resolver las hijas"
          :icono="GitBranch"
          :tono="(tablero.bloqueos_cierre ?? []).length ? 'urgente' : 'ok'"
          :items="tablero.bloqueos_cierre ?? []"
          vacio="Ninguna jerarquía bloqueada."
          @abrir="(o) => $router.push(`/ot/${o.id}`)"
        >
          <template #fila="{ item }">
            <span class="mono crecer">{{ item.numero_ot }}</span>
            <span class="arbol-bloqueante">{{ item.derivadas_bloqueantes }} bloqueante(s)</span>
          </template>
        </Bloque>

        <section class="panel">
          <div class="panel-head">
            <h3>Estado de la ejecución</h3>
            <router-link class="link-mini" to="/ot">Ver todas</router-link>
          </div>
          <div class="util-bar">
            <div v-for="f in filasEjecucion" :key="f.k" class="util-bar-row">
              <span class="label">{{ f.label }}</span>
              <span class="pct" :style="f.n && f.alerta ? 'color: var(--amber-ink); font-weight: 700' : ''">
                {{ f.n }}
              </span>
              <div class="track">
                <div class="fill" :style="{ width: pct(f.n) + '%', background: f.n && f.alerta ? 'var(--amber)' : 'var(--emerald)' }" />
              </div>
            </div>
          </div>
          <!--
            La regularización pendiente es la deuda que deja una emergencia. El
            cap. 3 es explícito: la emergencia cambia el orden administrativo,
            no elimina la obligación de regularizar.
          -->
          <div v-if="tablero.ejecucion?.regularizacion_pendiente" class="aviso espera">
            <TriangleAlert :size="15" />
            <div>
              <b>{{ tablero.ejecucion.regularizacion_pendiente }} emergencia(s) sin regularizar.</b>
              Empezaron sin cotización. La obligación de regularizar sigue viva.
            </div>
          </div>
        </section>
      </div>
    </template>

    <!-- ── vista del solicitante (QA-18: nada interno) ────────────────── -->
    <template v-else-if="misSolicitudes">
      <div v-if="Object.keys(misSolicitudes.resumen ?? {}).length" class="stat-row">
        <Stat
          v-for="(n, k) in misSolicitudes.resumen"
          :key="k"
          :label="etiqueta(k)"
          :valor="n"
          pequeno
        />
      </div>

      <ModuloPanel titulo="Mis solicitudes" :icono="Inbox" :conteo="(misSolicitudes.solicitudes ?? []).length" a-sangre>
        <template #acciones>
          <router-link class="btn primary sm" to="/solicitudes?nueva=1"><Plus :size="13" /> Nueva</router-link>
        </template>

        <div v-if="(misSolicitudes.solicitudes ?? []).length" class="tabla-wrap">
          <table>
            <thead>
              <tr><th>Solicitud</th><th>Título</th><th>Estado</th><th>OT generada</th><th>Enviada</th></tr>
            </thead>
            <tbody>
              <tr
                v-for="s in misSolicitudes.solicitudes"
                :key="s.id"
                class="clickable"
                @click="$router.push(`/solicitudes/${s.id}`)"
              >
                <td class="mono">{{ s.numero }}</td>
                <td class="truncar" style="max-width: 360px">{{ s.titulo }}</td>
                <td><span class="estado-pill" :class="tonoSolicitud(s.estado)"><span class="dot" />{{ etiqueta(s.estado) }}</span></td>
                <td class="mono">{{ s.ot?.numero ?? "—" }}</td>
                <td class="muted mono">{{ desde(s.fecha) }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <Vacio
          v-else
          :icono="Inbox"
          titulo="Todavía no ha reportado nada"
          texto="Cuando algo no funcione, cuéntelo aquí. No hace falta que sepa qué lo causa ni de qué equipo se trata."
        >
          <router-link class="btn primary" to="/solicitudes?nueva=1">Reportar una necesidad</router-link>
        </Vacio>
      </ModuloPanel>
    </template>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import {
  ClipboardCheck, GitBranch, Hourglass, Inbox, Plus, Siren, Stethoscope, TriangleAlert, Truck, Wrench,
} from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Bloque from "../../../shared/components/ui/Bloque.vue";
import Stat from "../../../shared/components/ui/Stat.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import ModuloPanel from "../../../shared/components/ui/ModuloPanel.vue";
import { dashboardApi } from "../../shared/catalogos.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { claseEspera, desde, etiqueta, tonoSolicitud } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const { usuario, puede } = useAuth();

const cargando = ref(true);
const tablero = ref(null);
const misSolicitudes = ref(null);

const esCoordinador = computed(() => puede("solicitudes:decidir") || puede("ot:cerrar"));

const saludo = computed(() => {
  const nombre = usuario.value?.nombres ?? usuario.value?.nombre?.split(" ")[0] ?? "";
  const h = new Date().getHours();
  const momento = h < 12 ? "Buenos días" : h < 19 ? "Buenas tardes" : "Buenas noches";
  return nombre ? `${momento}, ${nombre}` : momento;
});

/** Lo que de verdad espera una decisión del coordinador, en un solo número. */
const totalEnEspera = computed(() => {
  const t = tablero.value;
  if (!t) return 0;
  return (t.solicitudes_nuevas?.total ?? 0) + (t.sin_diagnostico?.total ?? 0) + (t.revision_final?.total ?? 0);
});

const filasEjecucion = computed(() => {
  const e = tablero.value?.ejecucion ?? {};
  return [
    { k: "trabajo", label: "En trabajo", n: e.en_trabajo ?? 0, alerta: false },
    { k: "pausadas", label: "Pausadas", n: e.pausadas ?? 0, alerta: true },
    { k: "quietas", label: "Sin avance en 7 días", n: e.sin_avance_7d ?? 0, alerta: true },
    { k: "regular", label: "Regularización pendiente", n: e.regularizacion_pendiente ?? 0, alerta: true },
  ];
});

/** La barra se escala contra el mayor de la lista: comparar entre sí es el punto. */
function pct(n) {
  const max = Math.max(...filasEjecucion.value.map((f) => f.n), 1);
  return Math.round((Number(n || 0) / max) * 100);
}

onMounted(async () => {
  try {
    // Se pide el tablero que corresponde al rol; no se piden los dos "por si acaso".
    if (esCoordinador.value) tablero.value = (await dashboardApi.coordinador()).data;
    else misSolicitudes.value = (await dashboardApi.solicitante()).data;
  } catch (e) {
    await mostrarError(e, "No se pudo cargar su bandeja");
  } finally {
    cargando.value = false;
  }
});
</script>
