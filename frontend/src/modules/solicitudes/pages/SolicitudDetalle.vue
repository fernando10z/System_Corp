<template>
  <div style="max-width: 860px">
    <Cargando v-if="cargando" />
    <template v-else-if="s">
      <PageHeader eyebrow="Solicitud" :title="s.numero" :subtitle="s.titulo">
        <template #acciones>
          <template v-if="p.decidir">
            <button v-if="s.estado === 'enviada'" class="btn accion" @click="tomar">Tomar la revisión</button>
            <template v-if="s.estado === 'en_revision'">
              <button class="btn primary" @click="convertir">Aceptar y crear OT</button>
              <button class="btn" @click="decidir('observar')">Observar</button>
              <button class="btn peligro" @click="decidir('rechazar')">Rechazar</button>
            </template>
          </template>
          <button v-if="p.enviar" class="btn primary" @click="enviar">Enviar</button>
        </template>
      </PageHeader>

      <div class="pila">
        <section class="card">
          <div class="card-head">
            <span class="card-titulo">Reporte original</span>
            <span class="tag" :class="s.estado === 'convertida_en_ot' ? 'ok' : 'espera'">{{ etiqueta(s.estado) }}</span>
          </div>
          <div class="card-cuerpo">
            <p style="white-space: pre-wrap; margin: 0 0 12px">{{ s.descripcion }}</p>
            <div class="defs">
              <div><div class="def-k">Lugar</div><div class="def-v">{{ s.lugar }}</div></div>
              <div><div class="def-k">Área</div><div class="def-v">{{ s.area?.nombre }}</div></div>
              <div><div class="def-k">Solicitante</div><div class="def-v">{{ s.solicitante?.nombre }}</div></div>
              <div><div class="def-k">Impacto</div><div class="def-v">{{ s.impacto ?? "—" }}</div></div>
              <div>
                <div class="def-k">Prioridad percibida</div>
                <div class="def-v">{{ etiqueta(s.prioridad_percibida) }}</div>
              </div>
              <div><div class="def-k">Enviada</div><div class="def-v mono">{{ fechaHora(s.fecha_envio) }}</div></div>
            </div>
          </div>
        </section>

        <section v-if="s.ot" class="card">
          <div class="card-head"><span class="card-titulo">Orden de trabajo generada</span></div>
          <div class="card-cuerpo fila fila-sep">
            <div class="fila" style="gap: 10px">
              <span class="mono" style="font-weight: 600">{{ s.ot.numero }}</span>
              <span class="tag">{{ etiqueta(s.ot.estado) }}</span>
            </div>
            <router-link class="btn sm" :to="`/ot/${s.ot.id}`">Abrir la OT</router-link>
          </div>
        </section>

        <!-- Cada decisión queda registrada con su motivo: es lo que permite
             entender después por qué esta solicitud acabó como acabó. -->
        <section v-if="(s.decisiones ?? []).length" class="card">
          <div class="card-head"><span class="card-titulo">Decisiones</span></div>
          <div class="card-cuerpo viajera">
            <div v-for="(d, i) in s.decisiones" :key="i" class="sello" :class="d.tipo === 'aceptar' ? 'cierre' : ''">
              <div class="sello-cab">
                <span class="sello-titulo">{{ etiqueta(d.tipo) }}</span>
                <span class="sello-meta">{{ fechaHora(d.fecha) }} · {{ d.actor }}</span>
              </div>
              <div v-if="d.estado_anterior" class="sello-cambio">
                <span class="antes">{{ etiqueta(d.estado_anterior) }}</span>
                <span class="flecha">→</span>
                <span class="despues">{{ etiqueta(d.estado_nuevo) }}</span>
              </div>
              <div v-if="d.comentario || d.motivo" class="sello-motivo">
                <b>{{ d.motivo ? "Motivo" : "Comentario" }}</b>{{ d.motivo ?? d.comentario }}
              </div>
            </div>
          </div>
        </section>
      </div>
    </template>
    <Vacio v-else titulo="No encontramos esa solicitud" texto="Puede que no esté dentro de su alcance." />
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import PageHeader from "../../../layouts/PageHeader.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import { solicitudesApi } from "../api/solicitudes.api.js";
import { catalogosApi, organizacionApi, usuariosApi } from "../../shared/catalogos.api.js";
import { otApi } from "../../ot/api/ot.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { etiqueta, fechaHora } from "../../../shared/utils/formato.js";

const route = useRoute();
const router = useRouter();
const { puede, usuario } = useAuth();

const s = ref(null);
const cargando = ref(true);

const p = computed(() => ({
  decidir: puede("solicitudes:decidir"),
  enviar: ["borrador", "observada"].includes(s.value?.estado) && s.value?.solicitante?.id === usuario.value?.id,
}));

async function cargar() {
  cargando.value = true;
  try {
    s.value = (await solicitudesApi.obtener(route.params.id)).data;
  } catch (e) {
    s.value = null;
    await mostrarError(e, "No se pudo abrir la solicitud");
  } finally {
    cargando.value = false;
  }
}

async function tomar() {
  try {
    await solicitudesApi.tomarRevision(route.params.id);
    await notify.exito("Revisión tomada", "Queda registrado el momento de la primera revisión.");
    await cargar();
  } catch (e) {
    await mostrarError(e);
  }
}

async function enviar() {
  try {
    await solicitudesApi.enviar(route.params.id);
    await notify.exito("Solicitud enviada");
    await cargar();
  } catch (e) {
    await mostrarError(e);
  }
}

async function decidir(tipo) {
  const comentario = await notify.pedirTexto(
    tipo === "observar" ? "¿Qué falta en la solicitud?" : "¿Por qué se rechaza?",
    {
      texto: "El solicitante verá este texto.",
      confirmar: tipo === "observar" ? "Observar" : "Rechazar",
      minimo: 5,
    },
  );
  if (!comentario) return;
  try {
    await solicitudesApi.decidir(route.params.id, { tipo, comentario });
    await notify.exito(tipo === "observar" ? "Solicitud observada" : "Solicitud rechazada");
    await cargar();
  } catch (e) {
    await mostrarError(e);
  }
}

/**
 * Aceptar es lo único que crea una OT, y para crearla hacen falta los datos
 * técnicos mínimos que el solicitante no tenía por qué conocer (cap. 24.4).
 */
async function convertir() {
  const { default: Swal } = await import("sweetalert2");
  let org, tipos, coordinadores;
  try {
    const [o, c, u] = await Promise.all([
      organizacionApi.arbol(),
      catalogosApi.todos("tipo_mantenimiento"),
      usuariosApi.listar({ estado: "activo", pageSize: 100 }),
    ]);
    org = o.data ?? [];
    tipos = c.data?.tipo_mantenimiento ?? [];
    coordinadores = u.data ?? [];
  } catch (e) {
    return mostrarError(e, "No se pudieron cargar los datos para crear la OT");
  }

  const sucursales = org.map((x) => `<option value="${x.id}">${x.nombre}</option>`).join("");
  const empresas = org.flatMap((x) => x.empresas ?? []);
  const opcEmpresas = empresas.map((e) => `<option value="${e.id}">${e.razon_social}</option>`).join("");
  const opcTipos = tipos.map((t) => `<option value="${t.id}">${t.nombre}</option>`).join("");
  const opcCoord = coordinadores.map((u) => `<option value="${u.id}">${u.nombre}</option>`).join("");

  const r = await Swal.fire({
    title: "Aceptar y crear la orden de trabajo",
    html: `
      <div style="text-align:left;display:grid;gap:9px">
        <label class="campo"><span class="campo-label">Sucursal</span>
          <select id="suc" class="swal2-input input" style="margin:0">${sucursales}</select></label>
        <label class="campo"><span class="campo-label">Empresa / RUC</span>
          <select id="emp" class="swal2-input input" style="margin:0">${opcEmpresas}</select></label>
        <label class="campo"><span class="campo-label">Tipo de mantenimiento</span>
          <select id="tm" class="swal2-input input" style="margin:0">${opcTipos}</select></label>
        <label class="campo"><span class="campo-label">Prioridad técnica</span>
          <select id="prio" class="swal2-input input" style="margin:0">
            <option value="critica">Crítica</option><option value="alta">Alta</option>
            <option value="media" selected>Media</option><option value="baja">Baja</option>
          </select></label>
        <label class="campo"><span class="campo-label">Coordinador responsable</span>
          <select id="coord" class="swal2-input input" style="margin:0">${opcCoord}</select></label>
        <label class="fila" style="gap:7px;font-size:12.5px;cursor:pointer">
          <input type="checkbox" id="emerg"> Clasificar como emergencia
        </label>
        <label class="campo"><span class="campo-label">Justificación de la emergencia</span>
          <textarea id="just" class="swal2-textarea textarea" style="margin:0"
            placeholder="Obligatoria si la marca como emergencia"></textarea></label>
      </div>`,
    width: 480,
    showCancelButton: true,
    confirmButtonText: "Crear la OT",
    cancelButtonText: "Cancelar",
    buttonsStyling: false,
    reverseButtons: true,
    customClass: { popup: "swal-mip", confirmButton: "btn primary", cancelButton: "btn" },
    preConfirm: () => {
      const v = (id) => document.getElementById(id)?.value?.trim() ?? "";
      const emerg = document.getElementById("emerg")?.checked ?? false;
      if (emerg && v("just").length < 10) {
        Swal.showValidationMessage("La emergencia exige una justificación de al menos 10 caracteres");
        return false;
      }
      return {
        sucursalId: v("suc"), empresaRucId: v("emp"), tipoMantenimientoId: v("tm"),
        prioridadTecnica: v("prio"), coordinadorId: v("coord"),
        esEmergencia: emerg, emergenciaJustificacion: emerg ? v("just") : undefined,
      };
    },
  });
  if (!r.isConfirmed) return;

  try {
    const res = await otApi.crear({
      solicitudId: route.params.id,
      areaId: s.value.area.id,
      ...r.value,
    });
    await notify.exito("Orden de trabajo creada", res.data.numero_ot);
    router.push(`/ot/${res.data.id}`);
  } catch (e) {
    await mostrarError(e, "No se pudo crear la OT");
  }
}

onMounted(cargar);
</script>
