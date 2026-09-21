<template>
  <div>
    <Cargando v-if="cargando" texto="Abriendo la orden de trabajo…" />

    <template v-else-if="t">
      <!-- ── cabecera ─────────────────────────────────────────────────── -->
      <header class="ficha-head" :style="{ '--galon': galonEstado(t.ot.estado) }">
        <div class="ficha-top">
          <div class="ficha-id">
            <div class="fila" style="gap: 10px; margin-bottom: 8px">
              <router-link to="/ot" class="row-action" title="Volver al listado"><ArrowLeft :size="15" /></router-link>
              <span class="eyebrow">
                {{ t.ot.es_derivada ? `Derivada de ${t.origen?.ot_padre?.numero ?? "—"}` : "Orden de trabajo" }}
              </span>
            </div>

            <div class="ficha-numero">{{ t.ot.numero }}</div>
            <p v-if="titulo" class="ficha-titulo">{{ titulo }}</p>

            <div class="ficha-marcas">
              <EstadoOt :estado="t.ot.estado" :admin="t.ot.estado_administrativo" />
              <span v-if="t.ot.es_emergencia" class="tag emergencia"><Siren :size="11" /> Emergencia</span>
              <span v-if="t.ot.condicion === 'pausada'" class="tag pausada"><Pause :size="11" /> Pausada</span>
              <span v-if="t.ot.veces_reabierta" class="tag">Reabierta ×{{ t.ot.veces_reabierta }}</span>
              <span v-if="t.ot.emergencia?.regularizacion_pendiente" class="tag espera">Regularización pendiente</span>
            </div>
          </div>

          <div class="ficha-cifras">
            <div class="qs">
              <div class="ql">Prioridad</div>
              <div class="qv" :class="{ peligro: t.ot.prioridad_tecnica === 'critica', espera: t.ot.prioridad_tecnica === 'alta' }">
                {{ etiqueta(t.ot.prioridad_tecnica) }}
              </div>
            </div>
            <div class="qs">
              <div class="ql">Cotizado</div>
              <div class="qv mono">{{ cotizacionVigente ? monto(cotizacionVigente.monto, cotizacionVigente.moneda) : "—" }}</div>
            </div>
            <div class="qs">
              <div class="ql">Abierta</div>
              <div class="qv">{{ t.ejecucion?.duracion_dias ? dias(t.ejecucion.duracion_dias) : desde(t.ot.fechas?.creacion) }}</div>
            </div>
            <div v-if="(t.derivadas ?? []).length" class="qs">
              <div class="ql">Derivadas</div>
              <div class="qv" :class="{ peligro: bloqueantes }">
                {{ t.derivadas.length }}<span v-if="bloqueantes" style="font-size: 12px"> · {{ bloqueantes }} bloquea(n)</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!--
        Qué espera la OT ahora mismo. Es la pregunta que se hace cualquiera al
        abrir la ficha, y hasta ahora había que deducirla del estado más las
        pestañas. Decirla en una línea ahorra ese trabajo.
      -->
      <div v-if="siguientePaso" class="aviso" :class="siguientePaso.tono" style="margin-bottom: var(--gap-paneles)">
        <component :is="siguientePaso.icono" :size="15" />
        <div><b>{{ siguientePaso.titulo }}</b>{{ siguientePaso.texto }}</div>
      </div>

      <!--
        Las acciones dependen del ESTADO, no del rol: mostrar "Cerrar" en una OT
        en diagnóstico sería ofrecer algo imposible. El rol filtra después, y el
        stored procedure decide de verdad.
      -->
      <div v-if="hayAcciones" class="ficha-acciones">
        <button v-if="p.diagnosticar" class="btn" @click="tab = 'diagnosticos'"><Stethoscope :size="14" /> Diagnosticar</button>
        <button v-if="p.cotizar" class="btn" @click="tab = 'cotizacion'"><FileText :size="14" /> Cotización</button>
        <button v-if="p.iniciar" class="btn accion" @click="iniciar"><Play :size="14" /> Iniciar trabajo</button>
        <button v-if="p.avanzar" class="btn" @click="registrarAvance"><Plus :size="14" /> Avance</button>
        <button v-if="p.pausar" class="btn" @click="pausar"><Pause :size="14" /> Pausar</button>
        <button v-if="p.reanudar" class="btn accion" @click="reanudar"><Play :size="14" /> Reanudar</button>
        <button v-if="p.declarar" class="btn accion" @click="declarar"><CheckCheck :size="14" /> Declarar realizado</button>
        <button v-if="p.revisar" class="btn accion" @click="revisar"><ClipboardCheck :size="14" /> Revisar trabajo</button>
        <button v-if="p.cerrar" class="btn primary" @click="cerrar"><Lock :size="14" /> Cerrar</button>

        <span class="crecer" />

        <button v-if="p.derivar" class="btn plano" @click="derivar"><GitBranch :size="14" /> Derivar</button>
        <button v-if="p.reabrir" class="btn plano" @click="reabrir"><Unlock :size="14" /> Reabrir</button>
        <button v-if="p.cancelar" class="btn peligro" @click="cancelar"><Ban :size="14" /> Cancelar</button>
      </div>

      <!-- La emergencia se explica siempre: es una excepción que exige justificarse. -->
      <div v-if="t.ot.emergencia" class="card" style="margin-bottom: var(--gap-paneles)">
        <div class="card-cuerpo">
          <div class="sello-motivo peligro" style="margin: 0">
            <b>Clasificada como emergencia</b>
            {{ t.ot.emergencia.justificacion }}
            <div class="mas-muted mono" style="font-size: 10.5px; margin-top: 5px">
              {{ t.ot.emergencia.declarada_por }} · {{ fechaHora(t.ot.emergencia.declarada_at) }}
            </div>
          </div>
        </div>
      </div>

      <!-- ── datos de un vistazo ──────────────────────────────────────── -->
      <section class="card" style="margin-bottom: var(--gap-paneles)">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile neutral"><Info :size="14" /></span>
            Datos de la intervención
          </span>
          <button v-if="p.prioridad" class="btn sm" @click="cambiarPrioridad">Cambiar prioridad</button>
        </div>
        <div class="card-cuerpo defs">
          <div><div class="def-k">Sucursal</div><div class="def-v">{{ t.organizacion?.sucursal?.nombre ?? "—" }}</div></div>
          <div v-if="t.organizacion?.empresa_ruc">
            <div class="def-k">Empresa / RUC</div>
            <div class="def-v">
              {{ t.organizacion.empresa_ruc.razon_social }}
              <div class="mono mas-muted" style="font-size: 11.5px">{{ t.organizacion.empresa_ruc.ruc }}</div>
            </div>
          </div>
          <div><div class="def-k">Área</div><div class="def-v">{{ t.organizacion?.area?.nombre ?? "—" }}</div></div>
          <div><div class="def-k">Tipo de trabajo</div><div class="def-v">{{ t.ot.tipo_trabajo ?? "—" }}</div></div>
          <div><div class="def-k">Coordinador</div><div class="def-v">{{ t.ot.coordinador ?? "—" }}</div></div>
          <div><div class="def-k">Ejecutor</div><div class="def-v">{{ t.ot.ejecutor ?? "Sin asignar" }}</div></div>
          <div><div class="def-k">Creada</div><div class="def-v mono">{{ fecha(t.ot.fechas?.creacion) }}</div></div>
          <div v-if="t.ot.fechas?.inicio_real">
            <div class="def-k">Inicio real</div><div class="def-v mono">{{ fechaHora(t.ot.fechas.inicio_real) }}</div>
          </div>
          <div v-if="t.ot.fechas?.termino_real">
            <div class="def-k">Término real</div><div class="def-v mono">{{ fechaHora(t.ot.fechas.termino_real) }}</div>
          </div>
          <div v-if="t.ot.fechas?.cierre">
            <div class="def-k">Cierre</div><div class="def-v mono">{{ fechaHora(t.ot.fechas.cierre) }}</div>
          </div>
        </div>
      </section>

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

      <!--
        Las acciones que piden un texto o una elección son modales propios, no
        diálogos del sistema: comparten ancho, tipografía y botonera con el
        resto de la aplicación. Antes cada uno se dibujaba distinto y por eso se
        veían desalineados entre sí.
      -->
      <ModalTexto
        v-if="mt"
        :abierto="!!mt"
        v-bind="mt"
        @cerrar="mt = null"
        @hecho="trasAccion(mt.exito)"
      />
      <ModalElegir
        v-if="me"
        :abierto="!!me"
        v-bind="me"
        @cerrar="me = null"
        @hecho="trasAccion(me.exito)"
      />
    </template>

    <Vacio
      v-else
      :icono="SearchX"
      titulo="No encontramos esa orden de trabajo"
      texto="Puede que se haya cancelado o que no esté dentro de su alcance."
    >
      <router-link class="btn" to="/ot">Volver al listado</router-link>
    </Vacio>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import {
  ArrowLeft, Ban, CheckCheck, ClipboardCheck, Coins, FileText, GitBranch, Info, Lock,
  Pause, Play, Plus, SearchX, Siren, Stethoscope, TriangleAlert, Unlock,
} from "lucide-vue-next";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import Tabs from "../../../shared/components/ui/Tabs.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import TarjetaViajera from "../../../shared/components/ui/TarjetaViajera.vue";
import ModalTexto from "../../../shared/components/ui/ModalTexto.vue";
import ModalElegir from "../../../shared/components/ui/ModalElegir.vue";
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
import { useTitulo } from "../../../shared/composables/useTitulo.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { dias, desde, etiqueta, fecha, fechaHora, galonEstado, monto } from "../../../shared/utils/formato.js";

const route = useRoute();
const router = useRouter();
const { puede } = useAuth();
const { fijar: fijarTitulo } = useTitulo();

const id = computed(() => route.params.id);
const t = ref(null);
const cargando = ref(true);
const tab = ref("resumen");

const titulo = computed(
  () => t.value?.origen?.solicitud?.titulo ?? t.value?.origen?.ot_padre?.motivo_derivacion ?? "",
);

const cotizacionVigente = computed(() => (t.value?.cotizaciones ?? []).find((c) => c.vigente));
const hayDiagnostico = computed(() => (t.value?.diagnosticos ?? []).some((d) => d.vigente));

const bloqueantes = computed(
  () =>
    (t.value?.derivadas ?? []).filter(
      (d) => d.es_bloqueante && !["cerrada", "cancelada"].includes(d.estado),
    ).length,
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
  const hayCotiz = !!cotizacionVigente.value;
  const revisionAprobada = (t.value?.cierre?.trabajo_realizado ?? []).some(
    (w) => w.vigente && w.revision?.resultado === "aprobado",
  );
  return {
    diagnosticar: puede("diagnosticos:registrar") && ["creada", "en_diagnostico", "en_cotizacion", "en_trabajo"].includes(e),
    cotizar: puede("cotizaciones:cargar") && ["en_diagnostico", "en_cotizacion", "en_trabajo"].includes(e),
    iniciar:
      puede("ejecucion:iniciar") &&
      ["en_cotizacion", "en_diagnostico"].includes(e) &&
      (hayCotiz || t.value?.ot?.es_emergencia),
    avanzar: puede("ejecucion:avanzar") && e === "en_trabajo",
    pausar: puede("ejecucion:pausar") && e === "en_trabajo" && !pausada,
    reanudar: puede("ejecucion:pausar") && pausada,
    declarar: puede("ejecucion:declarar_trabajo") && e === "en_trabajo" && !pausada,
    revisar: puede("ot:revisar") && e === "trabajo_realizado",
    cerrar: puede("ot:cerrar") && e === "trabajo_realizado" && revisionAprobada,
    reabrir: puede("ot:reabrir") && e === "cerrada",
    derivar: puede("ot:derivar") && e !== "cancelada",
    cancelar: puede("ot:cancelar") && !["cerrada", "cancelada"].includes(e),
    prioridad: puede("ot:cambiar_prioridad") && !["cerrada", "cancelada"].includes(e),
  };
});

const hayAcciones = computed(() => Object.values(p.value).some(Boolean));

/**
 * El siguiente paso se deduce del estado real, no del rol: aunque quien mire no
 * pueda ejecutarlo, saber qué falta es información útil (y evita el clásico
 * "¿por qué no avanza esta OT?").
 */
const siguientePaso = computed(() => {
  const x = t.value;
  if (!x) return null;
  const e = x.ot.estado;

  if (e === "cancelada") return null;
  if (x.ot.condicion === "pausada") {
    return { tono: "espera", icono: Pause, titulo: "El trabajo está pausado. ", texto: "Mientras lo esté no se puede declarar realizado." };
  }
  if (["creada", "en_diagnostico"].includes(e) && !hayDiagnostico.value) {
    // La emergencia se salta la COTIZACIÓN, no el diagnóstico (Anexo A). Decirlo
    // aquí evita la pregunta de "es urgente, ¿por qué no me deja arrancar?".
    return x.ot.es_emergencia
      ? { tono: "espera", icono: Stethoscope, titulo: "Registre el diagnóstico para poder arrancar. ", texto: "Por ser emergencia podrá iniciar sin cotización, pero el diagnóstico es el paso que habilita el inicio." }
      : { tono: "info", icono: Stethoscope, titulo: "Falta el diagnóstico. ", texto: "La OT no pasa a cotización sin un diagnóstico vigente con sus cuatro campos técnicos." };
  }
  if (["en_diagnostico", "en_cotizacion"].includes(e) && !cotizacionVigente.value && !x.ot.es_emergencia) {
    return { tono: "info", icono: Coins, titulo: "Falta la cotización. ", texto: "El inicio normal del trabajo requiere una cotización vigente." };
  }
  if (["en_diagnostico", "en_cotizacion"].includes(e)) {
    return { tono: "espera", icono: Play, titulo: "Lista para iniciar. ", texto: "Asigne un responsable de ejecución para empezar." };
  }
  if (e === "en_trabajo") {
    return { tono: "", icono: Info, titulo: "En ejecución. ", texto: "Registre avances; al terminar, declare el trabajo realizado." };
  }
  if (e === "trabajo_realizado") {
    const aprobada = (x.cierre?.trabajo_realizado ?? []).some((w) => w.vigente && w.revision?.resultado === "aprobado");
    return aprobada
      ? { tono: "ok", icono: Lock, titulo: "Revisión aprobada. ", texto: "Se puede cerrar la OT." }
      : { tono: "espera", icono: ClipboardCheck, titulo: "Esperando revisión del coordinador. ", texto: "Debe aprobarse o devolverse con observaciones antes del cierre." };
  }
  if (e === "cerrada" && x.administrativo && x.administrativo.estado_consolidado !== "administracion_completa") {
    return { tono: "espera", icono: TriangleAlert, titulo: "Cerrada con pendiente administrativo. ", texto: `Sigue en ${etiqueta(x.administrativo.estado_consolidado).toLowerCase()}. Registrarlo no reabre la OT.` };
  }
  if (bloqueantes.value) {
    return { tono: "peligro", icono: GitBranch, titulo: `${bloqueantes.value} derivada(s) bloquean el cierre. `, texto: "El padre no cierra mientras sigan vivas." };
  }
  return null;
});

async function recargar() {
  try {
    t.value = (await otApi.obtener(id.value)).data;
    fijarTitulo(t.value?.ot?.numero ?? "OT");
  } catch (e) {
    t.value = null;
    await mostrarError(e, "No se pudo abrir la orden de trabajo");
  } finally {
    cargando.value = false;
  }
}

/**
 * Un solo sitio para los modales de acción: `mt` para los que piden un texto,
 * `me` para los que piden elegir. Cada uno lleva su propia función de confirmar,
 * que devuelve una promesa: si falla, el error se queda DENTRO del modal y lo
 * escrito no se pierde.
 */
const mt = ref(null);
const me = ref(null);

async function trasAccion(exito) {
  mt.value = null;
  me.value = null;
  if (exito) await notify.exito(exito);
  await recargar();
}

/** Lanza si la API responde ok:false, para que el modal muestre el motivo. */
async function exigirOk(promesa) {
  const r = await promesa;
  if (r && r.ok === false) throw new Error(r.error?.message ?? "No se pudo completar la acción.");
  return r;
}

/**
 * Iniciar exige SIEMPRE un responsable de ejecución, tanto en el flujo normal
 * como en emergencia (cap. 29.1). Se elige aquí en lugar de fallar después.
 */
async function iniciar() {
  let personas = [];
  try {
    personas = (await usuariosApi.asignables()).data ?? [];
  } catch (e) {
    return mostrarError(e, "No se pudo cargar la lista de responsables");
  }
  if (!personas.length) {
    return notify.aviso("No hay usuarios activos", "Cree o active un usuario para poder asignarlo como ejecutor.");
  }

  me.value = {
    titulo: "¿Quién ejecuta el trabajo?",
    subtitulo: t.value?.ot?.es_emergencia
      ? "Es una emergencia: puede iniciar sin cotización, pero la regularización queda pendiente."
      : "El inicio requiere una cotización vigente y su confirmación.",
    confirmarTexto: "Iniciar trabajo",
    opciones: personas.map((u) => ({ value: u.id, label: u.nombre, detalle: u.cargo ?? "" })),
    exito: "Trabajo iniciado",
    alConfirmar: ({ opcion }) => exigirOk(otApi.iniciar(id.value, { responsableId: opcion })),
  };
}

function registrarAvance() {
  mt.value = {
    titulo: "Registrar avance",
    subtitulo: "Cuente qué se hizo. El porcentaje es opcional.",
    label: "Qué se hizo",
    placeholder: "Ej. cabezal desmontado y enviado a rectificado",
    confirmarTexto: "Registrar",
    minimo: 5,
    conPorcentaje: true,
    exito: "Avance registrado",
    alConfirmar: ({ texto, porcentaje }) =>
      exigirOk(otApi.avance(id.value, { descripcion: texto, porcentaje })),
  };
}

function pausar() {
  mt.value = {
    titulo: "Pausar el trabajo",
    subtitulo:
      "Mientras esté pausada no se puede declarar el trabajo realizado. La pausa se reporta aparte: no se descuenta de la duración.",
    label: "Motivo de la pausa",
    placeholder: "Ej. esperando el eje del taller de rectificado",
    confirmarTexto: "Pausar",
    tono: "accion",
    minimo: 5,
    exito: "Trabajo pausado",
    alConfirmar: ({ texto }) => exigirOk(otApi.pausar(id.value, { motivoTexto: texto })),
  };
}

async function reanudar() {
  try {
    await otApi.reanudar(id.value, {});
    await trasAccion("Trabajo reanudado");
  } catch (e) {
    await mostrarError(e);
  }
}

function declarar() {
  mt.value = {
    titulo: "Declarar el trabajo realizado",
    subtitulo: "Describa el resultado final. El coordinador lo revisará antes del cierre.",
    label: "Resultado del trabajo",
    placeholder: "Ej. rodamiento reemplazado, alineado y probado 2 h sin fuga",
    confirmarTexto: "Declarar",
    tono: "accion",
    minimo: 10,
    alto: 120,
    exito: "Trabajo declarado",
    alConfirmar: ({ texto }) => exigirOk(otApi.declararTrabajo(id.value, { descripcion: texto })),
  };
}

function revisar() {
  me.value = {
    titulo: "Revisar el trabajo declarado",
    subtitulo: "Aprobar habilita el cierre. Devolver lo regresa a En trabajo con su observación.",
    confirmarTexto: "Registrar revisión",
    opciones: [
      { value: "aprobado", label: "Aprobar para el cierre", detalle: "El trabajo cumple con lo declarado." },
      {
        value: "correccion_solicitada",
        label: "Devolver con correcciones",
        detalle: "El ejecutor verá la observación y la OT volverá a En trabajo.",
        exigeTexto: true,
        labelTexto: "¿Qué hay que corregir?",
        minimo: 5,
      },
    ],
    exito: "Revisión registrada",
    alConfirmar: ({ opcion, texto }) =>
      exigirOk(otApi.revisar(id.value, { resultado: opcion, observacion: texto })),
  };
}

/**
 * Cerrar es el flujo con más matiz del producto.
 *
 * La API responde ok:false con `requiere_confirmacion` cuando hay pendientes
 * administrativos. Eso NO es un error: es el sistema pidiendo la constancia que
 * exige el cap. 31.2. Se traduce en un segundo modal, no en un mensaje de fallo.
 */
async function cerrar() {
  const r = await otApi.cerrar(id.value, {});
  if (r.ok) return trasAccion("Orden de trabajo cerrada");

  if (r.data?.requiere_confirmacion) {
    mt.value = {
      titulo: "Cerrar con el seguimiento administrativo pendiente",
      subtitulo: `Estado actual: ${etiqueta(r.data.estado_administrativo)}. Puede cerrar igualmente, pero debe dejar constancia del pendiente: quedará visible en las listas y en el tablero hasta que se resuelva.`,
      label: "Constancia del pendiente",
      placeholder: "Ej. Compras emite la OC esta semana",
      confirmarTexto: "Cerrar la OT",
      minimo: 10,
      exito: "Orden de trabajo cerrada",
      alConfirmar: ({ texto }) =>
        exigirOk(otApi.cerrar(id.value, { adminRevisado: true, observacionPendiente: texto })),
    };
    return;
  }
  return notify.error("No se pudo cerrar", r.error?.message ?? "");
}

function reabrir() {
  mt.value = {
    titulo: "Reabrir la orden de trabajo",
    subtitulo: "El cierre anterior se conserva íntegro. Explique por qué se reabre.",
    label: "Motivo de la reapertura",
    placeholder: "Ej. la fuga reapareció a los tres días",
    confirmarTexto: "Reabrir",
    minimo: 10,
    exito: "Orden de trabajo reabierta",
    alConfirmar: ({ texto }) => exigirOk(otApi.reabrir(id.value, { motivoTexto: texto })),
  };
}

function derivar() {
  mt.value = {
    titulo: "Crear una OT derivada",
    subtitulo:
      "Una derivada es para cuando el trabajo deja de ser una sola intervención: otra especialidad, otro proveedor, otro alcance. Para una nota basta un avance.",
    label: "Motivo de la derivación",
    placeholder: "Ej. el tablero requiere intervención eléctrica con otro proveedor",
    confirmarTexto: "Crear derivada",
    minimo: 10,
    alto: 110,
    alConfirmar: async ({ texto }) => {
      const r = await otApi.crearDerivada(id.value, { motivoDerivacion: texto });
      mt.value = null;
      await notify.exito("Derivada creada", `${r.data.numero_ot} · nivel ${r.data.nivel}`);
      router.push(`/ot/${r.data.id}`);
    },
  };
}

/**
 * Cancelar con derivadas activas: la API devuelve la lista y el usuario decide
 * qué hacer con ellas (cap. 25.3). No se decide por él.
 */
function cancelar() {
  mt.value = {
    titulo: "Cancelar la orden de trabajo",
    subtitulo: "La OT se conserva con todo su historial. Explique por qué se cancela.",
    label: "Motivo de la cancelación",
    placeholder: "Ej. el equipo se reemplaza completo, el alcance ya no aplica",
    confirmarTexto: "Cancelar la OT",
    peligro: true,
    minimo: 10,
    alConfirmar: async ({ texto }) => {
      const r = await otApi.cancelar(id.value, { observacion: texto });
      if (r.ok) {
        mt.value = null;
        return trasAccion("Orden de trabajo cancelada");
      }

      const activas = r.data?.derivadas_activas ?? [];
      if (!activas.length) throw new Error(r.error?.message ?? "No se pudo cancelar.");

      // Hay hijas vivas: se cierra este modal y se pide la decisión sobre ellas.
      mt.value = null;
      me.value = {
        titulo: `Esta OT tiene ${activas.length} derivada(s) activa(s)`,
        subtitulo: `Afecta a: ${activas.map((x) => `${x.numero} (${etiqueta(x.estado)})`).join(", ")}. Decida qué pasa con ellas antes de cancelar.`,
        confirmarTexto: "Cancelar la OT",
        opciones: [
          {
            value: "independizar",
            label: "Mantenerlas activas por su cuenta",
            detalle: "Siguen su curso como OT independientes; se conserva de quién venían.",
          },
          {
            value: "cancelar",
            label: "Cancelarlas también",
            detalle: "Se cancelan con el mismo motivo. No se puede deshacer.",
            peligro: true,
          },
        ],
        exito: "Orden de trabajo cancelada",
        alConfirmar: ({ opcion }) =>
          exigirOk(otApi.cancelar(id.value, { observacion: texto, tratamientoDerivadas: opcion })),
      };
    },
  };
}

function cambiarPrioridad() {
  const actual = t.value.ot.prioridad_tecnica;
  // Bajar una prioridad alta o cambiarla en ejecución exige motivo (cap. 25.4).
  const exigeMotivo = ["critica", "alta"].includes(actual) || t.value.ot.estado === "en_trabajo";

  me.value = {
    titulo: "Cambiar la prioridad técnica",
    subtitulo:
      "La prioridad que percibió el solicitante no cambia: son dos cosas distintas y ambas se conservan.",
    confirmarTexto: "Cambiar prioridad",
    opciones: ["critica", "alta", "media", "baja"]
      .filter((x) => x !== actual)
      .map((x) => ({
        value: x,
        label: etiqueta(x),
        detalle: x === actual ? "Actual" : "",
        exigeTexto: exigeMotivo,
        labelTexto: "¿Por qué cambia la prioridad?",
        minimo: 5,
      })),
    exito: "Prioridad actualizada",
    alConfirmar: ({ opcion, texto }) =>
      exigirOk(otApi.cambiarPrioridad(id.value, { prioridad: opcion, motivo: texto })),
  };
}

watch(id, () => {
  tab.value = "resumen";
  recargar();
});
onMounted(recargar);
</script>
