<template>
  <!--
    Selector de rango con atajos. Dos campos date sueltos obligan a abrir dos
    calendarios y a saber de antemano la fecha exacta; el 90 % de las veces lo
    que se quiere es "este mes" o "los últimos 30 días".
  -->
  <div ref="raiz" class="rf">
    <button type="button" class="rf-trigger" :class="{ activo: abierto, puesto: hayRango }" @click="alternar">
      <CalendarRange :size="14" />
      <span class="rf-label">{{ etiqueta }}</span>
      <ChevronDown :size="14" :class="['rf-chev', abierto ? 'girada' : '']" />
    </button>

    <Transition name="pop">
      <div v-if="abierto" class="rf-panel">
        <div class="rf-atajos">
          <button
            v-for="a in ATAJOS"
            :key="a.clave"
            type="button"
            :class="['rf-atajo', atajoActivo === a.clave ? 'activo' : '']"
            @click="aplicarAtajo(a)"
          >
            {{ a.label }}
          </button>
        </div>

        <div class="rf-cal">
          <div class="rf-cal-cab">
            <button type="button" class="rf-nav" title="Mes anterior" @click="mover(-1)"><ChevronLeft :size="15" /></button>
            <span class="rf-mes">{{ tituloMes }}</span>
            <button type="button" class="rf-nav" title="Mes siguiente" @click="mover(1)"><ChevronRight :size="15" /></button>
          </div>

          <div class="rf-dias">
            <span v-for="d in ['L','M','X','J','V','S','D']" :key="d" class="rf-dow">{{ d }}</span>
            <button
              v-for="(c, i) in celdas"
              :key="i"
              type="button"
              :class="['rf-dia', c.fuera ? 'fuera' : '', c.enRango ? 'rango' : '', c.esBorde ? 'borde' : '', c.hoy ? 'hoy' : '']"
              :disabled="!c.fecha"
              @click="elegir(c.fecha)"
            >
              {{ c.n }}
            </button>
          </div>

          <div class="rf-pie">
            <span class="rf-resumen">{{ resumen }}</span>
            <button type="button" class="btn sm plano" @click="limpiar">Limpiar</button>
            <button type="button" class="btn sm primary" @click="aplicar">Aplicar</button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, ref, watch } from "vue";
import { CalendarRange, ChevronDown, ChevronLeft, ChevronRight } from "lucide-vue-next";

const props = defineProps({
  /** ISO "YYYY-MM-DD" o "" */
  desde: { type: String, default: "" },
  hasta: { type: String, default: "" },
  placeholder: { type: String, default: "Todo el periodo" },
});
const emit = defineEmits(["update:desde", "update:hasta", "cambiar"]);

const iso = (d) => {
  const x = new Date(d);
  return `${x.getFullYear()}-${String(x.getMonth() + 1).padStart(2, "0")}-${String(x.getDate()).padStart(2, "0")}`;
};
const deIso = (s) => {
  if (!s) return null;
  const [a, m, d] = s.split("-").map(Number);
  return new Date(a, m - 1, d);
};

const abierto = ref(false);
const raiz = ref(null);
const borradorDesde = ref(props.desde);
const borradorHasta = ref(props.hasta);
const mesVista = ref(deIso(props.desde) ?? new Date());

const hayRango = computed(() => !!(props.desde || props.hasta));

const ATAJOS = [
  { clave: "hoy", label: "Hoy", calcular: () => { const h = new Date(); return [h, h]; } },
  { clave: "7d", label: "Últimos 7 días", calcular: () => [new Date(Date.now() - 6 * 86400000), new Date()] },
  { clave: "30d", label: "Últimos 30 días", calcular: () => [new Date(Date.now() - 29 * 86400000), new Date()] },
  { clave: "mes", label: "Este mes", calcular: () => { const h = new Date(); return [new Date(h.getFullYear(), h.getMonth(), 1), h]; } },
  { clave: "mesPasado", label: "Mes pasado", calcular: () => { const h = new Date(); return [new Date(h.getFullYear(), h.getMonth() - 1, 1), new Date(h.getFullYear(), h.getMonth(), 0)]; } },
  { clave: "anio", label: "Este año", calcular: () => { const h = new Date(); return [new Date(h.getFullYear(), 0, 1), h]; } },
];

/** Qué atajo describe el rango elegido, si alguno. Da contexto al reabrir. */
const atajoActivo = computed(() => {
  if (!borradorDesde.value || !borradorHasta.value) return "";
  return ATAJOS.find((a) => {
    const [d, h] = a.calcular();
    return iso(d) === borradorDesde.value && iso(h) === borradorHasta.value;
  })?.clave ?? "";
});

const fmtCorto = (s) => {
  const d = deIso(s);
  return d ? d.toLocaleDateString("es-PE", { day: "2-digit", month: "short", year: "numeric" }) : "";
};

const etiqueta = computed(() => {
  if (!props.desde && !props.hasta) return props.placeholder;
  if (props.desde && props.hasta) {
    const nombre = ATAJOS.find((a) => {
      const [d, h] = a.calcular();
      return iso(d) === props.desde && iso(h) === props.hasta;
    })?.label;
    return nombre ?? `${fmtCorto(props.desde)} – ${fmtCorto(props.hasta)}`;
  }
  return props.desde ? `Desde ${fmtCorto(props.desde)}` : `Hasta ${fmtCorto(props.hasta)}`;
});

const resumen = computed(() => {
  if (!borradorDesde.value && !borradorHasta.value) return "Sin rango";
  if (borradorDesde.value && borradorHasta.value) return `${fmtCorto(borradorDesde.value)} – ${fmtCorto(borradorHasta.value)}`;
  return borradorDesde.value ? `Desde ${fmtCorto(borradorDesde.value)}` : `Hasta ${fmtCorto(borradorHasta.value)}`;
});

const tituloMes = computed(() =>
  mesVista.value.toLocaleDateString("es-PE", { month: "long", year: "numeric" }).replace(/^./, (c) => c.toUpperCase()),
);

/** Rejilla del mes, empezando en lunes. */
const celdas = computed(() => {
  const base = mesVista.value;
  const primero = new Date(base.getFullYear(), base.getMonth(), 1);
  const ultimo = new Date(base.getFullYear(), base.getMonth() + 1, 0);
  const hoyIso = iso(new Date());
  const arranque = (primero.getDay() + 6) % 7; // lunes = 0
  const out = [];
  for (let i = 0; i < arranque; i++) out.push({ n: "", fecha: null, fuera: true });
  for (let d = 1; d <= ultimo.getDate(); d++) {
    const f = iso(new Date(base.getFullYear(), base.getMonth(), d));
    const dentro =
      borradorDesde.value && borradorHasta.value && f >= borradorDesde.value && f <= borradorHasta.value;
    out.push({
      n: d,
      fecha: f,
      fuera: false,
      enRango: !!dentro,
      esBorde: f === borradorDesde.value || f === borradorHasta.value,
      hoy: f === hoyIso,
    });
  }
  return out;
});

function alternar() {
  abierto.value = !abierto.value;
  if (abierto.value) {
    borradorDesde.value = props.desde;
    borradorHasta.value = props.hasta;
    mesVista.value = deIso(props.desde) ?? new Date();
    document.addEventListener("mousedown", alClicFuera);
  } else {
    document.removeEventListener("mousedown", alClicFuera);
  }
}
function cerrar() {
  abierto.value = false;
  document.removeEventListener("mousedown", alClicFuera);
}
function alClicFuera(e) {
  if (raiz.value && !raiz.value.contains(e.target)) cerrar();
}

function mover(n) {
  mesVista.value = new Date(mesVista.value.getFullYear(), mesVista.value.getMonth() + n, 1);
}

/** El primer clic fija el inicio; el segundo cierra el rango. */
function elegir(f) {
  if (!f) return;
  if (!borradorDesde.value || (borradorDesde.value && borradorHasta.value)) {
    borradorDesde.value = f;
    borradorHasta.value = "";
    return;
  }
  if (f < borradorDesde.value) {
    borradorHasta.value = borradorDesde.value;
    borradorDesde.value = f;
  } else {
    borradorHasta.value = f;
  }
}

function aplicarAtajo(a) {
  const [d, h] = a.calcular();
  borradorDesde.value = iso(d);
  borradorHasta.value = iso(h);
  mesVista.value = new Date(h.getFullYear(), h.getMonth(), 1);
}

function aplicar() {
  // Un rango a medio elegir se cierra sobre sí mismo: un solo día.
  const d = borradorDesde.value;
  const h = borradorHasta.value || borradorDesde.value;
  emit("update:desde", d);
  emit("update:hasta", h);
  emit("cambiar", { desde: d, hasta: h });
  cerrar();
}

function limpiar() {
  borradorDesde.value = "";
  borradorHasta.value = "";
  emit("update:desde", "");
  emit("update:hasta", "");
  emit("cambiar", { desde: "", hasta: "" });
  cerrar();
}

watch(() => [props.desde, props.hasta], ([d, h]) => {
  borradorDesde.value = d;
  borradorHasta.value = h;
});
onBeforeUnmount(() => document.removeEventListener("mousedown", alClicFuera));
</script>

<style scoped>
.rf { position: relative; display: inline-flex; }

.rf-trigger {
  display: inline-flex; align-items: center; gap: 8px;
  height: 34px; padding: 0 11px;
  background: var(--bg-elev); border: 1px solid var(--line);
  border-radius: 8px; color: var(--ink-3);
  font-family: inherit; font-size: 13px; cursor: pointer;
  transition: border-color 0.12s, box-shadow 0.12s;
  white-space: nowrap;
}
.rf-trigger:hover { border-color: var(--line-strong); }
.rf-trigger.activo { border-color: var(--emerald); box-shadow: 0 0 0 3px var(--emerald-soft); }
.rf-trigger.puesto { background: var(--emerald-soft); border-color: var(--emerald-line); color: var(--emerald-ink); font-weight: 600; }
.rf-label { color: inherit; }
.rf-chev { flex-shrink: 0; transition: transform 0.18s ease; }
.rf-chev.girada { transform: rotate(180deg); }

.rf-panel {
  position: absolute; top: calc(100% + 6px); left: 0;
  display: flex; z-index: 90;
  background: var(--bg-elev); border: 1px solid var(--line);
  border-radius: 12px; box-shadow: var(--shadow-lg);
  overflow: hidden;
}

.rf-atajos {
  display: flex; flex-direction: column; gap: 2px;
  padding: 8px; min-width: 156px;
  border-right: 1px solid var(--line-soft);
  background: var(--bg-soft);
}
.rf-atajo {
  text-align: left; padding: 7px 10px;
  border: 0; background: transparent; border-radius: 7px;
  font-family: inherit; font-size: 12.5px; color: var(--ink-2); cursor: pointer;
  white-space: nowrap;
}
.rf-atajo:hover { background: var(--bg-elev); color: var(--ink); }
.rf-atajo.activo { background: var(--emerald-soft); color: var(--emerald-ink); font-weight: 600; }

.rf-cal { padding: 10px 12px 12px; }
.rf-cal-cab { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 8px; }
.rf-mes { font-size: 13px; font-weight: 600; }
.rf-nav {
  width: 26px; height: 26px; border-radius: 6px;
  border: 1px solid transparent; background: transparent;
  display: grid; place-items: center; color: var(--ink-3); cursor: pointer;
}
.rf-nav:hover { background: var(--bg-soft); border-color: var(--line); color: var(--ink); }

.rf-dias { display: grid; grid-template-columns: repeat(7, 32px); gap: 2px; }
.rf-dow {
  display: grid; place-items: center; height: 24px;
  font-size: 10px; font-weight: 600; color: var(--ink-4);
  text-transform: uppercase; letter-spacing: 0.04em;
}
.rf-dia {
  height: 30px; border: 0; background: transparent; border-radius: 6px;
  font-family: var(--font-mono); font-size: 12px; color: var(--ink-2); cursor: pointer;
}
.rf-dia:hover:not(:disabled) { background: var(--bg-soft); color: var(--ink); }
.rf-dia.fuera { visibility: hidden; }
.rf-dia.hoy { font-weight: 700; color: var(--emerald-deep); }
.rf-dia.rango { background: var(--emerald-soft); color: var(--emerald-ink); border-radius: 0; }
.rf-dia.borde {
  background: var(--emerald); color: #fff; font-weight: 700; border-radius: 6px;
}

.rf-pie {
  display: flex; align-items: center; gap: 8px;
  margin-top: 10px; padding-top: 10px;
  border-top: 1px solid var(--line-soft);
}
.rf-resumen { flex: 1; font-size: 11.5px; color: var(--ink-3); font-variant-numeric: tabular-nums; }

.pop-enter-active, .pop-leave-active { transition: opacity 0.14s ease, transform 0.14s ease; transform-origin: top left; }
.pop-enter-from, .pop-leave-to { opacity: 0; transform: translateY(-4px) scale(0.98); }
</style>
