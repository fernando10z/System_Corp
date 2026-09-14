<template>
  <div>
    <PageHeader
      eyebrow="Configuración"
      title="Organización"
      subtitle="Sucursal → Empresa/RUC → Área. Un área pertenece a una sola razón social: el mismo nombre bajo otra RUC es otra área."
    >
      <template #acciones>
        <button class="btn" @click="crearSucursal"><Plus :size="14" /> Sucursal</button>
        <button class="btn" @click="crearEmpresa"><Plus :size="14" /> Empresa</button>
        <button class="btn primary" @click="crearArea"><Plus :size="14" /> Área</button>
      </template>
    </PageHeader>

    <Cargando v-if="cargando" />
    <div v-else class="pila">
      <section v-for="s in arbol" :key="s.id" class="card">
        <div class="card-head">
          <span class="card-titulo">{{ s.nombre }} <span class="mono muted">{{ s.codigo }}</span></span>
          <span class="tag" :class="s.estado === 'activo' ? 'ok' : ''">{{ etiqueta(s.estado) }}</span>
        </div>
        <div class="card-cuerpo">
          <div v-for="e in s.empresas" :key="e.id" style="margin-bottom: 14px">
            <div class="fila" style="gap: 9px; margin-bottom: 7px">
              <b>{{ e.razon_social }}</b>
              <span class="mono muted">{{ e.ruc }}</span>
              <span v-if="e.estado !== 'activo'" class="tag">Inactiva</span>
              <span class="crecer"></span>
              <button v-if="e.estado === 'activo'" class="btn sm peligro" @click="inactivar(e)">Inactivar</button>
            </div>
            <div class="fila" style="flex-wrap: wrap; gap: 6px; padding-left: 13px">
              <span v-for="a in e.areas" :key="a.id" class="tag">{{ a.nombre }}</span>
              <span v-if="!e.areas.length" class="muted" style="font-size: 12px">Sin áreas todavía</span>
            </div>
          </div>
          <div v-if="!s.empresas.length" class="muted" style="font-size: 12.5px">
            Esta sucursal no tiene empresas asociadas.
          </div>
        </div>
      </section>

      <Vacio
        v-if="!arbol.length"
        titulo="Todavía no hay estructura"
        texto="Empiece creando una sucursal, luego la empresa con su RUC y por último las áreas."
      />
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { Plus } from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import { organizacionApi } from "../../shared/catalogos.api.js";
import { etiqueta } from "../../../shared/utils/formato.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const arbol = ref([]);
const cargando = ref(true);

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

async function pedirDos(titulo, l1, p1, l2, p2, confirmar) {
  const { default: Swal } = await import("sweetalert2");
  const r = await Swal.fire({
    title: titulo,
    html: `<div style="text-align:left;display:grid;gap:9px">
        <label class="campo"><span class="campo-label">${l1}</span>
          <input id="a" class="swal2-input input" style="margin:0" placeholder="${p1}"></label>
        <label class="campo"><span class="campo-label">${l2}</span>
          <input id="b" class="swal2-input input" style="margin:0" placeholder="${p2}"></label>
      </div>`,
    showCancelButton: true, confirmButtonText: confirmar, cancelButtonText: "Cancelar",
    buttonsStyling: false, reverseButtons: true,
    customClass: { popup: "swal-mip", confirmButton: "btn primary", cancelButton: "btn" },
    preConfirm: () => {
      const a = document.getElementById("a").value.trim();
      const b = document.getElementById("b").value.trim();
      if (!a || !b) { Swal.showValidationMessage("Complete los dos campos"); return false; }
      return { a, b };
    },
  });
  return r.isConfirmed ? r.value : null;
}

async function crearSucursal() {
  const v = await pedirDos("Nueva sucursal", "Código", "PLANTA-02", "Nombre", "Planta norte", "Crear");
  if (!v) return;
  try {
    await organizacionApi.crearSucursal({ codigo: v.a, nombre: v.b });
    await notify.exito("Sucursal creada");
    await cargar();
  } catch (e) { await mostrarError(e); }
}

async function crearEmpresa() {
  const v = await pedirDos("Nueva empresa", "RUC", "20100000001", "Razón social", "EMPRESA S.A.C.", "Crear");
  if (!v) return;
  try {
    await organizacionApi.crearEmpresa({ ruc: v.a, razonSocial: v.b });
    await notify.exito("Empresa creada", "Asóciela a una sucursal para poder usarla.");
    await cargar();
  } catch (e) { await mostrarError(e); }
}

async function crearArea() {
  const empresas = arbol.value.flatMap((s) => s.empresas ?? []);
  if (!empresas.length) return notify.aviso("Cree primero una empresa", "Un área pertenece siempre a una empresa/RUC.");
  const empresaRucId = await notify.elegir(
    "¿A qué empresa pertenece el área?",
    Object.fromEntries(empresas.map((e) => [e.id, `${e.razon_social} · ${e.ruc}`])),
    { confirmar: "Siguiente" },
  );
  if (!empresaRucId) return;
  const v = await pedirDos("Nueva área", "Código", "MANTTO", "Nombre", "Mantenimiento", "Crear");
  if (!v) return;
  try {
    await organizacionApi.crearArea({ empresaRucId, codigo: v.a, nombre: v.b });
    await notify.exito("Área creada");
    await cargar();
  } catch (e) { await mostrarError(e); }
}

/** Inactivar conserva la RUC y avisa de las OT abiertas que quedan (QA-24). */
async function inactivar(e) {
  const motivo = await notify.pedirTexto("Inactivar la empresa", {
    texto: "Se conserva en los datos y en el historial, pero no podrá usarse en OT nuevas.",
    confirmar: "Inactivar", minimo: 5,
  });
  if (!motivo) return;
  try {
    const r = await organizacionApi.inactivarEmpresa(e.id, motivo);
    if (r.data?.alerta) await notify.aviso("Empresa inactivada, con una advertencia", r.data.alerta);
    else await notify.exito("Empresa inactivada");
    await cargar();
  } catch (err) { await mostrarError(err); }
}

onMounted(cargar);
</script>
