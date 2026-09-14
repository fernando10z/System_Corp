<template>
  <div>
    <PageHeader
      eyebrow="Entrada"
      title="Solicitudes de trabajo"
      subtitle="El reporte de quien detecta el problema. No se le pide que sepa qué lo causa."
    >
      <template #acciones>
        <router-link class="btn primary" to="/solicitudes/nueva"><Plus :size="14" /> Nueva solicitud</router-link>
      </template>
    </PageHeader>

    <div class="filtros">
      <input v-model.trim="f.buscar" class="input" placeholder="Buscar…" @keyup.enter="cargar(1)" />
      <select v-model="f.estado" class="select" @change="cargar(1)">
        <option value="">Todos los estados</option>
        <option v-for="e in ESTADOS" :key="e" :value="e">{{ etiqueta(e) }}</option>
      </select>
      <label class="fila" style="gap: 6px; font-size: 12.5px; cursor: pointer">
        <input type="checkbox" v-model="f.pendientesRevision" @change="cargar(1)" /> Sólo por revisar
      </label>
      <label class="fila" style="gap: 6px; font-size: 12.5px; cursor: pointer">
        <input type="checkbox" v-model="f.mias" @change="cargar(1)" /> Sólo las mías
      </label>
    </div>

    <div class="tbl-shell">
      <Cargando v-if="cargando" />
      <template v-else>
        <table class="stbl">
          <thead>
            <tr><th>Solicitud</th><th>Título</th><th>Estado</th><th>Área</th><th>Solicitante</th><th>Espera</th><th>OT</th></tr>
          </thead>
          <tbody>
            <tr v-for="s in filas" :key="s.id" class="fila-enlace" @click="$router.push(`/solicitudes/${s.id}`)">
              <td class="mono">{{ s.numero }}</td>
              <td style="max-width: 340px">
                <div style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap">{{ s.titulo }}</div>
                <div class="muted" style="font-size: 11px">{{ s.lugar }}</div>
              </td>
              <td>
                <span class="tag" :class="s.estado === 'convertida_en_ot' ? 'ok' : s.estado === 'rechazada' ? '' : 'espera'">
                  {{ etiqueta(s.estado) }}
                </span>
              </td>
              <td class="muted">{{ s.area ?? "—" }}</td>
              <td class="muted">{{ s.solicitante }}</td>
              <td>
                <!-- Las horas de espera sólo importan si nadie la ha revisado. -->
                <span v-if="s.horas_espera !== null && s.horas_espera !== undefined" class="mono"
                  :class="s.horas_espera > 24 ? 'p-alta' : 'muted'">
                  {{ s.horas_espera }} h
                </span>
                <span v-else class="muted">—</span>
              </td>
              <td class="mono">{{ s.ot?.numero ?? "—" }}</td>
            </tr>
          </tbody>
        </table>

        <Vacio
          v-if="!filas.length"
          titulo="Ninguna solicitud con esos filtros"
          texto="Cuando alguien reporte una necesidad, aparecerá aquí para su revisión."
        />
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { useRoute } from "vue-router";
import { Plus } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import { solicitudesApi } from "../api/solicitudes.api.js";
import { etiqueta } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const route = useRoute();
const ESTADOS = ["borrador", "enviada", "en_revision", "observada", "rechazada", "derivada", "duplicada", "convertida_en_ot"];

const f = reactive({
  buscar: "", estado: "",
  pendientesRevision: route.query.pendientesRevision === "true",
  mias: false,
});
const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await solicitudesApi.listar({
      ...f,
      pendientesRevision: f.pendientesRevision ? "true" : "",
      mias: f.mias ? "true" : "",
      page, pageSize: 25,
    });
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar las solicitudes");
  } finally {
    cargando.value = false;
  }
}

onMounted(() => cargar(1));
</script>
