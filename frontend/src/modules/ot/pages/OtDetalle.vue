<template>
  <div>
    <Cargando v-if="cargando" texto="Abriendo la orden de trabajo…" />

    <template v-else-if="t">
      <!-- ── cabecera ─────────────────────────────────────────────────── -->
      <header class="ficha-head">
        <div>
          <div class="fila" style="gap: 10px; margin-bottom: 5px">
            <router-link to="/ot" class="btn icono sm plano" title="Volver al listado">
              <ArrowLeft :size="14" />
            </router-link>
            <span class="page-eyebrow" style="margin: 0">
              {{ t.ot.es_derivada ? `Derivada de ${t.origen?.ot_padre?.numero ?? "—"}` : "Orden de trabajo" }}
            </span>
          </div>

          <div class="fila" style="gap: 12px; flex-wrap: wrap">
            <h1 class="page-title mono" style="font-size: 26px">{{ t.ot.numero }}</h1>
            <EstadoOt :estado="t.ot.estado" :admin="t.ot.estado_administrativo" />
            <span v-if="t.ot.es_emergencia" class="tag emergencia">Emergencia</span>
            <span v-if="t.ot.condicion === 'pausada'" class="tag pausada">Pausada</span>
            <span v-if="t.ot.veces_reabierta" class="tag">Reabierta ×{{ t.ot.veces_reabierta }}</span>
            <span v-if="t.ot.emergencia?.regularizacion_pendiente" class="tag espera">Regularización pendiente</span>
          </div>

          <p class="page-sub" style="margin-top: 6px">{{ titulo }}</p>
        </div>

        <!--
          Las acciones que se ofrecen dependen del ESTADO, no del rol: mostrar
          "Cerrar" en una OT en diagnóstico sería ofrecer algo imposible. El rol
          filtra después, y el SP decide de verdad.
        -->
        <div class="page-acciones" style="flex-wrap: wrap; justify-content: flex-end">
          <button v-if="p.diagnosticar" class="btn" @click="irA('diagnosticos')">
            <Stethoscope :size="14" /> Diagnosticar
          </button>
          <button v-if="p.cotizar" class="btn" @click="irA('cotizacion')">
            <FileText :size="14" /> Cargar cotización
          </button>
          <button v-if="p.iniciar" class="btn accion" @click="iniciar">
            <Play :size="14" /> Iniciar trabajo
          </button>
          <button v-if="p.avanzar" class="btn" @click="registrarAvance">
            <Plus :size="14" /> Avance
          </button>
          <button v-if="p.pausar" class="btn" @click="pausar"><Pause :size="14" /> Pausar</button>
          <button v-if="p.reanudar" class="btn accion" @click="reanudar"><Play :size="14" /> Reanudar</button>
          <button v-if="p.declarar" class="btn accion" @click="declarar">
            <CheckCheck :size="14" /> Declarar trabajo realizado
          </button>
          <button v-if="p.revisar" class="btn accion" @click="revisar">
            <ClipboardCheck :size="14" /> Revisar trabajo
          </button>
          <button v-if="p.cerrar" class="btn primary" @click="cerrar"><Lock :size="14" /> Cerrar</button>
          <button v-if="p.reabrir" class="btn" @click="reabrir"><Unlock :size="14" /> Reabrir</button>
          <button v-if="p.derivar" class="btn" @click="derivar"><GitBranch :size="14" /> Crear derivada</button>
          <button v-if="p.cancelar" class="btn peligro" @click="cancelar"><Ban :size="14" /> Cancelar</button>
        </div>
      </header>

      <!-- ── datos de un vistazo ──────────────────────────────────────── -->
      <div class="card" style="margin-bottom: 16px">
        <div class="card-cuerpo defs">
          <div><div class="def-k">Sucursal</div><div class="def-v">{{ t.organizacion?.sucursal?.nombre ?? "—" }}</div></div>
          <div v-if="t.organizacion?.empresa_ruc">
            <div class="def-k">Empresa / RUC</div>
            <div class="def-v">
              {{ t.organizacion.empresa_ruc.razon_social }}
              <span class="mono muted">{{ t.organizacion.empresa_ruc.ruc }}</span>
            </div>
          </div>
          <div><div class="def-k">Área</div><div class="def-v">{{ t.organizacion?.area?.nombre ?? "—" }}</div></div>
          <div>
            <div class="def-k">Prioridad técnica</div>
            <div class="def-v">
              <span class="prio" :class="'p-' + t.ot.prioridad_tecnica">{{ etiqueta(t.ot.prioridad_tecnica) }}</span>
              <button v-if="p.prioridad" class="btn sm plano" style="margin-left: 4px" @click="cambiarPrioridad">
                Cambiar
              </button>
            </div>
          </div>
          <div><div class="def-k">Tipo de trabajo</div><div class="def-v">{{ t.ot.tipo_trabajo ?? "—" }}</div></div>
          <div><div class="def-k">Coordinador</div><div class="def-v">{{ t.ot.coordinador ?? "—" }}</div></div>
          <div><div class="def-k">Ejecutor</div><div class="def-v">{{ t.ot.ejecutor ?? "—" }}</div></div>
          <div><div class="def-k">Creada</div><div class="def-v mono">{{ fecha(t.ot.fechas?.creacion) }}</div></div>
          <div v-if="t.ot.fechas?.inicio_real">
            <div class="def-k">Inicio real</div><div class="def-v mono">{{ fechaHora(t.ot.fechas.inicio_real) }}</div>
          </div>
          <div v-if="t.ot.fechas?.termino_real">
            <div class="def-k">Término real</div><div class="def-v mono">{{ fechaHora(t.ot.fechas.termino_real) }}</div>
          </div>
          <div v-if="t.ejecucion?.duracion_dias">
            <div class="def-k">Duración</div>
            <div class="def-v mono">{{ t.ejecucion.duracion_dias }} días calendario</div>
          </div>
          <div v-if="t.ot.fechas?.cierre">
            <div class="def-k">Cierre</div><div class="def-v mono">{{ fechaHora(t.ot.fechas.cierre) }}</div>
          </div>
        </div>

        <!-- La emergencia se explica siempre: es una excepción que exige justificarse. -->
        <div v-if="t.ot.emergencia" class="card-cuerpo" style="border-top: 1px solid var(--line-soft)">
          <div class="sello-motivo" style="border-left-color: var(--rojo-linea); background: var(--rojo-piel)">
            <b style="color: var(--rojo)">Clasificada como emergencia</b>
            {{ t.ot.emergencia.justificacion }}
            <div class="muted mono" style="font-size: 10.5px; margin-top: 3px">
              {{ t.ot.emergencia.declarada_por }} · {{ fechaHora(t.ot.emergencia.declarada_at) }}
            </div>
          </div>
        </div>
      </div>

      <Tabs :tabs="pestanas" :activo="tab" @cambiar="tab = $event" />

      <OtResumen v-if="tab === 'resumen'" :t="t" />
      <OtDiagnosticos v-else-if="tab === 'diagnosticos'" :t="t" :ot-id="id" @cambio="recargar" />
      <OtCotizaciones v-else-if="tab === 'cotizacion'" :t="t" :ot-id="id" @cambio="recargar" />
      <OtEjecucion v-else-if="tab === 'ejecucion'" :t="t" />
      <OtAdministrativo v-else-if="tab === 'administrativo'" :t="t" :ot-id="id" @cambio="recargar" />
      <OtDerivadas v-else-if="tab === 'derivadas'" :ot-id="id" />
      <OtConversacion v-else-if="tab === 'conversacion'" :ot-id="id" :solo-lectura="t.conversacion?.solo_lectura" />

      <!-- La pestaña que da nombre al producto. -->
      <TarjetaViajera v-else-if="tab === 'trazabilidad'" :eventos="t.eventos ?? []" :meta="t._meta" />
    </template>

    <Vacio v-else titulo="No encontramos esa orden de trabajo" texto="Puede que se haya cancelado o que no esté en su alcance." />
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import {
  ArrowLeft, Ban, CheckCheck, ClipboardCheck, FileText, GitBranch, Lock, Pause, Play, Plus, Stethoscope, Unlock,
} from "lucide-vue-next";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Tabs from "../../../shared/components/ui/Tabs.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import TarjetaViajera from "../../../shared/components/ui/TarjetaViajera.vue";
import OtResumen from "../components/OtResumen.vue";
import OtDiagnosticos from "../components/OtDiagnosticos.vue";
import OtCotizaciones from "../components/OtCotizaciones.vue";
import OtEjecucion from "../components/OtEjecucion.vue";
import OtAdministrativo from "../components/OtAdministrativo.vue";
import OtDerivadas from "../components/OtDerivadas.vue";
import OtConversacion from "../components/OtConversacion.vue";
import { otApi } from "../api/ot.api.js";
import { usuariosApi } from "../../shared/catalogos.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { etiqueta, fecha, fechaHora } from "../../../shared/utils/formato.js";

const route = useRoute();
const router = useRouter();
const { puede } = useAuth();

const id = computed(() => route.params.id);
const t = ref(null);
const cargando = ref(true);
const tab = ref("resumen");

const titulo = computed(
  () => t.value?.origen?.solicitud?.titulo ?? t.value?.origen?.ot_padre?.motivo_derivacion ?? "",
);

const pestanas = computed(() => {
  const x = t.value;
  if (!x) return [];
  const lista = [
    { key: "resumen", label: "Resumen" },
    { key: "diagnosticos", label: "Diagnósticos", n: x.diagnosticos?.length ?? 0 },
  ];
  // Las secciones podadas por permisos sencillamente no aparecen: es más honesto
  // que mostrar una pestaña vacía o un candado.
  if (x.cotizaciones) lista.push({ key: "cotizacion", label: "Cotización", n: x.cotizaciones.length });
  lista.push({
    key: "ejecucion",
    label: "Ejecución",
    n: (x.ejecucion?.avances?.length ?? 0) + (x.ejecucion?.incidencias?.length ?? 0),
  });
  if (x.administrativo) lista.push({ key: "administrativo", label: "Administrativo" });
  lista.push({ key: "derivadas", label: "Derivadas", n: x.derivadas?.length ?? 0 });
  if (x.conversacion) lista.push({ key: "conversacion", label: "Conversación", n: x.conversacion.mensajes?.length ?? 0 });
  lista.push({ key: "trazabilidad", label: "Trazabilidad", n: x.eventos?.length ?? 0 });
  return lista;
});

/** Qué acciones tienen sentido AHORA, según estado y permisos. */
const p = computed(() => {
  const e = t.value?.ot?.estado;
  const pausada = t.value?.ot?.condicion === "pausada";
  const hayDiag = (t.value?.diagnosticos ?? []).some((d) => d.vigente);
  const hayCotiz = (t.value?.cotizaciones ?? []).some((c) => c.vigente);
  const revisionAprobada = (t.value?.cierre?.trabajo_realizado ?? []).some(
    (w) => w.vigente && w.revision?.resultado === "aprobado",
  );
  return {
    diagnosticar: puede("diagnosticos:registrar") && ["creada", "en_diagnostico", "en_cotizacion", "en_trabajo"].includes(e),
    cotizar: puede("cotizaciones:cargar") && ["en_diagnostico", "en_cotizacion", "en_trabajo"].includes(e),
    iniciar: puede("ejecucion:iniciar") && ["en_cotizacion", "en_diagnostico"].includes(e) && (hayCotiz || t.value?.ot?.es_emergencia),
    avanzar: puede("ejecucion:avanzar") && e === "en_trabajo",
    pausar: puede("ejecucion:pausar") && e === "en_trabajo" && !pausada,
    reanudar: puede("ejecucion:pausar") && pausada,
    declarar: puede("ejecucion:declarar_trabajo") && e === "en_trabajo" && !pausada,
    revisar: puede("ot:revisar") && e === "trabajo_realizado",
    cerrar: puede("ot:cerrar") && e === "trabajo_realizado" && revisionAprobada,
    reabrir: puede("ot:reabrir") && e === "cerrada",
    derivar: puede("ot:derivar") && !["cancelada"].includes(e),
    cancelar: puede("ot:cancelar") && !["cerrada", "cancelada"].includes(e),
    prioridad: puede("ot:cambiar_prioridad") && !["cerrada", "cancelada"].includes(e),
    _hayDiag: hayDiag,
  };
});

function irA(t2) { tab.value = t2; }

async function recargar() {
  try {
    t.value = (await otApi.obtener(id.value)).data;
  } catch (e) {
    t.value = null;
    await mostrarError(e, "No se pudo abrir la orden de trabajo");
  } finally {
    cargando.value = false;
  }
}

async function accion(fn, exito) {
  try {
    await fn();
    await notify.exito(exito);
    await recargar();
  } catch (e) {
    await mostrarError(e);
  }
}

/**
 * Iniciar exige SIEMPRE un responsable de ejecución, tanto en el flujo normal
 * como en emergencia (cap. 29.1). Se elige aquí en lugar de fallar después.
 */
async function iniciar() {
  let ejecutores;
  try {
    const r = await usuariosApi.listar({ estado: "activo", pageSize: 100 });
    ejecutores = Object.fromEntries((r.data ?? []).map((u) => [u.id, `${u.nombre}${u.cargo ? " · " + u.cargo : ""}`]));
  } catch (e) {
    return mostrarError(e, "No se pudo cargar la lista de responsables");
  }
  if (!Object.keys(ejecutores).length) {
    return notify.aviso("No hay usuarios activos", "Cree o active un usuario para poder asignarlo como ejecutor.");
  }

  const responsableId = await notify.elegir("¿Quién ejecuta el trabajo?", ejecutores, {
    texto: t.value?.ot?.es_emergencia
      ? "Es una emergencia: puede iniciar sin cotización, pero la regularización queda pendiente."
      : "El inicio requiere cotización vigente y su confirmación.",
    confirmar: "Iniciar trabajo",
  });
  if (!responsableId) return;

  await accion(() => otApi.iniciar(id.value, { responsableId }), "Trabajo iniciado");
}

async function registrarAvance() {
  const d = await notify.pedirTexto("Registrar avance", {
    texto: "Cuente qué se hizo. El porcentaje no es obligatorio.",
    placeholder: "Ej. cabezal desmontado y enviado a rectificado",
    confirmar: "Registrar",
    minimo: 5,
  });
  if (d) await accion(() => otApi.avance(id.value, { descripcion: d }), "Avance registrado");
}

async function pausar() {
  const m = await notify.pedirTexto("Pausar el trabajo", {
    texto: "Mientras esté pausada no se puede declarar el trabajo realizado.",
    placeholder: "Ej. esperando el eje del taller de rectificado",
    confirmar: "Pausar",
    minimo: 5,
  });
  if (m) await accion(() => otApi.pausar(id.value, { motivoTexto: m }), "Trabajo pausado");
}

async function reanudar() {
  await accion(() => otApi.reanudar(id.value, {}), "Trabajo reanudado");
}

async function declarar() {
  const d = await notify.pedirTexto("Declarar el trabajo realizado", {
    texto: "Describa el resultado final. El coordinador lo revisará antes del cierre.",
    placeholder: "Ej. rodamiento reemplazado, alineado y probado 2 h sin fuga",
    confirmar: "Declarar",
    minimo: 10,
  });
  if (d) await accion(() => otApi.declararTrabajo(id.value, { descripcion: d }), "Trabajo declarado");
}

async function revisar() {
  const r = await notify.elegir(
    "Revisar el trabajo declarado",
    { aprobado: "Aprobar para el cierre", correccion_solicitada: "Devolver con correcciones" },
    { confirmar: "Continuar" },
  );
  if (!r) return;
  let observacion = "";
  if (r === "correccion_solicitada") {
    observacion = await notify.pedirTexto("¿Qué hay que corregir?", {
      texto: "El ejecutor verá esta observación y la OT volverá a En trabajo.",
      confirmar: "Devolver",
      minimo: 5,
    });
    if (!observacion) return;
  }
  await accion(
    () => otApi.revisar(id.value, { resultado: r, observacion }),
    r === "aprobado" ? "Trabajo aprobado" : "Devuelto con observación",
  );
}

/**
 * Cerrar es el flujo con más matiz del producto.
 *
 * La API responde ok:false con `requiere_confirmacion` cuando hay pendientes
 * administrativos. Eso NO es un error: es el sistema pidiendo la confirmación
 * explícita y la observación que el cap. 31.2 exige. Se traduce en un segundo
 * diálogo, no en un mensaje de fallo.
 */
async function cerrar() {
  const r = await otApi.cerrar(id.value, {});
  if (r.ok) {
    await notify.exito("Orden de trabajo cerrada", r.data?.indicador ?? "");
    return recargar();
  }

  if (r.data?.requiere_confirmacion) {
    const ok = await notify.confirmar(
      "El seguimiento administrativo tiene pendientes",
      `Estado actual: ${etiqueta(r.data.estado_administrativo)}. Puede cerrar la OT igualmente, pero debe dejar constancia del pendiente.`,
      { confirmar: "He revisado el seguimiento" },
    );
    if (!ok) return;

    const obs = await notify.pedirTexto("Explique el pendiente", {
      texto: "Quedará visible en las listas y en el tablero hasta que se resuelva.",
      placeholder: "Ej. Compras emite la OC esta semana",
      confirmar: "Cerrar la OT",
      minimo: 10,
    });
    if (!obs) return;

    const r2 = await otApi.cerrar(id.value, { adminRevisado: true, observacionPendiente: obs });
    if (r2.ok) {
      await notify.exito("Orden de trabajo cerrada", r2.data?.indicador ?? "");
      return recargar();
    }
    return notify.error("No se pudo cerrar", r2.error?.message ?? "");
  }

  return notify.error("No se pudo cerrar", r.error?.message ?? "");
}

async function reabrir() {
  const m = await notify.pedirTexto("Reabrir la orden de trabajo", {
    texto: "El cierre anterior se conserva. Explique por qué se reabre.",
    placeholder: "Ej. la fuga reapareció a los tres días",
    confirmar: "Reabrir",
    minimo: 10,
  });
  if (m) await accion(() => otApi.reabrir(id.value, { motivoTexto: m }), "Orden de trabajo reabierta");
}

async function derivar() {
  const m = await notify.pedirTexto("Crear una OT derivada", {
    texto:
      "Una derivada es para cuando el trabajo deja de ser una sola intervención: otra especialidad, otro proveedor, otro alcance. Para una nota basta un avance.",
    placeholder: "Ej. el tablero requiere intervención eléctrica con otro proveedor",
    confirmar: "Crear derivada",
    minimo: 10,
  });
  if (!m) return;
  try {
    const r = await otApi.crearDerivada(id.value, { motivoDerivacion: m });
    await notify.exito("Derivada creada", `${r.data.numero_ot} · nivel ${r.data.nivel}`);
    router.push(`/ot/${r.data.id}`);
  } catch (e) {
    await mostrarError(e);
  }
}

/**
 * Cancelar con derivadas activas: la API devuelve la lista y el usuario decide
 * qué hacer con ellas (cap. 25.3). No se decide por él.
 */
async function cancelar() {
  const obs = await notify.pedirTexto("Cancelar la orden de trabajo", {
    texto: "La OT se conserva con todo su historial. Explique por qué se cancela.",
    confirmar: "Continuar",
    minimo: 10,
  });
  if (!obs) return;

  const r = await otApi.cancelar(id.value, { observacion: obs });
  if (r.ok) {
    await notify.exito("Orden de trabajo cancelada");
    return recargar();
  }

  const activas = r.data?.derivadas_activas ?? [];
  if (activas.length) {
    const lista = activas.map((d) => `${d.numero} (${etiqueta(d.estado)})`).join(", ");
    const trato = await notify.elegir(
      `Esta OT tiene ${activas.length} derivada(s) activa(s)`,
      {
        cancelar: "Cancelarlas también",
        independizar: "Mantenerlas activas por su cuenta",
      },
      { texto: `Afecta a: ${lista}. Decida qué pasa con ellas.`, confirmar: "Aplicar" },
    );
    if (!trato) return;

    const r2 = await otApi.cancelar(id.value, { observacion: obs, tratamientoDerivadas: trato });
    if (r2.ok) {
      await notify.exito("Orden de trabajo cancelada");
      return recargar();
    }
    return notify.error("No se pudo cancelar", r2.error?.message ?? "");
  }

  return notify.error("No se pudo cancelar", r.error?.message ?? "");
}

async function cambiarPrioridad() {
  const nueva = await notify.elegir(
    "Cambiar la prioridad técnica",
    { critica: "Crítica", alta: "Alta", media: "Media", baja: "Baja" },
    { texto: "La prioridad que percibió el solicitante no cambia: son dos cosas distintas.", confirmar: "Cambiar" },
  );
  if (!nueva) return;

  // Bajar una prioridad alta o cambiarla en ejecución exige motivo (cap. 25.4).
  const exigeMotivo =
    ["critica", "alta"].includes(t.value.ot.prioridad_tecnica) || t.value.ot.estado === "en_trabajo";
  let motivo = "";
  if (exigeMotivo) {
    motivo = await notify.pedirTexto("¿Por qué cambia la prioridad?", { confirmar: "Cambiar", minimo: 5 });
    if (!motivo) return;
  }
  await accion(() => otApi.cambiarPrioridad(id.value, { prioridad: nueva, motivo }), "Prioridad actualizada");
}

watch(id, recargar);
onMounted(recargar);
</script>

<style scoped>
.ficha-head {
  display: flex; align-items: flex-start; justify-content: space-between;
  gap: 20px; margin-bottom: 18px;
}
</style>
