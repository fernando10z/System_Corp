<template>
  <div>
    <PageHeader
      eyebrow="Configuración"
      title="Roles y permisos"
      subtitle="La matriz de base viene del documento. Es un punto de partida funcional, no la política de seguridad final de su organización."
    />

    <Cargando v-if="cargando" />
    <div v-else class="pila">
      <section v-for="r in roles" :key="r.id" class="card">
        <div class="card-head">
          <div>
            <span class="card-titulo">{{ r.nombre }}</span>
            <span class="mono muted" style="margin-left: 7px; font-size: 11px">{{ r.codigo }}</span>
          </div>
          <div class="fila" style="gap: 9px">
            <span class="muted" style="font-size: 12px">
              {{ r.usuarios }} usuario(s) · {{ r.permisos.length }} permiso(s)
            </span>
            <button class="btn sm" @click="editar(r)">Editar permisos</button>
          </div>
        </div>
        <div class="card-cuerpo">
          <p v-if="r.descripcion" class="muted" style="margin: 0 0 9px; font-size: 12.5px">{{ r.descripcion }}</p>
          <div class="fila" style="flex-wrap: wrap; gap: 5px">
            <span v-for="p in r.permisos" :key="p" class="tag mono" style="font-size: 10px">{{ p }}</span>
            <span v-if="!r.permisos.length" class="muted" style="font-size: 12px">Sin permisos asignados</span>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import { rolesApi } from "../../shared/catalogos.api.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const roles = ref([]);
const permisos = ref([]);
const cargando = ref(true);

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

async function editar(rol) {
  const { default: Swal } = await import("sweetalert2");
  // Agrupados por módulo: revisar 44 permisos en una lista plana es inviable.
  const porModulo = permisos.value.reduce((acc, p) => ((acc[p.modulo] ??= []).push(p), acc), {});
  const html = Object.entries(porModulo)
    .map(
      ([modulo, ps]) => `
      <div style="margin-bottom:11px">
        <div class="def-k" style="margin-bottom:5px">${modulo}</div>
        ${ps
          .map(
            (p) => `<label style="display:flex;gap:7px;align-items:flex-start;font-size:12.5px;padding:2px 0;cursor:pointer">
              <input type="checkbox" value="${p.codigo}" class="perm" ${rol.permisos.includes(p.codigo) ? "checked" : ""}>
              <span><b class="mono" style="font-size:11px">${p.accion}</b>
                <span style="color:var(--ink-3)"> · ${p.descripcion ?? ""}</span></span>
            </label>`,
          )
          .join("")}
      </div>`,
    )
    .join("");

  const r = await Swal.fire({
    title: `Permisos de ${rol.nombre}`,
    html: `<div style="text-align:left;max-height:52vh;overflow-y:auto">${html}</div>`,
    width: 620,
    showCancelButton: true, confirmButtonText: "Guardar", cancelButtonText: "Cancelar",
    buttonsStyling: false, reverseButtons: true,
    customClass: { popup: "swal-mip", confirmButton: "btn primary", cancelButton: "btn" },
    preConfirm: () => [...document.querySelectorAll(".perm:checked")].map((i) => i.value),
  });
  if (!r.isConfirmed) return;

  try {
    await rolesApi.asignarPermisos(rol.id, r.value);
    await notify.exito("Permisos actualizados", "El cambio queda registrado en la auditoría.");
    await cargar();
  } catch (e) { await mostrarError(e); }
}

onMounted(cargar);
</script>
