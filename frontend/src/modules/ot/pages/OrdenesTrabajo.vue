<template>
  <div>
    <PageHeader
      eyebrow="Operación"
      title="Órdenes de trabajo"
      subtitle="Cada OT es una intervención técnica ejecutable. Si el alcance se divide, aparece como derivada."
    />

    <div class="filtros">
      <input v-model.trim="f.buscar" class="input" placeholder="Buscar por número o texto…" @keyup.enter="cargar(1)" />
      <select v-model="f.estado" class="select" @change="cargar(1)">
        <option value="">Todos los estados</option>
        <option v-for="e in ESTADOS" :key="e" :value="e">{{ etiqueta(e) }}</option>
      </select>
      <select v-model="f.prioridadTecnica" class="select" @change="cargar(1)">
        <option value="">Toda prioridad</option>
        <option v-for="p in ['critica','alta','media','baja']" :key="p" :value="p">{{ etiqueta(p) }}</option>
      </select>
      <select v-model="f.estadoAdministrativo" class="select" @change="cargar(1)">
        <option value="">Todo estado administrativo</option>
        <option v-for="e in ADMIN" :key="e" :value="e">{{ etiqueta(e) }}</option>
      </select>
      <label class="fila" style="gap: 6px; font-size: 12.5px; cursor: pointer">
        <input type="checkbox" v-model="f.soloEmergencias" @change="cargar(1)" /> Sólo emergencias
      </label>
      <label class="fila" style="gap: 6px; font-size: 12.5px; cursor: pointer">
        <!-- Ocultar derivadas ayuda a leer la carga real: una intervención por fila. -->
        <input type="checkbox" v-model="f.soloPrincipales" @change="cargar(1)" /> Ocultar derivadas
      </label>
      <button class="btn sm" @click="limpiar">Limpiar</button>
    </div>

    <div class="tbl-shell">
      <Cargando v-if="cargando" />
      <template v-else>
        <div class="tbl-scroll" style="max-height: calc(100vh - 270px)">
          <table class="stbl">
            <thead>
              <tr>
                <th>OT</th>
                <th>Estado</th>
                <th>Título</th>
                <th>Prioridad</th>
                <th>Organización</th>
                <th>Responsables</th>
                <th class="der">Cotizado</th>
                <th>Creada</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="o in filas" :key="o.id" class="fila-enlace" @click="$router.push(`/ot/${o.id}`)">
                <td class="nowrap">
                  <div class="fila" style="gap: 6px">
                    <!-- La sangría muestra el nivel de derivación de un vistazo. -->
                    <span v-if="o.nivel" :style="{ width: o.nivel * 11 + 'px' }" class="muted">↳</span>
                    <span class="mono" style="font-weight: 600">{{ o.numero_ot }}</span>
                  </div>
                  <div v-if="o.derivadas_activas" class="muted" style="font-size: 10.5px; padding-left: 2px">
                    {{ o.derivadas_activas }} derivada(s) activa(s)
                  </div>
                </td>
                <td><EstadoOt :estado="o.estado" :admin="o.estado_administrativo" /></td>
                <td style="max-width: 320px">
                  <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap">{{ o.titulo }}</div>
                  <div class="fila" style="gap: 5px; margin-top: 3px">
                    <span v-if="o.es_emergencia" class="tag emergencia">Emergencia</span>
                    <span v-if="o.condicion === 'pausada'" class="tag pausada">Pausada</span>
                    <span v-if="o.regularizacion_pendiente" class="tag espera">Regularizar</span>
                    <span v-if="o.veces_reabierta" class="tag">Reabierta ×{{ o.veces_reabierta }}</span>
                  </div>
                </td>
                <td><span class="prio" :class="'p-' + o.prioridad_tecnica">{{ etiqueta(o.prioridad_tecnica) }}</span></td>
                <td class="muted" style="font-size: 11.5px">
                  {{ o.area ?? "—" }}<br /><span style="opacity: 0.75">{{ o.empresa_ruc ?? "" }}</span>
                </td>
                <td class="muted" style="font-size: 11.5px">
                  {{ o.coordinador ?? "—" }}<br /><span style="opacity: 0.75">{{ o.ejecutor ?? "" }}</span>
                </td>
                <td class="der mono">{{ o.monto_cotizado ? monto(o.monto_cotizado, o.moneda) : "—" }}</td>
                <td class="muted mono nowrap">{{ desde(o.fecha_creacion) }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <Vacio
          v-if="!filas.length"
          titulo="Ninguna OT con esos filtros"
          texto="Pruebe a quitar algún filtro. Las OT nacen al aceptar una solicitud."
        >
          <router-link class="btn" to="/solicitudes?pendientesRevision=true">Ver solicitudes por revisar</router-link>
        </Vacio>

        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { useRoute } from "vue-router";
import PageHeader from "../../../layouts/PageHeader.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import { otApi } from "../api/ot.api.js";
import { desde, etiqueta, monto } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const route = useRoute();

const ESTADOS = ["creada", "en_diagnostico", "en_cotizacion", "en_trabajo", "trabajo_realizado", "cerrada", "cancelada"];
const ADMIN = [
  "sin_solped", "solped_pendiente", "solped_creada", "oc_pendiente", "oc_registrada",
  "liberacion_pendiente", "liberacion_parcial", "liberacion_total", "administracion_completa",
];

const f = reactive({
  buscar: "", estado: "", prioridadTecnica: "", estadoAdministrativo: "",
  soloEmergencias: route.query.soloEmergencias === "true",
  soloPrincipales: false,
});

const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await otApi.listar({
      ...f,
      soloEmergencias: f.soloEmergencias ? "true" : "",
      soloPrincipales: f.soloPrincipales ? "true" : "",
      page,
      pageSize: 25,
    });
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar las órdenes de trabajo");
  } finally {
    cargando.value = false;
  }
}

function limpiar() {
  Object.assign(f, {
    buscar: "", estado: "", prioridadTecnica: "", estadoAdministrativo: "",
    soloEmergencias: false, soloPrincipales: false,
  });
  cargar(1);
}

onMounted(() => cargar(1));
</script>
