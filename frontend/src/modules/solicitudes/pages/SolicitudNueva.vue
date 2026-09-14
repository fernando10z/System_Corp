<template>
  <div style="max-width: 660px">
    <PageHeader
      eyebrow="Entrada"
      title="Reportar una necesidad"
      subtitle="Cuente qué observó. No hace falta que sepa qué equipo es, ni qué lo causa, ni cuánto cuesta."
    />

    <form class="card" @submit.prevent="enviar">
      <div class="card-cuerpo col" style="gap: 16px">
        <div class="campo">
          <label class="campo-label" for="titulo">Título</label>
          <input id="titulo" v-model.trim="d.titulo" class="input" required minlength="5" maxlength="180"
                 placeholder="Ej. ruido anormal en el compresor 2" />
          <span class="campo-ayuda">Una frase corta que lo identifique.</span>
        </div>

        <div class="campo">
          <label class="campo-label" for="descripcion">¿Qué está pasando?</label>
          <textarea id="descripcion" v-model.trim="d.descripcion" class="textarea" required minlength="10"
                    placeholder="Desde cuándo, qué se oye o se ve, si afecta la producción…"></textarea>
          <span class="campo-ayuda">Este texto se conserva tal cual, aunque después el diagnóstico diga otra cosa.</span>
        </div>

        <div class="campo">
          <label class="campo-label" for="lugar">¿Dónde?</label>
          <input id="lugar" v-model.trim="d.lugar" class="input" required
                 placeholder="Ej. sala de compresores, nivel 1" />
          <span class="campo-ayuda">Como usted lo diría. No hace falta el código técnico del sitio.</span>
        </div>

        <div class="campo">
          <label class="campo-label" for="area">Área afectada</label>
          <select id="area" v-model="d.areaId" class="select" required>
            <option value="" disabled>Elija el área</option>
            <option v-for="a in areas" :key="a.id" :value="a.id">{{ a.nombre }} · {{ a.empresa_ruc }}</option>
          </select>
        </div>

        <div class="grid-2">
          <div class="campo">
            <label class="campo-label" for="impacto">¿Cómo afecta a la operación?</label>
            <select id="impacto" v-model="d.impactoOperativoId" class="select">
              <option value="">Sin indicar</option>
              <option v-for="i in impactos" :key="i.id" :value="i.id">{{ i.nombre }}</option>
            </select>
          </div>
          <div class="campo">
            <label class="campo-label" for="prioridad">¿Qué tan urgente le parece?</label>
            <select id="prioridad" v-model="d.prioridadPercibida" class="select">
              <option value="">Sin indicar</option>
              <option value="critica">Crítica</option>
              <option value="alta">Alta</option>
              <option value="media">Media</option>
              <option value="baja">Baja</option>
            </select>
            <span class="campo-ayuda">Es su percepción. El coordinador fijará la prioridad técnica.</span>
          </div>
        </div>

        <div v-if="impactoExigeComentario" class="campo">
          <label class="campo-label" for="impactoc">Cuéntenos más sobre el impacto</label>
          <input id="impactoc" v-model.trim="d.impactoComentario" class="input" required />
        </div>
      </div>

      <div class="card-cuerpo fila fila-sep" style="border-top: 1px solid var(--line-soft)">
        <button type="button" class="btn" :disabled="enviando" @click="guardarBorrador">Guardar como borrador</button>
        <button class="btn primary" type="submit" :disabled="enviando">
          {{ enviando ? "Enviando…" : "Enviar solicitud" }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from "vue";
import { useRouter } from "vue-router";
import PageHeader from "../../../layouts/PageHeader.vue";
import { solicitudesApi } from "../api/solicitudes.api.js";
import { catalogosApi, organizacionApi } from "../../shared/catalogos.api.js";
import { mostrarError, notify } from "../../../shared/composables/useNotify.js";

const router = useRouter();

const d = reactive({
  titulo: "", descripcion: "", lugar: "", areaId: "",
  impactoOperativoId: "", impactoComentario: "", prioridadPercibida: "",
});
const areas = ref([]);
const impactos = ref([]);
const enviando = ref(false);

// El ítem 'Otro' del catálogo exige comentario; el catálogo lo declara.
const impactoExigeComentario = computed(
  () => impactos.value.find((i) => i.id === d.impactoOperativoId)?.requiere_comentario ?? false,
);

async function guardar(enviar) {
  enviando.value = true;
  try {
    const r = await solicitudesApi.crear({ ...d, enviar });
    await notify.exito(
      enviar ? "Solicitud enviada" : "Borrador guardado",
      enviar ? `${r.data.numero} · el coordinador la revisará.` : "Puede terminarla cuando quiera.",
    );
    router.push(`/solicitudes/${r.data.id}`);
  } catch (e) {
    await mostrarError(e, "No se pudo registrar la solicitud");
  } finally {
    enviando.value = false;
  }
}
const enviar = () => guardar(true);
const guardarBorrador = () => guardar(false);

onMounted(async () => {
  try {
    const [a, c] = await Promise.all([organizacionApi.areas(), catalogosApi.todos("impacto_operativo")]);
    areas.value = a.data ?? [];
    impactos.value = c.data?.impacto_operativo ?? [];
  } catch (e) {
    await mostrarError(e, "No se pudieron cargar las áreas");
  }
});
</script>
