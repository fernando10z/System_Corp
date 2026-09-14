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
    lo primero que alguien busca meses después cuando pregunta "¿por qué se
    hizo así?".
  -->
  <div>
    <div class="fila fila-sep" style="margin-bottom: 14px">
      <div class="fila" style="gap: 14px">
        <span class="muted" style="font-size: 12px">
          {{ eventos.length }} {{ eventos.length === 1 ? "hecho registrado" : "hechos registrados" }}
        </span>
        <label class="fila" style="gap: 6px; font-size: 12px; cursor: pointer">
          <input type="checkbox" v-model="soloHitos" />
          Sólo hitos
        </label>
      </div>
      <span v-if="meta" class="mono muted" style="font-size: 11px">
        v{{ meta.version }} · {{ meta.total_nodos }} nodo(s) · profundidad {{ meta.profundidad_arbol }}
      </span>
    </div>

    <div v-if="!visibles.length" class="vacio">
      <div class="vacio-titulo">Todavía no hay sellos</div>
      <p class="vacio-texto">
        En cuanto la OT avance, cada acción quedará registrada aquí con su autor, su instante y su motivo.
      </p>
    </div>

    <div v-else class="viajera">
      <article v-for="e in visibles" :key="e.id" class="sello" :class="claseSello(e.evento)">
        <div class="sello-cab">
          <span class="sello-titulo">{{ nombreEvento(e.evento) }}</span>
          <span class="sello-meta">{{ fechaHora(e.fecha) }}</span>
          <span v-if="e.actor" class="sello-meta">· {{ e.actor }}</span>
        </div>

        <!-- Antes → después, en mono para poder compararlos de un vistazo. -->
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
</template>

<script setup>
import { computed, ref } from "vue";
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
