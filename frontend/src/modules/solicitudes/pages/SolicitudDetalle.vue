<template>
  <div>
    <Cargando v-if="cargando" texto="Abriendo la solicitud…" />

    <template v-else-if="s">
      <!-- La cabecera lleva el galón del estado: se reconoce sin leer. -->
      <header class="ficha-head" :style="{ '--galon': galon }">
        <div class="ficha-top">
          <div class="ficha-id">
            <div class="fila" style="gap: 10px; margin-bottom: 8px">
              <router-link to="/solicitudes" class="row-action" title="Volver al listado">
                <ArrowLeft :size="15" />
              </router-link>
              <span class="eyebrow">Solicitud</span>
            </div>
            <div class="ficha-numero">{{ s.numero }}</div>
            <p class="ficha-titulo">{{ s.titulo }}</p>
            <div class="ficha-marcas">
              <span class="estado-pill" :class="tonoSolicitud(s.estado)"><span class="dot" />{{ etiqueta(s.estado) }}</span>
              <span v-if="s.prioridad_percibida" class="tag">
                Percibida: {{ etiqueta(s.prioridad_percibida) }}
              </span>
              <span v-if="s.impacto" class="tag">{{ s.impacto }}</span>
            </div>
          </div>

          <div class="ficha-cifras">
            <div class="qs">
              <div class="ql">Enviada</div>
              <div class="qv" style="font-size: 15px">{{ desde(s.fecha_envio) }}</div>
            </div>
            <div v-if="s.ot" class="qs">
              <div class="ql">OT generada</div>
              <div class="qv ok mono" style="font-size: 17px">{{ s.ot.numero }}</div>
            </div>
          </div>
        </div>
      </header>

      <!--
        Las acciones se ofrecen según el ESTADO, no según el rol: mostrar
        "Aceptar" en una solicitud ya convertida sería ofrecer un imposible.
      -->
      <div v-if="hayAcciones" class="ficha-acciones">
        <template v-if="p.decidir">
          <button v-if="s.estado === 'enviada'" class="btn accion" @click="tomar">
            <Hand :size="14" /> Tomar la revisión
          </button>
          <template v-if="s.estado === 'en_revision'">
            <button class="btn primary" @click="modalOt = true"><Check :size="14" /> Aceptar y crear OT</button>
            <button class="btn" @click="decidir('observar')"><MessageCircleQuestion :size="14" /> Observar</button>
            <button class="btn peligro" @click="decidir('rechazar')"><X :size="14" /> Rechazar</button>
          </template>
        </template>
        <button v-if="p.enviar" class="btn primary" @click="enviar"><Send :size="14" /> Enviar</button>
      </div>

      <!--
        Dos columnas: a la izquierda lo que hay que LEER —el reporte y las
        decisiones—, a la derecha los datos de referencia. Antes todo iba en una
        columna estrecha y sobraba media pantalla a la derecha.
      -->
      <div class="st-grid">
        <div class="pila">
        <section class="card">
          <div class="card-head">
            <span class="card-titulo">
              <span class="icon-tile neutral"><FileText :size="14" /></span>
              Reporte original
            </span>
            <span class="muted" style="font-size: 12px">Se conserva tal cual, diga lo que diga el diagnóstico</span>
          </div>
          <div class="card-cuerpo">
            <p style="white-space: pre-wrap; margin: 0; line-height: 1.65; font-size: 14px">{{ s.descripcion }}</p>
          </div>
        </section>

        <section v-if="s.ot" class="card">
          <div class="card-head">
            <span class="card-titulo">
              <span class="icon-tile"><ClipboardList :size="14" /></span>
              Orden de trabajo generada
            </span>
            <router-link class="btn sm" :to="`/ot/${s.ot.id}`">Abrir la OT <ArrowRight :size="13" /></router-link>
          </div>
          <div class="card-cuerpo fila" style="gap: 12px">
            <span class="mono" style="font-weight: 600; font-size: 15px">{{ s.ot.numero }}</span>
            <EstadoOt :estado="s.ot.estado" :admin="s.ot.estado_administrativo" />
          </div>
        </section>

        <!--
          Cada decisión queda registrada con su motivo: es lo que permite
          entender después por qué esta solicitud acabó como acabó.
        -->
        <section v-if="(s.decisiones ?? []).length" class="card">
          <div class="card-head">
            <span class="card-titulo">
              <span class="icon-tile neutral"><History :size="14" /></span>
              Decisiones
            </span>
          </div>
          <div class="card-cuerpo">
            <div class="viajera">
              <article
                v-for="(dec, i) in s.decisiones"
                :key="i"
                class="sello"
                :class="dec.tipo === 'aceptar' ? 'cierre' : dec.tipo === 'rechazar' ? 'alerta' : ''"
              >
                <div class="sello-cab">
                  <span class="sello-titulo">{{ etiqueta(dec.tipo) }}</span>
                  <span class="sello-meta">{{ fechaHora(dec.fecha) }}</span>
                  <span v-if="dec.actor" class="sello-meta">· {{ dec.actor }}</span>
                </div>
                <div v-if="dec.estado_anterior" class="sello-cambio">
                  <span class="antes">{{ etiqueta(dec.estado_anterior) }}</span>
                  <span class="flecha">→</span>
                  <span class="despues">{{ etiqueta(dec.estado_nuevo) }}</span>
                </div>
                <div v-if="dec.comentario || dec.motivo" class="sello-motivo">
                  <b>{{ dec.motivo ? "Motivo" : "Comentario" }}</b>{{ dec.motivo ?? dec.comentario }}
                </div>
              </article>
            </div>
          </div>
        </section>
        </div>

        <aside class="pila">
          <section class="card">
            <div class="card-head">
              <span class="card-titulo">
                <span class="icon-tile neutral"><Info :size="14" /></span>
                Datos del reporte
              </span>
            </div>
            <div class="card-cuerpo col" style="gap: 14px">
              <div><div class="def-k">Lugar</div><div class="def-v">{{ s.lugar }}</div></div>
              <div><div class="def-k">Área</div><div class="def-v">{{ s.area?.nombre ?? "—" }}</div></div>
              <div><div class="def-k">Solicitante</div><div class="def-v">{{ s.solicitante?.nombre ?? "—" }}</div></div>
              <div><div class="def-k">Impacto en la operación</div><div class="def-v">{{ s.impacto ?? "Sin indicar" }}</div></div>
              <div>
                <div class="def-k">Prioridad percibida</div>
                <div class="def-v">
                  <span v-if="s.prioridad_percibida" class="prio" :class="'p-' + s.prioridad_percibida">
                    {{ etiqueta(s.prioridad_percibida) }}
                  </span>
                  <span v-else class="mas-muted">Sin indicar</span>
                </div>
              </div>
              <div><div class="def-k">Enviada</div><div class="def-v mono">{{ fechaHora(s.fecha_envio) }}</div></div>
              <div v-if="s.fecha_primera_revision">
                <div class="def-k">Primera revisión</div>
                <div class="def-v mono">{{ fechaHora(s.fecha_primera_revision) }}</div>
              </div>
            </div>
          </section>

          <section class="card">
            <div class="card-head">
              <span class="card-titulo">
                <span class="icon-tile neutral"><Paperclip :size="14" /></span>
                Evidencias
                <span class="head-meta">{{ (s.adjuntos ?? []).length }}</span>
              </span>
            </div>
            <div class="card-cuerpo">
              <ul v-if="(s.adjuntos ?? []).length" class="ev-lista">
                <li v-for="a in s.adjuntos" :key="a.id">
                  <!-- Una evidencia que no se puede abrir no es evidencia. -->
                  <button type="button" class="ev-item" :disabled="abriendo === a.id" @click="abrirEvidencia(a)">
                    <span v-if="abriendo === a.id" class="spinner" />
                    <FileText v-else :size="14" class="mas-muted" />
                    <span class="truncar">{{ a.nombre_original ?? a.nombre ?? "Archivo" }}</span>
                  </button>
                </li>
              </ul>
              <p v-else class="muted" style="margin: 0; font-size: 12.5px">
                El solicitante no adjuntó evidencias.
              </p>
            </div>
          </section>
        </aside>
      </div>

      <CrearOtModal
        :abierto="modalOt"
        :solicitud="s"
        @cerrar="modalOt = false"
        @creada="(ot) => $router.push(`/ot/${ot.id}`)"
      />
    </template>

    <Vacio
      v-else
      :icono="SearchX"
      titulo="No encontramos esa solicitud"
      texto="Puede que se haya retirado o que no esté dentro de su alcance."
    >
      <router-link class="btn" to="/solicitudes">Volver al listado</router-link>
    </Vacio>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import {
  ArrowLeft, ArrowRight, Check, ClipboardList, FileText, Hand, History, Info,
  MessageCircleQuestion, Paperclip, SearchX, Send, X,
} from "lucide-vue-next";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import Vacio from "../../../shared/components/ui/Vacio.vue";
import EstadoOt from "../../../shared/components/ui/EstadoOt.vue";
import CrearOtModal from "../components/CrearOtModal.vue";
import { solicitudesApi } from "../api/solicitudes.api.js";
import { urlDeAdjunto } from "../../../shared/api/adjuntos.api.js";
import { useAuth } from "../../../shared/composables/useAuth.js";
import { useTitulo } from "../../../shared/composables/useTitulo.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";
import { desde, etiqueta, fechaHora, tonoSolicitud } from "../../../shared/utils/formato.js";

const route = useRoute();
const { puede, usuario } = useAuth();
const { fijar: fijarTitulo } = useTitulo();

const s = ref(null);
const cargando = ref(true);
const modalOt = ref(false);
const abriendo = ref("");

/**
 * La URL del almacén es temporal y se pide en el momento de abrir: no se deja
 * caducando en la pantalla ni se expone el archivo más tiempo del necesario.
 */
async function abrirEvidencia(a) {
  abriendo.value = a.id;
  try {
    const { url } = await urlDeAdjunto(a.id);
    window.open(url, "_blank", "noopener");
  } catch (e) {
    mostrarError(e, "No se pudo abrir la evidencia");
  } finally {
    abriendo.value = "";
  }
}

const p = computed(() => ({
  decidir: puede("solicitudes:decidir"),
  enviar: ["borrador", "observada"].includes(s.value?.estado) && s.value?.solicitante?.id === usuario.value?.id,
}));

const hayAcciones = computed(
  () => p.value.enviar || (p.value.decidir && ["enviada", "en_revision"].includes(s.value?.estado)),
);

const galon = computed(() => {
  const t = tonoSolicitud(s.value?.estado);
  return { ok: "var(--emerald)", warn: "var(--amber)", danger: "var(--red)", violet: "var(--violet)" }[t] ?? "var(--line-strong)";
});

async function cargar() {
  cargando.value = true;
  try {
    s.value = (await solicitudesApi.obtener(route.params.id)).data;
    // La barra superior lee este título para la última miga.
    fijarTitulo(s.value?.numero ?? "Solicitud");
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
      texto: "El solicitante verá este texto tal cual.",
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

onMounted(cargar);
</script>

<style scoped>
/* La columna de lectura manda; la de referencia acompaña y no la estrecha. */
.st-grid { display: grid; grid-template-columns: minmax(0, 1.9fr) minmax(300px, 1fr); gap: var(--gap-paneles); }
@media (max-width: 1100px) { .st-grid { grid-template-columns: 1fr; } }

.ev-lista { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 6px; }
.ev-item {
  display: flex; align-items: center; gap: 8px; width: 100%;
  padding: 7px 10px; border-radius: var(--radius-sm);
  background: var(--bg-soft); border: 1px solid var(--line);
  font-size: 12.5px; color: var(--ink-2); text-align: left;
  cursor: pointer; transition: border-color 0.12s, background 0.12s;
}
.ev-item:hover:not(:disabled) { border-color: var(--emerald); background: var(--emerald-soft); color: var(--emerald-ink); }
.ev-item:disabled { cursor: progress; }
</style>
