<template>
  <!--
    Evidencias. El documento (ST-01) las pide como entrada opcional de la
    solicitud: "Título, descripción, lugar, área, impacto operativo y prioridad
    percibida; evidencias opcionales". Sin esto el formulario cumplía todo menos
    la última palabra.
  -->
  <div class="adj">
    <label class="adj-zona" :class="{ arrastrando }"
      @dragover.prevent="arrastrando = true"
      @dragleave.prevent="arrastrando = false"
      @drop.prevent="alSoltar"
    >
      <input type="file" multiple :accept="acepta" class="sr-only" @change="alElegir" />
      <Paperclip :size="16" />
      <span>
        <b>{{ titulo }}</b>
        <small>{{ sugerencia }} {{ ayudaTamano }}</small>
      </span>
    </label>

    <ul v-if="archivos.length" class="adj-lista">
      <li v-for="(a, i) in archivos" :key="i" class="adj-item" :class="{ malo: !!a.error }">
        <component :is="iconoDe(a.file)" :size="15" class="adj-icono" />
        <span class="adj-nombre truncar">{{ a.file.name }}</span>
        <span class="adj-peso mono">{{ pesoLegible(a.file.size) }}</span>
        <span v-if="a.error" class="adj-error">{{ a.error }}</span>
        <button type="button" class="row-action" title="Quitar" @click="quitar(i)"><X :size="14" /></button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed, ref } from "vue";
import { FileText, Film, Image as Imagen, Paperclip, X } from "lucide-vue-next";

const props = defineProps({
  /** Bytes. Por defecto 25 MB, el límite de PDF/documento del cap. 28.3. */
  maximo: { type: Number, default: 26_214_400 },
  acepta: { type: String, default: "image/*,video/*,application/pdf,.doc,.docx,.xls,.xlsx" },

  /* Qué se pide aquí. Por defecto lo general; quien acepta un solo tipo de
     archivo lo dice con sus palabras en vez de ofrecer fotos y vídeos. */
  titulo: { type: String, default: "Adjunte fotos, videos o documentos" },
  sugerencia: { type: String, default: "Arrastre aquí o haga clic." },
});
const modelo = defineModel({ type: Array, default: () => [] });

const arrastrando = ref(false);
const archivos = computed({ get: () => modelo.value, set: (v) => (modelo.value = v) });

const ayudaTamano = computed(() => `Hasta ${Math.round(props.maximo / 1024 / 1024)} MB por archivo.`);

function pesoLegible(b) {
  if (b < 1024) return `${b} B`;
  if (b < 1024 * 1024) return `${Math.round(b / 1024)} KB`;
  return `${(b / 1024 / 1024).toFixed(1)} MB`;
}

function iconoDe(f) {
  if (f.type.startsWith("image/")) return Imagen;
  if (f.type.startsWith("video/")) return Film;
  return FileText;
}

/** Se valida el tamaño aquí para no subir 100 MB y que la API lo rechace. */
function agregar(lista) {
  const nuevos = [...lista].map((file) => ({
    file,
    error: file.size > props.maximo ? `Supera los ${Math.round(props.maximo / 1024 / 1024)} MB` : "",
  }));
  archivos.value = [...archivos.value, ...nuevos];
}

function alElegir(e) {
  agregar(e.target.files);
  e.target.value = "";
}
function alSoltar(e) {
  arrastrando.value = false;
  agregar(e.dataTransfer.files);
}
function quitar(i) {
  archivos.value = archivos.value.filter((_, j) => j !== i);
}
</script>

<style scoped>
.adj { display: flex; flex-direction: column; gap: 10px; }

.adj-zona {
  display: flex; align-items: center; gap: 12px;
  padding: 14px 16px;
  border: 1px dashed var(--line-strong); border-radius: var(--radius);
  background: var(--bg-soft); color: var(--ink-3);
  cursor: pointer;
  transition: border-color 0.12s, background 0.12s;
}
.adj-zona:hover, .adj-zona.arrastrando {
  border-color: var(--emerald); background: var(--emerald-soft); color: var(--emerald-ink);
}
.adj-zona b { display: block; font-size: 13px; color: var(--ink); font-weight: 600; }
.adj-zona.arrastrando b, .adj-zona:hover b { color: var(--emerald-ink); }
.adj-zona small { display: block; font-size: 11.5px; margin-top: 1px; }

.adj-lista { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 5px; }
.adj-item {
  display: flex; align-items: center; gap: 9px;
  padding: 7px 10px; border-radius: var(--radius-sm);
  background: var(--bg-soft); border: 1px solid var(--line);
  font-size: 12.5px;
}
.adj-item.malo { background: var(--red-soft); border-color: var(--red-line); }
.adj-icono { flex: none; color: var(--ink-3); }
.adj-item.malo .adj-icono { color: var(--red-ink); }
.adj-nombre { flex: 1; min-width: 0; color: var(--ink); }
.adj-peso { font-size: 11px; color: var(--ink-4); flex: none; }
.adj-error { font-size: 11.5px; color: var(--red-ink); font-weight: 600; flex: none; }
</style>
