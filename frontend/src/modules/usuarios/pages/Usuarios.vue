<template>
  <div>
    <PageHeader
      eyebrow="Configuración"
      title="Usuarios"
      subtitle="Un usuario con historial se inactiva, nunca se elimina: sus OT, mensajes y diagnósticos conservan su autoría."
    >
      <template #acciones>
        <button class="btn primary" @click="crear"><Plus :size="14" /> Nuevo usuario</button>
      </template>
    </PageHeader>

    <div class="filtros">
      <input v-model.trim="f.buscar" class="input" placeholder="Buscar por nombre o correo…" @keyup.enter="cargar(1)" />
      <select v-model="f.estado" class="select" @change="cargar(1)">
        <option value="">Todos</option><option value="activo">Activos</option><option value="inactivo">Inactivos</option>
      </select>
    </div>

    <div class="tbl-shell">
      <Cargando v-if="cargando" />
      <template v-else>
        <table class="stbl">
          <thead><tr><th>Nombre</th><th>Correo</th><th>Roles</th><th>Cargo</th><th>Estado</th><th>Último acceso</th><th></th></tr></thead>
          <tbody>
            <tr v-for="u in filas" :key="u.id">
              <td><b>{{ u.nombre }}</b></td>
              <td class="mono muted">{{ u.email }}</td>
              <td>
                <span v-for="r in u.roles" :key="r.id" class="tag" style="margin-right: 4px">{{ r.nombre }}</span>
                <span v-if="!u.roles.length" class="muted">Sin rol</span>
              </td>
              <td class="muted">{{ u.cargo ?? "—" }}</td>
              <td><span class="tag" :class="u.estado === 'activo' ? 'ok' : ''">{{ etiqueta(u.estado) }}</span></td>
              <td class="mono muted">{{ u.ultimo_acceso_at ? desde(u.ultimo_acceso_at) : "nunca" }}</td>
              <td class="der">
                <button v-if="u.estado === 'activo'" class="btn sm peligro" @click="inactivar(u)">Inactivar</button>
              </td>
            </tr>
          </tbody>
        </table>
        <Paginacion :meta="meta" @ir="cargar" />
      </template>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { Plus } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Paginacion from "../../../shared/components/ui/Paginacion.vue";
import { rolesApi, usuariosApi } from "../../shared/catalogos.api.js";
import { desde, etiqueta } from "../../../shared/utils/formato.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const f = reactive({ buscar: "", estado: "" });
const filas = ref([]);
const meta = ref(null);
const cargando = ref(true);

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

async function crear() {
  const { default: Swal } = await import("sweetalert2");
  let roles = [];
  try { roles = (await rolesApi.listar()).data ?? []; } catch { /* se puede crear sin rol */ }
  const opc = roles.map((r) => `<option value="${r.codigo}">${r.nombre}</option>`).join("");

  const r = await Swal.fire({
    title: "Nuevo usuario",
    html: `<div style="text-align:left;display:grid;gap:9px">
        <label class="campo"><span class="campo-label">Nombres</span><input id="n" class="swal2-input input" style="margin:0"></label>
        <label class="campo"><span class="campo-label">Apellidos</span><input id="a" class="swal2-input input" style="margin:0"></label>
        <label class="campo"><span class="campo-label">Correo</span><input id="e" type="email" class="swal2-input input" style="margin:0"></label>
        <label class="campo"><span class="campo-label">Contraseña inicial</span>
          <input id="p" type="text" class="swal2-input input" style="margin:0" placeholder="mínimo 10 caracteres"></label>
        <label class="campo"><span class="campo-label">Rol</span>
          <select id="r" class="swal2-input input" style="margin:0">${opc}</select></label>
        <label class="campo"><span class="campo-label">Cargo</span><input id="c" class="swal2-input input" style="margin:0"></label>
      </div>`,
    width: 440, showCancelButton: true, confirmButtonText: "Crear", cancelButtonText: "Cancelar",
    buttonsStyling: false, reverseButtons: true,
    customClass: { popup: "swal-mip", confirmButton: "btn primary", cancelButton: "btn" },
    preConfirm: () => {
      const v = (id) => document.getElementById(id).value.trim();
      if (!v("n") || !v("a") || !v("e")) { Swal.showValidationMessage("Complete nombres, apellidos y correo"); return false; }
      if (v("p").length < 10) { Swal.showValidationMessage("La contraseña necesita al menos 10 caracteres"); return false; }
      return { nombres: v("n"), apellidos: v("a"), email: v("e"), password: v("p"), rolCodigos: [v("r")], cargo: v("c") || undefined };
    },
  });
  if (!r.isConfirmed) return;
  try {
    await usuariosApi.crear(r.value);
    await notify.exito("Usuario creado", "Pídale que cambie la contraseña al entrar.");
    await cargar(1);
  } catch (e) { await mostrarError(e); }
}

async function inactivar(u) {
  const motivo = await notify.pedirTexto("Inactivar el usuario", {
    texto: `${u.nombre} dejará de poder entrar, pero su historial se conserva íntegro.`,
    confirmar: "Inactivar", minimo: 5,
  });
  if (!motivo) return;
  try {
    const r = await usuariosApi.inactivar(u.id, motivo);
    if (r.data?.alerta) await notify.aviso("Usuario inactivado, con una advertencia", r.data.alerta);
    else await notify.exito("Usuario inactivado");
    await cargar();
  } catch (e) { await mostrarError(e); }
}

onMounted(() => cargar(1));
</script>
