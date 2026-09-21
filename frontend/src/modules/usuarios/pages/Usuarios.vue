<template>
  <div>
    <PageHeader
      eyebrow="Configuración"
      title="Usuarios"
      subtitle="Un usuario con historial se inactiva, nunca se elimina: sus OT, mensajes y diagnósticos conservan su autoría."
    >
      <template #acciones>
        <button class="btn primary" @click="abrirAlta"><Plus :size="14" /> Nuevo usuario</button>
      </template>
    </PageHeader>

    <ModuloPanel titulo="Equipo" :icono="Users" :conteo="meta?.total ?? null" a-sangre>
      <template #acciones>
        <BotonExportar nombre="usuarios" :columnas="COLUMNAS_EXCEL" :filas="visibles" :traer-todo="traerTodo" />
      </template>

      <template #filtros>
        <div class="fil grow">
          <Search :size="14" />
          <input v-model.trim="f.buscar" placeholder="Buscar por nombre o correo…" @keyup.enter="cargar(1)" />
        </div>
        <RangoFechas v-model:desde="f.desde" v-model:hasta="f.hasta" placeholder="Alta: todo el periodo" @cambiar="cargar(1)" />
        <SelectMenu v-model="f.estado" sabor="fil" :opciones="OPC_ESTADO" @change="cargar(1)" />
        <SelectMenu v-model="f.rol" sabor="fil" :opciones="opcRoles" @change="cargar(1)" />
        <div class="toolbar-spacer" />
        <button v-if="hayFiltros" class="chip-filter" @click="limpiar"><X :size="13" /> Limpiar filtros</button>
      </template>

      <Cargando v-if="cargando" :filas="6" />

      <div v-else-if="filas.length" class="tabla-wrap">
        <table>
          <thead>
            <tr>
              <th v-for="c in COLUMNAS" :key="c.key">{{ c.label }}</th>
              <th class="acciones-col">Acciones</th>
            </tr>
            <FilaFiltros :columnas="[...COLUMNAS, { key: '_', filtro: 'limpiar' }]" v-model="filtros" />
          </thead>
          <tbody>
            <tr v-for="u in visibles" :key="u.id">
              <td>
                <div class="entidad-cell">
                  <Avatar :nombre="u.nombre" :color="u.estado === 'activo' ? '' : 'neutral'" />
                  <div class="info">
                    <strong>{{ u.nombre }}</strong>
                    <small class="mono">{{ u.email }}</small>
                  </div>
                </div>
              </td>
              <td>
                <div class="fila fila-wrap" style="gap: 4px">
                  <span v-for="r in u.roles" :key="r.id" class="tag">{{ r.nombre }}</span>
                  <span v-if="!u.roles.length" class="mas-muted" style="font-size: 12px">Sin rol</span>
                </div>
              </td>
              <td class="muted">{{ u.cargo ?? "—" }}</td>
              <td>
                <span class="estado-pill" :class="u.estado === 'activo' ? 'ok' : 'neutral'">
                  <span class="dot" />{{ etiqueta(u.estado) }}
                </span>
              </td>
              <td class="mono muted nowrap">{{ u.ultimo_acceso_at ? desde(u.ultimo_acceso_at) : "nunca" }}</td>
              <td class="acciones-col">
                <div class="row-actions">
                  <button class="row-action" title="Editar datos y roles" @click="abrirEdicion(u)">
                    <Pencil :size="15" />
                  </button>
                  <button class="row-action" title="Restablecer contraseña" @click="passwordDe = u">
                    <KeyRound :size="15" />
                  </button>
                  <button
                    v-if="u.estado === 'activo'"
                    class="row-action peligro"
                    title="Inactivar"
                    @click="inactivar(u)"
                  >
                    <UserMinus :size="15" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>

        <div v-if="!visibles.length" class="vacio" style="padding: 40px 20px">
          <div class="vacio-titulo">Ninguna fila pasa los filtros de columna</div>
          <button class="btn" @click="filtros = {}">Quitar filtros de columna</button>
        </div>
      </div>

      <Vacio
        v-else
        :icono="Users"
        titulo="Ningún usuario con esos filtros"
        texto="Cree el primer usuario o quite los filtros para ver el equipo completo."
      >
        <button class="btn primary" @click="abrirAlta">Nuevo usuario</button>
      </Vacio>

      <template v-if="!cargando && filas.length" #pie>
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </ModuloPanel>

    <UsuarioModal :abierto="modal" :usuario="editando" @cerrar="cerrarModal" @guardado="alGuardar" />
    <PasswordModal :abierto="!!passwordDe" :usuario="passwordDe" @cerrar="passwordDe = null" @hecho="passwordDe = null" />
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, toRef } from "vue";
import { KeyRound, Pencil, Plus, Search, UserMinus, Users, X } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import ModuloPanel from "../../../shared/components/ui/ModuloPanel.vue";
import SelectMenu from "../../../shared/components/ui/SelectMenu.vue";
import RangoFechas from "../../../shared/components/ui/RangoFechas.vue";
import FilaFiltros from "../../../shared/components/ui/FilaFiltros.vue";
import BotonExportar from "../../../shared/components/ui/BotonExportar.vue";
import Avatar from "../../../shared/components/ui/Avatar.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import UsuarioModal from "../components/UsuarioModal.vue";
import PasswordModal from "../components/PasswordModal.vue";
import { rolesApi, usuariosApi } from "../../shared/catalogos.api.js";
import { useFiltroColumnas } from "../../../shared/composables/useFiltroColumnas.js";
import { desde, etiqueta } from "../../../shared/utils/formato.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const OPC_ESTADO = [
  { value: "", label: "Todos" },
  { value: "activo", label: "Activos", dot: "var(--emerald)" },
  { value: "inactivo", label: "Inactivos", dot: "var(--ink-4)" },
];

const COLUMNAS = [
  { key: "nombre", label: "Usuario", filtro: "texto", valorFiltro: (u) => `${u.nombre} ${u.email}` },
  { key: "roles", label: "Roles", filtro: "texto", valorFiltro: (u) => (u.roles ?? []).map((r) => r.nombre).join(" ") },
  { key: "cargo", label: "Cargo", filtro: "texto" },
  { key: "estado", label: "Estado", filtro: "select",
    opciones: [{ value: "activo", label: "Activo" }, { value: "inactivo", label: "Inactivo" }] },
  { key: "ultimo_acceso_at", label: "Último acceso" },
];

const COLUMNAS_EXCEL = [
  { key: "nombre", label: "Nombre" },
  { key: "email", label: "Correo" },
  { key: "roles", label: "Roles", valor: (u) => (u.roles ?? []).map((r) => r.nombre).join(", ") },
  { key: "cargo", label: "Cargo" },
  { key: "documento", label: "Documento" },
  { key: "telefono", label: "Teléfono" },
  { key: "estado", label: "Estado", valor: (u) => etiqueta(u.estado) },
  { key: "ultimo_acceso_at", label: "Último acceso", tipo: "fechaHora" },
];

const f = reactive({ buscar: "", estado: "", rol: "", desde: "", hasta: "" });
const filas = ref([]);
const meta = ref(null);
const roles = ref([]);
const cargando = ref(true);
const modal = ref(false);
const editando = ref(null);
const passwordDe = ref(null);

const { filtros, filtradas } = useFiltroColumnas(toRef(() => filas.value), COLUMNAS);
const visibles = filtradas;

const opcRoles = computed(() => [
  { value: "", label: "Todos los roles" },
  ...roles.value.map((r) => ({ value: r.codigo, label: r.nombre })),
]);

const hayFiltros = computed(() => !!(f.buscar || f.estado || f.rol || f.desde || f.hasta));

async function cargar(page = 1) {
  cargando.value = true;
  try {
    const r = await usuariosApi.listar({ ...f, page, pageSize: 25 });
    filas.value = r.data ?? [];
    meta.value = r.meta ?? null;
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar los usuarios");
  } finally {
    cargando.value = false;
  }
}

async function traerTodo() {
  const r = await usuariosApi.listar({ ...f, page: 1, pageSize: 100 });
  return r.data ?? [];
}

function limpiar() {
  Object.assign(f, { buscar: "", estado: "", rol: "", desde: "", hasta: "" });
  filtros.value = {};
  cargar(1);
}

function abrirAlta() {
  editando.value = null;
  modal.value = true;
}
function abrirEdicion(u) {
  editando.value = u;
  modal.value = true;
}
function cerrarModal() {
  modal.value = false;
  editando.value = null;
}
function alGuardar() {
  cerrarModal();
  cargar(meta.value?.page ?? 1);
}

async function inactivar(u) {
  const motivo = await notify.pedirTexto("Inactivar el usuario", {
    texto: `${u.nombre} dejará de poder entrar, pero su historial se conserva íntegro.`,
    confirmar: "Inactivar",
    minimo: 5,
  });
  if (!motivo) return;
  try {
    const r = await usuariosApi.inactivar(u.id, motivo);
    if (r.data?.alerta) await notify.aviso("Usuario inactivado, con una advertencia", r.data.alerta);
    else await notify.exito("Usuario inactivado");
    await cargar(meta.value?.page ?? 1);
  } catch (e) {
    await mostrarError(e);
  }
}

onMounted(async () => {
  try {
    roles.value = (await rolesApi.listar()).data ?? [];
  } catch {
    // El filtro de rol puede quedarse vacío sin romper la pantalla.
  }
  await cargar(1);
});
</script>
