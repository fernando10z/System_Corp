<template>
  <div>
    <PageHeader
      eyebrow="Bandeja"
      :title="saludo"
      subtitle="Lo que espera una decisión suya, ordenado por lo que se puede hacer con ello."
    >
      <template #acciones>
        <router-link class="btn" to="/solicitudes/nueva">
          <Plus :size="14" /> Nueva solicitud
        </router-link>
      </template>
    </PageHeader>

    <Cargando v-if="cargando" texto="Reuniendo su bandeja…" />

    <template v-else-if="esCoordinador && tablero">
      <div class="bandeja">
        <!-- Bloque 1 · lo más urgente: solicitudes sin primera revisión. -->
        <Bloque
          :total="tablero.solicitudes_nuevas?.total ?? 0"
          label="Solicitudes por revisar"
          accion="Tomar y decidir"
          :tono="tablero.solicitudes_nuevas?.total ? 'espera' : 'ok'"
          :items="tablero.solicitudes_nuevas?.items ?? []"
          vacio="Sin solicitudes esperando."
          @abrir="(s) => $router.push(`/solicitudes/${s.id}`)"
        >
          <template #fila="{ item }">
            <span class="mono">{{ item.numero }}</span>
            <span class="crecer" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ item.titulo }}</span>
            <span v-if="item.prioridad_percibida" class="prio" :class="'p-' + item.prioridad_percibida">
              {{ etiqueta(item.prioridad_percibida) }}
            </span>
            <span class="muted mono nowrap">{{ item.horas_espera }} h</span>
          </template>
        </Bloque>

        <!-- Bloque 2 · sin diagnóstico vigente: no pueden avanzar a cotización. -->
        <Bloque
          :total="tablero.sin_diagnostico?.total ?? 0"
          label="OT sin diagnóstico"
          accion="Completar o asignar técnico"
          :tono="tablero.sin_diagnostico?.total ? 'espera' : 'ok'"
          :items="tablero.sin_diagnostico?.items ?? []"
          vacio="Todas tienen diagnóstico vigente."
          @abrir="(o) => $router.push(`/ot/${o.id}`)"
        >
          <template #fila="{ item }">
            <span class="mono">{{ item.numero_ot }}</span>
            <span v-if="item.es_emergencia" class="tag emergencia">Emergencia</span>
            <span class="crecer"></span>
            <span class="prio" :class="'p-' + item.prioridad">{{ etiqueta(item.prioridad) }}</span>
            <span class="muted mono nowrap">{{ item.dias_abierta }} d</span>
          </template>
        </Bloque>

        <!-- Bloque 3 · trabajo declarado esperando revisión del coordinador. -->
        <Bloque
          :total="tablero.revision_final?.total ?? 0"
          label="Trabajo por revisar"
          accion="Aprobar o devolver"
          :tono="tablero.revision_final?.total ? 'espera' : 'ok'"
          :items="tablero.revision_final?.items ?? []"
          vacio="Nada pendiente de revisión."
          @abrir="(o) => $router.push(`/ot/${o.id}`)"
        >
          <template #fila="{ item }">
            <span class="mono">{{ item.numero_ot }}</span>
            <span class="crecer muted" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
              {{ item.declarado_por }}
            </span>
            <span class="muted mono nowrap">{{ desde(item.declarado_at) }}</span>
          </template>
        </Bloque>
      </div>

      <div class="bandeja" style="margin-top: 14px">
        <!-- Estos tres son informativos: no hay una acción única que ofrecer. -->
        <section class="bloque">
          <div class="bloque-head">
            <span class="bloque-n">{{ tablero.ejecucion?.en_trabajo ?? 0 }}</span>
            <span class="bloque-label">En trabajo</span>
          </div>
          <div class="bloque-lista">
            <div class="bloque-fila" @click="$router.push('/ot?condicion=pausada')">
              <span class="crecer">Pausadas</span>
              <b class="mono">{{ tablero.ejecucion?.pausadas ?? 0 }}</b>
            </div>
            <div class="bloque-fila" @click="$router.push('/ot?soloEmergencias=true')">
              <span class="crecer">Emergencias activas</span>
              <b class="mono" :style="tablero.ejecucion?.emergencias_activas ? 'color:var(--danger)' : ''">
                {{ tablero.ejecucion?.emergencias_activas ?? 0 }}
              </b>
            </div>
            <div class="bloque-fila">
              <span class="crecer">Sin avance en 7 días</span>
              <b class="mono">{{ tablero.ejecucion?.sin_avance_7d ?? 0 }}</b>
            </div>
            <!--
              La regularización pendiente es la deuda que deja una emergencia.
              El cap. 3 es explícito: la emergencia cambia el orden administrativo,
              no elimina la obligación de regularizar.
            -->
            <div class="bloque-fila">
              <span class="crecer">Regularización pendiente</span>
              <b class="mono" :style="tablero.ejecucion?.regularizacion_pendiente ? 'color:var(--accion)' : ''">
                {{ tablero.ejecucion?.regularizacion_pendiente ?? 0 }}
              </b>
            </div>
          </div>
        </section>

        <Bloque
          :total="tablero.administracion_pendiente?.total ?? 0"
          label="Cerradas con pendiente administrativo"
          accion="Registrar sin reabrir"
          :tono="tablero.administracion_pendiente?.total ? '' : 'ok'"
          :items="pendientesAdmin"
          vacio="Administración al día."
          @abrir="() => $router.push('/administrativo')"
        >
          <template #fila="{ item }">
            <span class="crecer">{{ etiqueta(item.k) }}</span>
            <b class="mono">{{ item.n }}</b>
          </template>
        </Bloque>

        <!-- Jerarquías bloqueadas: un padre no cierra con una hija bloqueante viva. -->
        <Bloque
          :total="(tablero.bloqueos_cierre ?? []).length"
          label="Cierres bloqueados por derivadas"
          accion="Resolver las hijas"
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
      </div>
    </template>

    <!-- Vista del solicitante: sus casos, sin nada interno (QA-18). -->
    <template v-else-if="misSolicitudes">
      <div class="bandeja" style="margin-bottom: 14px">
        <section v-for="(n, k) in misSolicitudes.resumen ?? {}" :key="k" class="bloque">
          <div class="bloque-head">
            <span class="bloque-n">{{ n }}</span>
            <span class="bloque-label">{{ etiqueta(k) }}</span>
          </div>
        </section>
      </div>

      <div class="tbl-shell">
        <table class="stbl">
          <thead>
            <tr><th>Solicitud</th><th>Título</th><th>Estado</th><th>OT</th><th>Enviada</th></tr>
          </thead>
          <tbody>
            <tr
              v-for="s in misSolicitudes.solicitudes ?? []"
              :key="s.id" class="fila-enlace"
              @click="$router.push(`/solicitudes/${s.id}`)"
            >
              <td class="mono">{{ s.numero }}</td>
              <td>{{ s.titulo }}</td>
              <td><span class="tag">{{ etiqueta(s.estado) }}</span></td>
              <td class="mono">{{ s.ot?.numero ?? "—" }}</td>
              <td class="muted mono">{{ desde(s.fecha) }}</td>
            </tr>
          </tbody>
        </table>
        <Vacio
          v-if="!(misSolicitudes.solicitudes ?? []).length"
          titulo="Todavía no ha reportado nada"
          texto="Cuando algo no funcione, cuéntelo aquí. No hace falta que sepa qué lo causa."
        >
          <router-link class="btn primary" to="/solicitudes/nueva">Reportar una necesidad</router-link>
        </Vacio>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { Plus } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Bloque from "../../../shared/components/ui/Bloque.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import { dashboardApi } from "../../shared/catalogos.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { desde, etiqueta } from "../../../shared/utils/formato.js";
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

const pendientesAdmin = computed(() =>
  Object.entries(tablero.value?.administracion_pendiente?.por_estado ?? {}).map(([k, n]) => ({ k, n, id: k })),
);

onMounted(async () => {
  try {
    // Se pide el tablero que corresponde al rol; no se piden los dos "por si acaso".
    if (esCoordinador.value) {
      tablero.value = (await dashboardApi.coordinador()).data;
    } else {
      misSolicitudes.value = (await dashboardApi.solicitante()).data;
    }
  } catch (e) {
    await mostrarError(e, "No se pudo cargar su bandeja");
  } finally {
    cargando.value = false;
  }
});
</script>
