<template>
  <div style="max-width: 1000px">
    <PageHeader
      eyebrow="Configuración"
      title="Parámetros del sistema"
      subtitle="Lo que cambia entre empresas se ajusta aquí. El flujo operativo central no se configura: es el mismo para todos."
    >
      <template #acciones>
        <button v-if="hayCambios" class="btn" :disabled="guardando" @click="descartar">Descartar</button>
        <button class="btn primary" :disabled="!hayCambios || guardando" @click="guardar">
          <span v-if="guardando" class="spinner" />
          {{ guardando ? "Guardando…" : hayCambios ? `Guardar ${nCambios} cambio(s)` : "Sin cambios" }}
        </button>
      </template>
    </PageHeader>

    <Cargando v-if="cargando" texto="Cargando los parámetros…" />

    <div v-else class="pila">
      <!-- ── tiempos de respuesta ─────────────────────────────────────── -->
      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile amber"><Timer :size="14" /></span>
            Tiempos de primera respuesta
          </span>
        </div>
        <div class="card-cuerpo">
          <p class="muted" style="margin: 0 0 16px; font-size: 12.5px; max-width: 74ch">
            Cuánto debería tardar alguien en <b>tomar</b> una solicitud según la urgencia que percibió quien la
            reportó. Son objetivos para el tablero: <b>no bloquean nada</b> ni cierran solicitudes solas.
          </p>
          <div class="p-grid">
            <Campo
              v-for="p in PRIORIDADES"
              :key="p.clave"
              :label="p.label"
              :ayuda="legibleMinutos(valorSla(p.clave))"
            >
              <div class="p-num">
                <input
                  :value="valorSla(p.clave)"
                  type="number" min="1" class="input mono"
                  @input="fijarSla(p.clave, $event.target.value)"
                />
                <span class="p-unidad">minutos</span>
              </div>
            </Campo>
          </div>
        </div>
      </section>

      <!-- ── adjuntos ─────────────────────────────────────────────────── -->
      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile blue"><Paperclip :size="14" /></span>
            Tamaño máximo de los archivos
          </span>
        </div>
        <div class="card-cuerpo">
          <p class="muted" style="margin: 0 0 16px; font-size: 12.5px; max-width: 74ch">
            Lo que puede subir cada persona como evidencia. Súbalo si su gente manda fotos grandes; bájelo si el
            almacenamiento aprieta.
          </p>
          <div class="p-grid">
            <Campo v-for="a in ADJUNTOS" :key="a.clave" :label="a.label" :ayuda="a.ayuda">
              <div class="p-num">
                <input
                  :value="valorMb(a.clave)"
                  type="number" min="1" class="input mono"
                  @input="fijarMb(a.clave, $event.target.value)"
                />
                <span class="p-unidad">MB</span>
              </div>
            </Campo>
          </div>
        </div>
      </section>

      <!-- ── reglas del cierre ────────────────────────────────────────── -->
      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile"><ListChecks :size="14" /></span>
            Reglas de su organización
          </span>
        </div>
        <div class="card-cuerpo col" style="gap: 4px">
          <label v-for="b in BOOLEANOS" :key="b.clave" class="p-switch">
            <input type="checkbox" :checked="!!borrador[b.clave]" @change="fijar(b.clave, $event.target.checked)" />
            <span class="p-switch-texto">
              <b>{{ b.label }}</b>
              <small>{{ b.ayuda }}</small>
            </span>
          </label>
        </div>
      </section>

      <!-- ── seguridad ────────────────────────────────────────────────── -->
      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile red"><ShieldCheck :size="14" /></span>
            Acceso y contraseñas
          </span>
        </div>
        <div class="card-cuerpo">
          <p class="muted" style="margin: 0 0 16px; font-size: 12.5px; max-width: 74ch">
            Tras varios intentos fallidos seguidos la cuenta se bloquea sola durante un rato. Protege contra alguien
            probando contraseñas, venga de donde venga.
          </p>
          <div class="p-grid">
            <Campo label="Intentos antes de bloquear" ayuda="Fallos seguidos sobre la misma cuenta.">
              <div class="p-num">
                <input
                  :value="obj('bloqueo_credenciales', 'intentos', 5)"
                  type="number" min="3" max="20" class="input mono"
                  @input="fijarEn('bloqueo_credenciales', 'intentos', $event.target.value)"
                />
                <span class="p-unidad">intentos</span>
              </div>
            </Campo>
            <Campo label="Cuánto dura el bloqueo" ayuda="Después vuelve a poder entrar sola.">
              <div class="p-num">
                <input
                  :value="obj('bloqueo_credenciales', 'minutos', 15)"
                  type="number" min="1" max="1440" class="input mono"
                  @input="fijarEn('bloqueo_credenciales', 'minutos', $event.target.value)"
                />
                <span class="p-unidad">minutos</span>
              </div>
            </Campo>
          </div>
        </div>
      </section>

      <!-- ── formularios y análisis ───────────────────────────────────── -->
      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile violet"><SlidersHorizontal :size="14" /></span>
            Formularios y análisis
          </span>
        </div>
        <div class="card-cuerpo">
          <div class="p-grid">
            <Campo label="Título: mínimo de caracteres" ayuda="Evita títulos como “falla”.">
              <div class="p-num">
                <input :value="borrador.titulo_min_caracteres ?? 5" type="number" min="3" max="50" class="input mono"
                       @input="fijar('titulo_min_caracteres', Number($event.target.value))" />
                <span class="p-unidad">caracteres</span>
              </div>
            </Campo>
            <Campo label="Título: máximo de caracteres" ayuda="Un título no sustituye a la descripción.">
              <div class="p-num">
                <input :value="borrador.titulo_max_caracteres ?? 180" type="number" min="40" max="500" class="input mono"
                       @input="fijar('titulo_max_caracteres', Number($event.target.value))" />
                <span class="p-unidad">caracteres</span>
              </div>
            </Campo>
            <Campo
              label="Casos mínimos para publicar un promedio"
              ayuda="Con menos casos que esto, Costos muestra los registros pero NO calcula promedio: un promedio de dos casos engaña."
            >
              <div class="p-num">
                <input :value="obj('umbral_muestra_costos', 'minimo', 3)" type="number" min="1" max="50" class="input mono"
                       @input="fijarEn('umbral_muestra_costos', 'minimo', $event.target.value)" />
                <span class="p-unidad">casos</span>
              </div>
            </Campo>
          </div>
        </div>
      </section>

      <!-- ── lo que no se toca ────────────────────────────────────────── -->
      <section class="card">
        <div class="card-head">
          <span class="card-titulo">
            <span class="icon-tile neutral"><Lock :size="14" /></span>
            Lo que no se configura
          </span>
          <span class="muted" style="font-size: 12px">Es igual para todas las empresas</span>
        </div>
        <div class="card-cuerpo">
          <ul class="no-config">
            <li v-for="(n, i) in noConfigurable" :key="i"><Minus :size="13" />{{ n }}</li>
          </ul>
        </div>
      </section>

      <!--
        La salida de emergencia. Existe porque una clave nueva del backend
        aparecerá aquí antes de que haya un control amable para ella, y es mejor
        poder tocarla que quedarse esperando a una versión.
      -->
      <details class="card avanzado">
        <summary>
          <Code :size="14" />
          Valores en bruto
          <span class="muted" style="font-weight: 400">· para soporte técnico</span>
        </summary>
        <div class="card-cuerpo tabla-wrap" style="padding: 0">
          <table>
            <thead><tr><th>Clave</th><th>Valor</th></tr></thead>
            <tbody>
              <tr v-for="c in claves" :key="c">
                <td class="mono" style="font-weight: 600; color: var(--ink)">{{ c }}</td>
                <td><code class="valor">{{ JSON.stringify(borrador[c] ?? null) }}</code></td>
              </tr>
            </tbody>
          </table>
        </div>
      </details>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import {
  Code, ListChecks, Lock, Minus, Paperclip, ShieldCheck, SlidersHorizontal, Timer,
} from "lucide-vue-next";
import PageHeader from "../../../layouts/PageHeader.vue";
import Campo from "../../../shared/components/ui/Campo.vue";
import Cargando from "../../../shared/components/ui/Cargando.vue";
import { configuracionApi } from "../../shared/catalogos.api.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const PRIORIDADES = [
  { clave: "critica", label: "Crítica" },
  { clave: "alta", label: "Alta" },
  { clave: "media", label: "Media" },
  { clave: "baja", label: "Baja" },
];

const ADJUNTOS = [
  { clave: "imagen", label: "Fotos", ayuda: "Lo que manda la gente desde el móvil." },
  { clave: "pdf", label: "PDF", ayuda: "Cotizaciones, informes, fichas técnicas." },
  { clave: "documento", label: "Documentos", ayuda: "Word, Excel y similares." },
  { clave: "video", label: "Videos", ayuda: "Un ruido raro se entiende mejor en video." },
  { clave: "total_ot", label: "Total por OT", ayuda: "Suma de todo lo adjunto a una misma OT." },
];

const BOOLEANOS = [
  {
    clave: "exige_evidencia_cierre",
    label: "Exigir evidencias para cerrar una OT",
    ayuda: "Nadie podrá cerrar sin haber adjuntado al menos una foto o documento del trabajo terminado.",
  },
  {
    clave: "exige_conformidad",
    label: "Exigir la conformidad del solicitante",
    ayuda: "El cierre esperará a que quien reportó el problema confirme que quedó resuelto.",
  },
  {
    clave: "permite_derivada_no_bloqueante",
    label: "Permitir derivadas que no bloquean el cierre",
    ayuda: "Si lo apaga, toda OT derivada tendrá que resolverse antes de poder cerrar la principal.",
  },
];

const original = ref({});
const borrador = ref({});
const claves = ref([]);
const noConfigurable = ref([]);
const cargando = ref(true);
const guardando = ref(false);

const MB = 1024 * 1024;

/** Sólo se envían las claves que de verdad cambiaron. */
const cambiadas = computed(() =>
  claves.value.filter(
    (c) => JSON.stringify(borrador.value[c] ?? null) !== JSON.stringify(original.value[c] ?? null),
  ),
);
const hayCambios = computed(() => cambiadas.value.length > 0);
const nCambios = computed(() => cambiadas.value.length);

const obj = (clave, campo, porDefecto) => borrador.value[clave]?.[campo] ?? porDefecto;
const valorSla = (p) => obj("sla_primera_revision", p, 60);
const valorMb = (a) => Math.round((obj("limites_adjunto", a, 10 * MB) / MB) * 10) / 10;

function fijar(clave, valor) {
  borrador.value = { ...borrador.value, [clave]: valor };
}
function fijarEn(clave, campo, valor) {
  const n = Number(valor);
  if (!Number.isFinite(n)) return;
  fijar(clave, { ...(borrador.value[clave] ?? {}), [campo]: n });
}
const fijarSla = (p, v) => fijarEn("sla_primera_revision", p, v);

function fijarMb(a, v) {
  const n = Number(v);
  if (!Number.isFinite(n) || n <= 0) return;
  fijarEn("limites_adjunto", a, Math.round(n * MB));
}

/** "480 minutos" no dice nada; "8 horas" sí. */
function legibleMinutos(m) {
  const n = Number(m);
  if (!Number.isFinite(n)) return "";
  const conUnidad = (v, singular, plural) => `${v} ${v === 1 ? singular : plural}`;
  if (n < 60) return conUnidad(n, "minuto", "minutos");
  if (n < 1440) return conUnidad(Math.round((n / 60) * 10) / 10, "hora", "horas");
  return conUnidad(Math.round((n / 1440) * 10) / 10, "día", "días");
}

async function cargar() {
  cargando.value = true;
  try {
    const d = (await configuracionApi.obtener()).data;
    original.value = structuredClone(d.configuracion ?? {});
    borrador.value = structuredClone(d.configuracion ?? {});
    claves.value = d.claves_disponibles ?? [];
    noConfigurable.value = d.no_configurable ?? [];
  } catch (e) {
    await mostrarError(e, "No se pudo cargar la configuración");
  } finally {
    cargando.value = false;
  }
}

function descartar() {
  borrador.value = structuredClone(original.value);
}

async function guardar() {
  guardando.value = true;
  try {
    for (const clave of cambiadas.value) {
      await configuracionApi.guardar({ clave, valor: borrador.value[clave] });
    }
    await notify.exito(`${cambiadas.value.length} parámetro(s) guardado(s)`, "El cambio queda registrado en la auditoría.");
    await cargar();
  } catch (e) {
    await mostrarError(e, "No se pudieron guardar los parámetros");
  } finally {
    guardando.value = false;
  }
}

onMounted(cargar);
</script>

<style scoped>
.p-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(210px, 100%), 1fr)); gap: 16px 20px; }

.p-num { display: flex; align-items: center; gap: 8px; }
.p-num .input { width: 100px; }
.p-unidad { font-size: 12px; color: var(--ink-3); white-space: nowrap; }

.p-switch {
  display: flex; align-items: flex-start; gap: 11px;
  padding: 12px 14px; border-radius: var(--radius);
  border: 1px solid transparent; cursor: pointer; user-select: none;
  transition: background 0.12s, border-color 0.12s;
}
.p-switch:hover { background: var(--bg-soft); border-color: var(--line); }
.p-switch input { margin-top: 3px; accent-color: var(--emerald); width: 16px; height: 16px; cursor: pointer; }
.p-switch-texto { min-width: 0; line-height: 1.45; }
.p-switch-texto b { display: block; font-size: 13.5px; color: var(--ink); font-weight: 600; }
.p-switch-texto small { display: block; font-size: 12.5px; color: var(--ink-3); margin-top: 2px; }

.no-config { margin: 0; padding: 0; list-style: none; }
.no-config li {
  display: flex; align-items: flex-start; gap: 8px;
  font-size: 12.5px; color: var(--ink-2); padding: 6px 0; line-height: 1.5;
}
.no-config li svg { flex: none; margin-top: 3px; color: var(--ink-4); }

.avanzado { overflow: hidden; }
.avanzado summary {
  display: flex; align-items: center; gap: 9px;
  padding: 13px 18px; cursor: pointer;
  font-size: 13px; font-weight: 600; color: var(--ink-2);
  list-style: none;
}
.avanzado summary::-webkit-details-marker { display: none; }
.avanzado summary:hover { background: var(--bg-soft); }
.avanzado[open] summary { border-bottom: 1px solid var(--line-soft); }
.valor {
  font-family: var(--font-mono); font-size: 11.5px;
  background: var(--bg-soft); border: 1px solid var(--line-soft);
  padding: 3px 8px; border-radius: 5px; color: var(--ink-2);
}
</style>
