<template>
  <div>
    <PageHeader
      eyebrow="Compras"
      title="Seguimiento administrativo"
      subtitle="SOLPED, orden de compra y liberación. Corre en paralelo al estado técnico: una OT cerrada puede seguir aquí."
    />

    <div class="filtros">
      <select v-model="f.estadoAdministrativo" class="select" @change="cargar(1)">
        <option value="">Todo estado administrativo</option>
        <option v-for="e in ADMIN" :key="e" :value="e">{{ etiqueta(e) }}</option>
      </select>
      <select v-model="f.estado" class="select" @change="cargar(1)">
        <option value="">Todo estado operativo</option>
        <option value="cerrada">Cerradas</option>
        <option value="en_trabajo">En trabajo</option>
        <option value="en_cotizacion">En cotización</option>
      </select>
    </div>

    <div class="tbl-shell">
      <Cargando v-if="cargando" />
      <template v-else>
        <table class="stbl">
          <thead>
            <tr><th>OT</th><th>Estado</th><th>Título</th><th class="der">Cotizado</th><th>Organización</th><th>Cierre</th></tr>
          </thead>
          <tbody>
            <tr v-for="o in filas" :key="o.id" class="fila-enlace" @click="$router.push(`/ot/${o.id}`)">
              <td class="mono">{{ o.numero_ot }}</td>
              <td><EstadoOt :estado="o.estado" :admin="o.estado_administrativo" /></td>
              <td style="max-width: 340px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">
                {{ o.titulo }}
              </td>
              <td class="der mono">{{ o.monto_cotizado ? monto(o.monto_cotizado, o.moneda) : "—" }}</td>
              <td class="muted" style="font-size: 11.5px">{{ o.empresa_ruc ?? "—" }}</td>
              <td class="mono muted">{{ o.fecha_cierre ? fecha(o.fecha_cierre) : "—" }}</td>
            </tr>
          </tbody>
        </table>
        <Vacio
          v-if="!filas.length"
          titulo="Nada pendiente por aquí"
          texto="Cuando una OT tenga SOLPED, OC o liberación pendiente, aparecerá en esta lista."
        />
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import PageHeader from "../../../layouts/PageHeader.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import { otApi } from "../../ot/api/ot.api.js";
import { etiqueta, fecha, monto } from "../../../shared/utils/formato.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const ADMIN = ["sin_solped","solped_pendiente","solped_creada","oc_pendiente","oc_registrada","liberacion_pendiente","liberacion_parcial","liberacion_total"];
const f = reactive({ estadoAdministrativo: "", estado: "" });
const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await otApi.listar({ ...f, page, pageSize: 25 });
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudo cargar el seguimiento");
  } finally {
    cargando.value = false;
  }
}
onMounted(() => cargar(1));
</script>
