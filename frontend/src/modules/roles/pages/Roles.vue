<template>
  <div>
    <PageHeader
      eyebrow="Configuración"
      title="Roles y permisos"
      subtitle="La matriz de base viene del documento. Es un punto de partida funcional, no la política de seguridad final de su organización."
    />

    <div class="aviso info" style="margin-bottom: var(--gap-paneles)">
      <ShieldCheck :size="15" />
      <div>
        <b>Los permisos sólo deciden qué se muestra.</b>
        Quien autoriza de verdad es el stored procedure: aunque alguien fuerce un botón, la operación se rechaza abajo.
      </div>
    </div>

    <Cargando v-if="cargando" texto="Cargando la matriz…" />

    <div v-else class="roles-grid">
      <article v-for="r in roles" :key="r.id" class="card rol">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile"><ShieldCheck :size="14" /></span>
            {{ r.nombre }}
            <span class="head-meta">{{ r.codigo }}</span>
          </span>
          <button class="btn sm" @click="editar(r)"><Pencil :size="13" /> Editar</button>
        </div>

        <div class="card-cuerpo">
          <p v-if="r.descripcion" class="muted" style="margin: 0 0 14px; font-size: 12.5px; line-height: 1.55">
            {{ r.descripcion }}
          </p>

          <div class="fila" style="gap: 18px; margin-bottom: 14px">
            <div>
              <div class="def-k">Usuarios</div>
              <div class="mono" style="font-size: 19px; font-weight: 600">{{ r.usuarios }}</div>
            </div>
            <div class="crecer">
              <div class="def-k">Permisos</div>
              <div class="fila" style="gap: 10px">
                <span class="mono" style="font-size: 19px; font-weight: 600">{{ r.permisos.length }}</span>
                <div class="progress-bar crecer">
                  <div class="fill" :style="{ width: cobertura(r) + '%' }" />
                </div>
                <span class="mas-muted mono" style="font-size: 11px">{{ cobertura(r) }} %</span>
              </div>
            </div>
          </div>

          <!-- Los módulos, no los 44 códigos: la lista plana no se lee. -->
          <div class="fila fila-wrap" style="gap: 5px">
            <span v-for="(n, m) in modulosDe(r)" :key="m" class="tag">
              {{ m }} <b class="mono" style="color: var(--ink-3)">{{ n }}</b>
            </span>
            <span v-if="!r.permisos.length" class="mas-muted" style="font-size: 12px">Sin permisos asignados</span>
          </div>
        </div>
      </article>
    </div>

    <PermisosDrawer
      :abierto="!!rolEditando"
      :rol="rolEditando"
      :permisos="permisos"
      @cerrar="rolEditando = null"
      @guardado="alGuardar"
    />
  </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { Pencil, ShieldCheck } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import PermisosDrawer from "../components/PermisosDrawer.vue";
import { rolesApi } from "../../shared/catalogos.api.js";
import { mostrarError } from "../../../shared/composables/useNotify.js";

const roles = ref([]);
const permisos = ref([]);
const cargando = ref(true);
const rolEditando = ref(null);

/** Qué porcentaje del total de permisos cubre este rol. */
function cobertura(r) {
  if (!permisos.value.length) return 0;
  return Math.round((r.permisos.length / permisos.value.length) * 100);
}

/** Cuántos permisos tiene el rol en cada módulo. */
function modulosDe(r) {
  const indice = Object.fromEntries(permisos.value.map((p) => [p.codigo, p.modulo]));
  return r.permisos.reduce((acc, c) => {
    const m = indice[c] ?? "otros";
    acc[m] = (acc[m] ?? 0) + 1;
    return acc;
  }, {});
}

async function cargar() {
  cargando.value = true;
  try {
    const [r, p] = await Promise.all([rolesApi.listar(), rolesApi.permisos()]);
    roles.value = r.data ?? [];
    permisos.value = p.data ?? [];
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar los roles");
  } finally {
    cargando.value = false;
  }
}

function editar(rol) {
  rolEditando.value = rol;
}

function alGuardar() {
  rolEditando.value = null;
  cargar();
}

onMounted(cargar);
</script>

<style scoped>
.roles-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(min(340px, 100%), 1fr));
  gap: var(--gap-paneles);
}
.rol { display: flex; flex-direction: column; }
.rol .card-cuerpo { flex: 1; }
</style>
