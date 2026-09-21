<template>
  <div>
    <PageHeader
      eyebrow="Configuración"
      title="Organización"
      subtitle="Sucursal → Empresa/RUC → Área. Un área pertenece a una sola razón social: el mismo nombre bajo otra RUC es otra área."
    >
      <template #acciones>
        <button class="btn" @click="abrir('sucursal')"><Plus :size="14" /> Sucursal</button>
        <button class="btn" @click="abrir('empresa')"><Plus :size="14" /> Empresa</button>
        <button class="btn primary" :disabled="!hayEmpresas" @click="abrir('area')"><Plus :size="14" /> Área</button>
      </template>
    </PageHeader>

    <div class="stat-row tres">
      <Stat label="Sucursales" :valor="arbol.length" :icono="Building2" meta="Primer nivel" />
      <Stat label="Empresas / RUC" :valor="totales.empresas" :icono="Landmark" meta="Razones sociales activas e inactivas" />
      <Stat label="Áreas" :valor="totales.areas" :icono="LayoutGrid" meta="Donde nacen las solicitudes" />
    </div>

    <Cargando v-if="cargando" texto="Cargando la estructura…" />

    <div v-else-if="arbol.length" class="pila">
      <section v-for="s in arbol" :key="s.id" class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile"><Building2 :size="14" /></span>
            {{ s.nombre }}
            <span class="head-meta">{{ s.codigo }}</span>
          </span>
          <span class="estado-pill" :class="s.estado === 'activo' ? 'ok' : 'neutral'">
            <span class="dot" />{{ etiqueta(s.estado) }}
          </span>
        </div>

        <div class="card-cuerpo">
          <p v-if="!s.empresas.length" class="muted" style="margin: 0; font-size: 12.5px">
            Esta sucursal no tiene empresas asociadas todavía.
          </p>

          <div v-for="e in s.empresas" :key="e.id" class="empresa">
            <div class="empresa-cab">
              <Landmark :size="15" class="mas-muted" />
              <b>{{ e.razon_social }}</b>
              <span class="mono mas-muted">{{ e.ruc }}</span>
              <span v-if="e.estado !== 'activo'" class="tag">Inactiva</span>
              <span class="crecer" />
              <button v-if="e.estado === 'activo'" class="btn sm peligro" @click="inactivar(e)">Inactivar</button>
            </div>

            <div class="areas">
              <span v-for="a in e.areas" :key="a.id" class="tag">
                {{ a.nombre }} <b class="mono mas-muted">{{ a.codigo }}</b>
              </span>
              <span v-if="!e.areas.length" class="mas-muted" style="font-size: 12px">Sin áreas todavía</span>
            </div>
          </div>
        </div>
      </section>
    </div>

    <Vacio
      v-else
      :icono="Building2"
      titulo="Todavía no hay estructura"
      texto="Empiece creando una sucursal, luego la empresa con su RUC y por último las áreas. Sin esto no se pueden crear OT."
    >
      <button class="btn primary" @click="abrir('sucursal')">Crear la primera sucursal</button>
    </Vacio>

    <OrganizacionModal
      :abierto="!!modal"
      :tipo="modal || 'sucursal'"
      :arbol="arbol"
      @cerrar="modal = null"
      @guardado="alGuardar"
    />
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { Building2, Landmark, LayoutGrid, Plus } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Stat from "../../../shared/components/ui/Stat.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import OrganizacionModal from "../components/OrganizacionModal.vue";
import { organizacionApi } from "../../shared/catalogos.api.js";
import { etiqueta } from "../../../shared/utils/formato.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const arbol = ref([]);
const cargando = ref(true);
const modal = ref(null);

const totales = computed(() => {
  const empresas = arbol.value.flatMap((s) => s.empresas ?? []);
  return { empresas: empresas.length, areas: empresas.reduce((a, e) => a + (e.areas?.length ?? 0), 0) };
});

const hayEmpresas = computed(() => totales.value.empresas > 0);

function abrir(tipo) {
  modal.value = tipo;
}

function alGuardar() {
  modal.value = null;
  cargar();
}

async function cargar() {
  cargando.value = true;
  try {
    arbol.value = (await organizacionApi.arbol()).data ?? [];
  } catch (e) {
    await mostrarError(e, "No se pudo cargar la organización");
  } finally {
    cargando.value = false;
  }
}

/** Inactivar conserva la RUC y avisa de las OT abiertas que quedan (QA-24). */
async function inactivar(e) {
  const motivo = await notify.pedirTexto("Inactivar la empresa", {
    texto: "Se conserva en los datos y en el historial, pero no podrá usarse en OT nuevas.",
    confirmar: "Inactivar",
    minimo: 5,
  });
  if (!motivo) return;
  try {
    const r = await organizacionApi.inactivarEmpresa(e.id, motivo);
    if (r.data?.alerta) await notify.aviso("Empresa inactivada, con una advertencia", r.data.alerta);
    else await notify.exito("Empresa inactivada");
    await cargar();
  } catch (err) {
    await mostrarError(err);
  }
}

onMounted(cargar);
</script>

<style scoped>
.empresa { padding: 14px 0; border-bottom: 1px solid var(--line-soft); }
.empresa:first-child { padding-top: 0; }
.empresa:last-child { padding-bottom: 0; border-bottom: 0; }
.empresa-cab { display: flex; align-items: center; gap: 9px; flex-wrap: wrap; margin-bottom: 10px; }
.empresa-cab b { font-size: 13.5px; color: var(--ink); }
.areas { display: flex; flex-wrap: wrap; gap: 6px; padding-left: 24px; }
</style>
