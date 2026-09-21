<template>
  <!--
    Editar permisos es revisar cuarenta y tantas casillas agrupadas por módulo.
    Eso no cabe en un diálogo: cabe en un panel lateral, donde se puede buscar,
    marcar un módulo entero y ver cuántos van seleccionados sin perder de vista
    el rol que se está editando.
  -->
  <Drawer
    :abierto="abierto"
    :titulo="rol ? `Permisos de ${rol.nombre}` : 'Permisos'"
    :subtitulo="rol ? `${seleccionados.size} de ${permisos.length} permisos · ${rol.usuarios} usuario(s) afectado(s)` : ''"
    :ancho="520"
    @cerrar="$emit('cerrar')"
  >
    <div class="fil grow" style="width: 100%; margin-bottom: 14px">
      <Search :size="14" />
      <input v-model.trim="filtro" placeholder="Filtrar permisos…" />
    </div>

    <div v-for="(ps, modulo) in porModulo" :key="modulo" class="modulo">
      <div class="modulo-cab">
        <span class="def-k" style="margin: 0">{{ modulo }}</span>
        <span class="crecer" />
        <span class="mas-muted mono" style="font-size: 10.5px">{{ marcadosEn(ps) }}/{{ ps.length }}</span>
        <button class="link-mini" @click="alternarModulo(ps)">
          {{ marcadosEn(ps) === ps.length ? "Ninguno" : "Todos" }}
        </button>
      </div>

      <label v-for="p in ps" :key="p.codigo" class="permiso" :class="{ marcado: seleccionados.has(p.codigo) }">
        <input
          type="checkbox"
          :checked="seleccionados.has(p.codigo)"
          @change="alternar(p.codigo)"
        />
        <span class="permiso-texto">
          <b class="mono">{{ p.accion }}</b>
          <small>{{ p.descripcion ?? "" }}</small>
        </span>
      </label>
    </div>

    <p v-if="!Object.keys(porModulo).length" class="muted" style="font-size: 12.5px; text-align: center; padding: 24px">
      Ningún permiso coincide con “{{ filtro }}”.
    </p>

    <template #acciones>
      <span class="crecer muted" style="font-size: 12px">El cambio queda registrado en la auditoría.</span>
      <button class="btn" :disabled="guardando" @click="$emit('cerrar')">Cancelar</button>
      <button class="btn primary" :disabled="guardando || !haCambiado" @click="guardar">
        <span v-if="guardando" class="spinner" />
        {{ guardando ? "Guardando…" : "Guardar" }}
      </button>
    </template>
  </Drawer>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import { Search } from "lucide-vue-next";
import Drawer from "../../../shared/components/ui/Drawer.vue";
import { rolesApi } from "../../shared/catalogos.api.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const props = defineProps({
  abierto: { type: Boolean, required: true },
  rol: { type: Object, default: null },
  permisos: { type: Array, default: () => [] },
});
const emit = defineEmits(["cerrar", "guardado"]);

const seleccionados = ref(new Set());
const inicial = ref("");
const filtro = ref("");
const guardando = ref(false);

const porModulo = computed(() => {
  const q = filtro.value.toLowerCase();
  return props.permisos
    .filter((p) => !q || `${p.codigo} ${p.modulo} ${p.accion} ${p.descripcion ?? ""}`.toLowerCase().includes(q))
    .reduce((acc, p) => ((acc[p.modulo] ??= []).push(p), acc), {});
});

/** Comparar conjuntos ordenados evita guardar cuando nada cambió. */
const haCambiado = computed(() => [...seleccionados.value].sort().join(",") !== inicial.value);

function marcadosEn(ps) {
  return ps.filter((p) => seleccionados.value.has(p.codigo)).length;
}

function alternar(codigo) {
  const s = new Set(seleccionados.value);
  s.has(codigo) ? s.delete(codigo) : s.add(codigo);
  seleccionados.value = s;
}

function alternarModulo(ps) {
  const todos = marcadosEn(ps) === ps.length;
  const s = new Set(seleccionados.value);
  ps.forEach((p) => (todos ? s.delete(p.codigo) : s.add(p.codigo)));
  seleccionados.value = s;
}

watch(
  () => props.abierto,
  (v) => {
    if (!v) return;
    const actuales = props.rol?.permisos ?? [];
    seleccionados.value = new Set(actuales);
    inicial.value = [...actuales].sort().join(",");
    filtro.value = "";
  },
);

async function guardar() {
  guardando.value = true;
  try {
    await rolesApi.asignarPermisos(props.rol.id, [...seleccionados.value]);
    await notify.exito("Permisos actualizados", "El cambio queda registrado en la auditoría.");
    emit("guardado");
  } catch (e) {
    await mostrarError(e);
  } finally {
    guardando.value = false;
  }
}
</script>

<style scoped>
.modulo { margin-bottom: 18px; }
.modulo-cab {
  display: flex; align-items: center; gap: 8px;
  padding-bottom: 6px; margin-bottom: 4px;
  border-bottom: 1px solid var(--line-soft);
}

.permiso {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 8px 10px; border-radius: 8px;
  cursor: pointer; user-select: none;
  border: 1px solid transparent;
}
.permiso:hover { background: var(--bg-soft); }
.permiso.marcado { background: var(--emerald-soft); border-color: var(--emerald-line); }
.permiso input { margin-top: 2px; accent-color: var(--emerald); cursor: pointer; }
.permiso-texto { min-width: 0; line-height: 1.4; }
.permiso-texto b { font-size: 11.5px; color: var(--ink); display: block; }
.permiso.marcado .permiso-texto b { color: var(--emerald-ink); }
.permiso-texto small { font-size: 12px; color: var(--ink-3); }
</style>
