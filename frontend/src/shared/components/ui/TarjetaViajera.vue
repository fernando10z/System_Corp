<template>
  <!--
    LA TARJETA VIAJERA
    ------------------------------------------------------------------------
    En un taller, cada trabajo lleva una tarjeta física que lo acompaña y se
    sella en cada estación: quién lo tocó, cuándo y por qué. Eso es exactamente
    lo que guarda la columna `trazabilidad` de la OT, así que aquí se dibuja
    como lo que es.

    Cada sello es un hecho de la bitácora append-only. El motivo se resalta
    porque es lo que el documento exige conservar en toda acción sensible, y es
    lo primero que alguien busca meses después preguntando "¿por qué se hizo
    así?".
  -->
  <section class="card">
    <header class="card-head">
      <span class="card-titulo">
        <span class="icon-tile"><Stamp :size="14" /></span>
        Tarjeta viajera
        <span class="head-meta">{{ eventos.length }}</span>
      </span>
      <div class="fila" style="gap: 12px">
        <div class="toggle-group">
          <button :class="{ active: !soloHitos }" @click="soloHitos = false">Todo</button>
          <button :class="{ active: soloHitos }" @click="soloHitos = true">Sólo hitos</button>
        </div>
        <span v-if="meta" class="mono muted" style="font-size: 11px">
          v{{ meta.version }} · {{ meta.total_nodos }} nodo(s) · prof. {{ meta.profundidad_arbol }}
        </span>
      </div>
    </header>

    <div class="card-cuerpo">
      <Vacio
        v-if="!visibles.length"
        :icono="Stamp"
        titulo="Todavía no hay sellos"
        texto="En cuanto la OT avance, cada acción quedará registrada aquí con su autor, su instante y su motivo."
      />

      <div v-else class="viajera">
        <article v-for="e in visibles" :key="e.id" class="sello" :class="claseSello(e.evento)">
          <div class="sello-cab">
            <span class="sello-titulo">{{ nombreEvento(e.evento) }}</span>
            <span class="sello-meta">{{ fechaHora(e.fecha) }}</span>
            <span v-if="e.actor" class="sello-meta">· {{ e.actor }}</span>
          </div>

          <!-- Antes → después, en mono para compararlos de un vistazo. -->
          <div v-if="cambio(e)" class="sello-cambio">
            <span class="antes">{{ cambio(e).antes }}</span>
            <span class="flecha">→</span>
            <span class="despues">{{ cambio(e).despues }}</span>
          </div>

          <div v-else-if="resumen(e)" class="sello-cuerpo">{{ resumen(e) }}</div>

          <div v-if="e.motivo" class="sello-motivo">
            <b>Motivo</b>
            {{ e.motivo }}
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, ref } from "vue";
import { Stamp } from "lucide-vue-next";
import Vacio from "./Vacio.vue";
import { claseSello, etiqueta, fechaHora, nombreEvento } from "../../utils/formato.js";

const props = defineProps({
  eventos: { type: Array, default: () => [] },
  meta: { type: Object, default: null },
});

const soloHitos = ref(false);

const visibles = computed(() => {
  const orden = [...props.eventos].sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
  if (!soloHitos.value) return orden;
  return orden.filter((e) => ["hito", "cierre", "alerta"].includes(claseSello(e.evento)));
});

/**
 * Muchos eventos guardan `anterior` y `nuevo` con la misma clave (estado,
 * prioridad_tecnica, numero_sap…). Cuando coinciden, se muestra el cambio; si
 * no, se cae al resumen genérico.
 */
function cambio(e) {
  const a = e.anterior ?? null;
  const n = e.nuevo ?? null;
  if (!a || !n) return null;
  const clave = Object.keys(a).find((k) => k in n && a[k] !== n[k]);
  if (!clave) return null;
  return { antes: etiqueta(String(a[clave])), despues: etiqueta(String(n[clave])) };
}

/** Resumen legible de `nuevo` para los eventos que no son un cambio de valor. */
function resumen(e) {
  const n = e.nuevo;
  if (!n || typeof n !== "object") return "";
  const partes = [];
  for (const [k, v] of Object.entries(n)) {
    if (v === null || v === undefined || typeof v === "object") continue;
    partes.push(`${etiqueta(k)}: ${typeof v === "boolean" ? (v ? "sí" : "no") : v}`);
  }
  return partes.slice(0, 4).join(" · ");
}
</script>
