<template>
  <!--
    Buscador global. En una plataforma donde todo cuelga de un número de OT, lo
    que más se hace es "llévame a la OT-000148": tener que ir al listado,
    filtrar y hacer clic es tres pasos de más. Con ⌘K / Ctrl+K desde cualquier
    pantalla.
  -->
  <div ref="raiz" class="cmdk">
    <div class="cmdk-box" :class="{ activa: abierto }">
      <Search :size="14" />
      <input
        ref="campo"
        v-model="consulta"
        class="cmdk-input"
        type="text"
        placeholder="Buscar una OT, una solicitud o una pantalla…"
        autocomplete="off"
        spellcheck="false"
        aria-label="Buscar"
        @focus="abierto = true"
        @keydown.down.prevent="mover(1)"
        @keydown.up.prevent="mover(-1)"
        @keydown.enter.prevent="elegirActiva"
        @keydown.esc.prevent="cerrarYSalir"
      />
      <kbd class="cmdk-kbd">{{ atajo }}</kbd>
    </div>

    <Transition name="pop">
      <div v-if="abierto" ref="lista" class="cmdk-dropdown" role="listbox">
        <template v-if="pantallas.length">
          <div class="cmdk-grupo">Ir a</div>
          <button
            v-for="(it, i) in pantallas"
            :key="'nav-' + it.to"
            :class="['cmdk-item', i === activa ? 'activa' : '']"
            :data-idx="i"
            @mousemove="activa = i"
            @click="irA(it.to)"
          >
            <component :is="it.icono" :size="16" class="cmdk-icono" />
            <span class="cmdk-label">{{ it.label }}</span>
            <span class="cmdk-seccion">{{ it.seccion }}</span>
          </button>
        </template>

        <template v-if="ots.length">
          <div class="cmdk-grupo">Órdenes de trabajo</div>
          <button
            v-for="(o, i) in ots"
            :key="'ot-' + o.id"
            :class="['cmdk-item', pantallas.length + i === activa ? 'activa' : '']"
            :data-idx="pantallas.length + i"
            @mousemove="activa = pantallas.length + i"
            @click="irA(`/ot/${o.id}`)"
          >
            <ClipboardList :size="16" class="cmdk-icono" />
            <span class="cmdk-label">{{ o.titulo }}</span>
            <span class="cmdk-doc">{{ o.numero_ot }}</span>
          </button>
        </template>

        <template v-if="solicitudes.length">
          <div class="cmdk-grupo">Solicitudes</div>
          <button
            v-for="(s, i) in solicitudes"
            :key="'st-' + s.id"
            :class="['cmdk-item', pantallas.length + ots.length + i === activa ? 'activa' : '']"
            :data-idx="pantallas.length + ots.length + i"
            @mousemove="activa = pantallas.length + ots.length + i"
            @click="irA(`/solicitudes/${s.id}`)"
          >
            <Inbox :size="16" class="cmdk-icono" />
            <span class="cmdk-label">{{ s.titulo }}</span>
            <span class="cmdk-doc">{{ s.numero }}</span>
          </button>
        </template>

        <div v-if="!totalResultados" class="cmdk-vacio">
          <template v-if="buscando">Buscando…</template>
          <template v-else-if="consulta.trim()">Nada coincide con “{{ consulta.trim() }}”</template>
          <template v-else>Escriba un número de OT, un texto o el nombre de una pantalla</template>
        </div>

        <div class="cmdk-pie">
          <span><kbd>↑</kbd><kbd>↓</kbd> moverse</span>
          <span><kbd>↵</kbd> abrir</span>
          <span><kbd>Esc</kbd> cerrar</span>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useRouter } from "vue-router";
import { ClipboardList, Inbox, Search } from "lucide-vue-next";
import { itemsNavegables } from "../../config/navigation.js";
import { useAuth } from "../../composables/useAuth.js";
import { otApi } from "../../../modules/ot/api/ot.api.js";
import { solicitudesApi } from "../../../modules/solicitudes/api/solicitudes.api.js";

const router = useRouter();
const { puede } = useAuth();

const raiz = ref(null);
const campo = ref(null);
const lista = ref(null);
const abierto = ref(false);
const consulta = ref("");
const activa = ref(0);
const buscando = ref(false);

const ots = ref([]);
const solicitudes = ref([]);

let temporizador = null;
let testigo = 0;

const esMac = typeof navigator !== "undefined" && /Mac|iPhone|iPad/.test(navigator.platform || navigator.userAgent);
const atajo = esMac ? "⌘K" : "Ctrl K";

const navegables = computed(() => itemsNavegables(puede));

// Coincide por etiqueta, sección y palabras clave: buscar "compras" tiene que
// encontrar la pantalla de SOLPED aunque no se llame así.
const pantallas = computed(() => {
  const q = consulta.value.trim().toLowerCase();
  if (!q) return navegables.value.slice(0, 6);
  return navegables.value
    .filter((it) => {
      const heno = `${it.label} ${it.seccion} ${it.claves ?? ""}`.toLowerCase();
      return q.split(/\s+/).every((t) => heno.includes(t));
    })
    .slice(0, 6);
});

const totalResultados = computed(() => pantallas.value.length + ots.value.length + solicitudes.value.length);

function mover(d) {
  if (!totalResultados.value) return;
  activa.value = (activa.value + d + totalResultados.value) % totalResultados.value;
  nextTick(() => lista.value?.querySelector(`[data-idx="${activa.value}"]`)?.scrollIntoView({ block: "nearest" }));
}

function elegirActiva() {
  const i = activa.value;
  const nN = pantallas.value.length;
  const nO = ots.value.length;
  if (i < nN) return irA(pantallas.value[i]?.to);
  if (i < nN + nO) return irA(`/ot/${ots.value[i - nN]?.id}`);
  return irA(`/solicitudes/${solicitudes.value[i - nN - nO]?.id}`);
}

function irA(to) {
  if (!to) return;
  reiniciar();
  router.push(to);
}

function reiniciar() {
  abierto.value = false;
  consulta.value = "";
  ots.value = [];
  solicitudes.value = [];
  activa.value = 0;
  campo.value?.blur();
}

function cerrarYSalir() {
  abierto.value = false;
  campo.value?.blur();
}

// Búsqueda con espera; el testigo evita que una respuesta lenta pise a una nueva.
watch(consulta, (q) => {
  activa.value = 0;
  clearTimeout(temporizador);
  const termino = q.trim();
  if (termino.length < 2) {
    ots.value = [];
    solicitudes.value = [];
    buscando.value = false;
    return;
  }
  buscando.value = true;
  const mio = ++testigo;
  temporizador = setTimeout(async () => {
    try {
      const peticiones = [
        puede("ot:listar") ? otApi.listar({ buscar: termino, pageSize: 6 }) : Promise.resolve({ data: [] }),
        puede("solicitudes:listar")
          ? solicitudesApi.listar({ buscar: termino, pageSize: 5 })
          : Promise.resolve({ data: [] }),
      ];
      const [o, s] = await Promise.all(peticiones);
      if (mio !== testigo) return;
      ots.value = o.data ?? [];
      solicitudes.value = s.data ?? [];
    } catch {
      // El buscador es accesorio: si la API falla, el menú de pantallas sigue
      // sirviendo y no se interrumpe al usuario con un diálogo.
      if (mio === testigo) {
        ots.value = [];
        solicitudes.value = [];
      }
    } finally {
      if (mio === testigo) buscando.value = false;
    }
  }, 240);
});

function alPulsar(e) {
  if ((e.metaKey || e.ctrlKey) && (e.key === "k" || e.key === "K")) {
    e.preventDefault();
    if (abierto.value) return cerrarYSalir();
    abierto.value = true;
    nextTick(() => campo.value?.focus());
  }
}
function alClicFuera(e) {
  if (abierto.value && raiz.value && !raiz.value.contains(e.target)) abierto.value = false;
}

onMounted(() => {
  document.addEventListener("keydown", alPulsar);
  document.addEventListener("mousedown", alClicFuera);
});
onBeforeUnmount(() => {
  clearTimeout(temporizador);
  document.removeEventListener("keydown", alPulsar);
  document.removeEventListener("mousedown", alClicFuera);
});
</script>

<style scoped>
.cmdk { position: relative; display: inline-flex; }

.cmdk-box {
  display: flex; align-items: center; gap: 8px;
  width: 330px;
  background: var(--bg);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 6px 12px;
  color: var(--ink-4);
  transition: border-color 0.12s, box-shadow 0.12s, background 0.12s;
}
.cmdk-box:hover { border-color: var(--line-strong); }
.cmdk-box.activa {
  border-color: var(--emerald);
  background: var(--bg-elev);
  box-shadow: 0 0 0 3px var(--emerald-soft);
}
.cmdk-input { flex: 1; min-width: 0; border: none; outline: none; background: transparent; font-size: 13px; color: var(--ink); }
.cmdk-input::placeholder { color: var(--ink-4); }
.cmdk-kbd {
  font-family: var(--font-mono); font-size: 10.5px;
  background: var(--bg-elev); border: 1px solid var(--line);
  border-radius: 4px; padding: 1px 5px; color: var(--ink-3);
  font-weight: 500; flex-shrink: 0;
}

.cmdk-dropdown {
  position: absolute; top: calc(100% + 8px); right: 0;
  width: 440px; max-width: calc(100vw - 32px);
  background: var(--bg-elev);
  border: 1px solid var(--line);
  border-radius: 12px;
  box-shadow: var(--shadow-pop);
  display: flex; flex-direction: column;
  max-height: min(70vh, 480px);
  overflow-y: auto;
  z-index: 120; padding: 6px;
}

.cmdk-grupo {
  font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.06em;
  font-weight: 600; color: var(--ink-4); padding: 10px 10px 4px;
}
.cmdk-item {
  width: 100%; display: flex; align-items: center; gap: 11px;
  padding: 9px 10px; border: none; background: none;
  border-radius: 9px; cursor: pointer; text-align: left; color: var(--ink-2);
}
.cmdk-item.activa { background: var(--emerald-soft); }
.cmdk-icono { flex: 0 0 auto; color: var(--ink-3); }
.cmdk-item.activa .cmdk-icono { color: var(--emerald-deep); }
.cmdk-label { flex: 1; font-size: 13.5px; color: var(--ink); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.cmdk-seccion { font-size: 11px; color: var(--ink-4); white-space: nowrap; }
.cmdk-doc { font-family: var(--font-mono); font-size: 11.5px; color: var(--ink-3); white-space: nowrap; }

.cmdk-vacio { padding: 26px 16px; text-align: center; font-size: 13px; color: var(--ink-4); }

.cmdk-pie {
  display: flex; gap: 16px;
  padding: 9px 8px 4px; margin-top: 4px;
  border-top: 1px solid var(--line);
  font-size: 11px; color: var(--ink-4);
}
.cmdk-pie kbd {
  font-family: var(--font-mono); font-size: 10px;
  border: 1px solid var(--line); border-radius: 4px;
  padding: 0 4px; margin-right: 3px;
  color: var(--ink-3); background: var(--bg);
}

.pop-enter-active, .pop-leave-active { transition: opacity 0.14s ease, transform 0.14s ease; transform-origin: top right; }
.pop-enter-from, .pop-leave-to { opacity: 0; transform: translateY(-6px) scale(0.98); }

@media (max-width: 1080px) {
  .cmdk-box { width: 190px; }
  .cmdk-kbd { display: none; }
}

/* En móvil el buscador toma el hueco que sobra en vez de exigir un ancho fijo,
   que es lo que empujaba fuera al avatar y al botón de tema. */
@media (max-width: 700px) {
  .cmdk { flex: 1; min-width: 0; }
  .cmdk-box { width: 100%; min-width: 0; }
  .cmdk-dropdown { width: calc(100vw - 24px); right: -44px; }
}
</style>
